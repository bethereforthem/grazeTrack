import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../chat_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatTitle),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.chat_bubble_outline), text: l10n.chatsTab),
            Tab(icon: const Icon(Icons.people_outline), text: l10n.farmersTab),
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

class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);
    final l10n = AppLocalizations.of(context);

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
            Text(l10n.noConversations,
                style: const TextStyle(fontSize: 17, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(l10n.goToFarmersTab,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

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
    final l10n = AppLocalizations.of(context);
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
            ? (isDirect ? l10n.directMessage : l10n.newConversation)
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

class _FarmersTab extends ConsumerWidget {
  const _FarmersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);
    final l10n = AppLocalizations.of(context);

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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: OutlinedButton.icon(
            onPressed: () => _showFindFarmersSheet(context, ref),
            icon: const Icon(Icons.search, size: 18),
            label: Text(l10n.findFarmersToChat),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

        Expanded(
          child: contacted.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(l10n.noFarmersContactedYet,
                          style: const TextStyle(
                              fontSize: 17, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(l10n.tapFindFarmers,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                          textAlign: TextAlign.center),
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

class _ContactedFarmerTile extends StatelessWidget {
  final Map<String, dynamic> farmer;
  const _ContactedFarmerTile({required this.farmer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        lastMsg.isEmpty ? l10n.tapToContinueConversation : lastMsg,
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

class _FindFarmersSheet extends ConsumerWidget {
  const _FindFarmersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(l10n.findFarmers,
              style: const TextStyle(
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
                            Text(l10n.noOtherFarmersFound,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(chatProvider.notifier)
                                  .loadFarmers(),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
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
      ref.read(chatProvider.notifier).loadThreads();
      if (context.mounted) {
        Navigator.of(context).pop();
        context.push(
          '/chat/thread/$threadId',
          extra: {'sellerName': widget.farmer['name'] ?? 'Farmer'},
        );
      }
    } else {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenChat)),
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
