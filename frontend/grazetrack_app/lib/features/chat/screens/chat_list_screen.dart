import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../chat_provider.dart';
import '../../../core/theme/app_theme.dart';

// ─── Chat List Screen ─────────────────────────────────────────────────────────
//
// Two tabs:
//   "Chats"   — existing conversations, sorted by most recent message
//   "Farmers" — farmers you have already communicated with; tap "Find Farmers"
//               to discover new ones via a bottom sheet

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(chatProvider.notifier).loadThreads();
    });
    _tabs.addListener(() {
      if (_tabs.index == 0 && !_tabs.indexIsChanging) {
        ref.read(chatProvider.notifier).loadThreads();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chats'),
            Tab(icon: Icon(Icons.people_outline), text: 'Farmers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _ChatsTab(),
          _FarmersTab(),
        ],
      ),
    );
  }
}

// ─── Tab 1: Existing Conversations ───────────────────────────────────────────

class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.threads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64,
                color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('No conversations yet',
                style: TextStyle(fontSize: 17, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('Go to the Farmers tab to start a chat',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    // Deduplicate: show one entry per unique other user (most recent thread).
    // The backend already deduplicates, but this is a client-side safety net
    // in case older threads are cached locally.
    final seen = <String>{};
    final unique = state.threads
        .where((t) =>
            t['otherUserId'] != null &&
            seen.add(t['otherUserId'] as String))
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(chatProvider.notifier).loadThreads(),
      child: ListView.separated(
        itemCount: unique.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 72),
        itemBuilder: (_, i) => _ThreadTile(thread: unique[i]),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final Map<String, dynamic> thread;
  const _ThreadTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    final name    = thread['otherUserName'] ?? 'Farmer';
    final lastMsg = thread['lastMessage'] ?? '';
    final lastAt  = thread['lastMessageAt'] ?? '';
    final isDirect = thread['isDirect'] == true;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'F';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.primaryGreen.withAlpha(30),
        child: Text(initial,
            style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (lastAt.isNotEmpty)
            Text(_formatTime(lastAt),
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      subtitle: Text(
        lastMsg.isEmpty
            ? (isDirect ? 'Direct message' : 'New conversation')
            : lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Colors.grey[600], fontSize: 13),
      ),
      onTap: () => context.push(
        '/chat/thread/${thread['id']}',
        extra: {'sellerName': name},
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt  = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}

// ─── Tab 2: Contacted Farmers ─────────────────────────────────────────────────
//
// Shows only farmers the current user has already communicated with.
// A "Find Farmers" button opens a bottom sheet with all active farmers
// so the user can start new conversations.

class _FarmersTab extends ConsumerWidget {
  const _FarmersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);

    // Derive unique contacted farmers from existing threads
    final seen = <String>{};
    final contacted = state.threads
        .where((t) =>
            t['otherUserId'] != null &&
            seen.add(t['otherUserId'] as String))
        .map((t) => {
              'id': t['otherUserId'] as String,
              'name': (t['otherUserName'] as String?) ?? 'Farmer',
              'threadId': t['id'] as String,
              'lastMessage': (t['lastMessage'] as String?) ?? '',
              'lastMessageAt': (t['lastMessageAt'] as String?) ?? '',
            })
        .toList();

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // ── Find new farmers button ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: OutlinedButton.icon(
            onPressed: () => _showFindFarmersSheet(context, ref),
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Find Farmers to Chat'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

        // ── List of contacted farmers ────────────────────────────────
        Expanded(
          child: contacted.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text('No farmers contacted yet',
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey)),
                      const SizedBox(height: 6),
                      const Text(
                          'Tap "Find Farmers" above to start a conversation',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(chatProvider.notifier).loadThreads(),
                  child: ListView.separated(
                    itemCount: contacted.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) =>
                        _ContactedFarmerTile(farmer: contacted[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showFindFarmersSheet(BuildContext context, WidgetRef ref) {
    ref.read(chatProvider.notifier).loadFarmers();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const _FindFarmersSheet(),
    );
  }
}

// Tile for a farmer you've already chatted with — navigates to existing thread
class _ContactedFarmerTile extends StatelessWidget {
  final Map<String, dynamic> farmer;
  const _ContactedFarmerTile({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final name     = farmer['name'] as String? ?? 'Farmer';
    final lastMsg  = farmer['lastMessage'] as String? ?? '';
    final lastAt   = farmer['lastMessageAt'] as String? ?? '';
    final threadId = farmer['threadId'] as String;
    final initial  = name.isNotEmpty ? name[0].toUpperCase() : 'F';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.accentGreen.withAlpha(60),
        child: Text(initial,
            style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (lastAt.isNotEmpty)
            Text(_formatTime(lastAt),
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      subtitle: Text(
        lastMsg.isEmpty ? 'Tap to continue conversation' : lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: const Icon(Icons.chat_bubble_outline,
          color: AppTheme.primaryGreen, size: 20),
      onTap: () => context.push(
        '/chat/thread/$threadId',
        extra: {'sellerName': name},
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt  = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year &&
          dt.month == now.month &&
          dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}

// ─── Bottom Sheet: Find New Farmers ──────────────────────────────────────────

class _FindFarmersSheet extends ConsumerWidget {
  const _FindFarmersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('Find Farmers',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: state.isFarmersLoading
                ? const Center(child: CircularProgressIndicator())
                : state.farmers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text('No other farmers found',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(chatProvider.notifier)
                                  .loadFarmers(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: state.farmers.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (_, i) =>
                            _FarmerTile(farmer: state.farmers[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Farmer Tile (for "Find Farmers" sheet) ───────────────────────────────────

class _FarmerTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> farmer;
  const _FarmerTile({required this.farmer});

  @override
  ConsumerState<_FarmerTile> createState() => _FarmerTileState();
}

class _FarmerTileState extends ConsumerState<_FarmerTile> {
  bool _opening = false;

  Future<void> _openChat() async {
    setState(() => _opening = true);

    final threadId = await ref
        .read(chatProvider.notifier)
        .getOrCreateThread(widget.farmer['id'] as String);

    if (!mounted) return;
    setState(() => _opening = false);

    if (threadId != null) {
      // Reload threads so the new contact appears in the Farmers tab
      ref.read(chatProvider.notifier).loadThreads();
      if (context.mounted) {
        Navigator.of(context).pop(); // close the bottom sheet
        context.push(
          '/chat/thread/$threadId',
          extra: {'sellerName': widget.farmer['name'] ?? 'Farmer'},
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not open chat. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name    = widget.farmer['name'] ?? 'Farmer';
    final phone   = widget.farmer['phone'] ?? '';
    final photo   = widget.farmer['profilePhotoUrl'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'F';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.accentGreen.withAlpha(60),
        backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
        child: photo.isEmpty
            ? Text(initial,
                style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18))
            : null,
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: phone.isNotEmpty
          ? Row(children: [
              const Icon(Icons.phone_outlined,
                  size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(phone,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
            ])
          : const Text('Farmer',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: _opening
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.chat_bubble_outline,
              color: AppTheme.primaryGreen),
      onTap: _opening ? null : _openChat,
    );
  }
}
