import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

// ─── Chat Screen ──────────────────────────────────────────────────────────────
//
// Real-time messaging between a buyer and a seller.
//
// Features:
//   • Text messages
//   • Image sharing — paste an image URL and it renders inline
//   • Read receipts — double-tick shown for messages the other person has read
//   • Edit / Delete — long-press any of your own messages to edit or delete
//   • "(edited)" label shown on edited messages

class ChatScreen extends ConsumerStatefulWidget {
  final String threadId;
  final Map<String, dynamic>? threadMeta;

  const ChatScreen({super.key, required this.threadId, this.threadMeta});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    Future.microtask(() async {
      await ref.read(chatProvider.notifier).loadMessages(widget.threadId);
      await _markRead();
      _scrollToBottom();
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) setState(() => _currentUserId = user?['id']);
  }

  Future<void> _markRead() async {
    try {
      await ApiService().put('/chat/thread/${widget.threadId}/read', {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await ref.read(chatProvider.notifier).sendMessage(widget.threadId, text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showImageUrlDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Share an Image'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Paste image URL here…',
            prefixIcon: Icon(Icons.link),
          ),
          autofocus: true,
          onSubmitted: (_) {
            final url = ctrl.text.trim();
            if (url.isNotEmpty) {
              Navigator.pop(context);
              ref.read(chatProvider.notifier)
                  .sendMessage(widget.threadId, url);
              _scrollToBottom();
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final url = ctrl.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                ref.read(chatProvider.notifier)
                    .sendMessage(widget.threadId, url);
                _scrollToBottom();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // ─── Edit / Delete ────────────────────────────────────────────────────────

  /// Long-press bottom sheet — Edit or Delete
  void _showMessageOptions(String messageId, String currentContent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppTheme.primaryGreen),
              title: const Text('Edit Message'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(messageId, currentContent);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Message',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm(messageId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String messageId, String currentContent) {
    final ctrl = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
              hintText: 'Update your message…',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen),
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              final ok = await ref
                  .read(chatProvider.notifier)
                  .editMessage(messageId, text);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Could not edit message')));
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirm(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
            'This message will be permanently deleted. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await ref
          .read(chatProvider.notifier)
          .deleteMessage(messageId);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not delete message')));
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final title = widget.threadMeta?['sellerName'] ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Text('Hold a message to edit or delete',
                style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref
                  .read(chatProvider.notifier)
                  .loadMessages(widget.threadId);
              _scrollToBottom();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ─── Messages List ────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No messages yet',
                                style: TextStyle(color: Colors.grey)),
                            Text('Say hello to start the conversation!',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding:
                            const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        itemCount: state.messages.length,
                        itemBuilder: (_, i) {
                          final msg  = state.messages[i];
                          final isMe = msg['senderId'] == _currentUserId;
                          return _MessageBubble(
                            message: msg,
                            isMe: isMe,
                            // Only the sender can edit/delete their messages
                            onLongPress: isMe
                                ? () => _showMessageOptions(
                                    msg['id'] as String,
                                    msg['content'] as String? ?? '')
                                : null,
                          );
                        },
                      ),
          ),

          // ─── Input Bar ────────────────────────────────────
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined,
                        color: AppTheme.primaryGreen),
                    tooltip: 'Share image URL',
                    onPressed: _showImageUrlDialog,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: state.isSending ? null : _send,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      child: state.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final VoidCallback? onLongPress; // null = not the sender, no options shown

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.onLongPress,
  });

  bool _isImageUrl(String text) {
    final lower = text.toLowerCase();
    return (lower.startsWith('http://') || lower.startsWith('https://')) &&
        (lower.contains('.jpg') ||
            lower.contains('.jpeg') ||
            lower.contains('.png') ||
            lower.contains('.gif') ||
            lower.contains('.webp'));
  }

  @override
  Widget build(BuildContext context) {
    final content    = message['content'] as String? ?? '';
    final senderName = message['senderName'] as String? ?? '';
    final time       = _formatTime(message['createdAt'] as String? ?? '');
    final isRead     = message['read'] == true;
    final isEdited   = message['editedAt'] != null;
    final isImage    = _isImageUrl(content);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Sender name (only for the other person's messages)
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(senderName,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600)),
                ),

              // Message bubble
              Container(
                clipBehavior: isImage ? Clip.antiAlias : Clip.none,
                decoration: BoxDecoration(
                  color: isMe
                      ? AppTheme.primaryGreen
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[200]),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                ),
                child: isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isMe
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                          bottomRight: isMe
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                        ),
                        child: Image.network(
                          content,
                          width: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : const SizedBox(
                                      width: 200,
                                      height: 120,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))),
                          errorBuilder: (_, __, ___) => Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(content,
                                style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 14)),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Text(
                          content,
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 14),
                        ),
                      ),
              ),

              // Time + read receipt + edited label
              Padding(
                padding:
                    const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEdited)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text('edited',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic)),
                      ),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 12,
                        color: isRead ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
