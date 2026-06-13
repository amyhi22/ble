import 'package:flutter/material.dart';
import '../models/chat_history_model.dart';

class ChatSidebar extends StatefulWidget {
  final List<ChatConversation> conversations;
  final String? selectedConversationId;
  final Function(String) onConversationSelect;
  final Function() onNewChat;
  final Function(ChatConversation) onConversationDelete;
  final Function(ChatConversation) onConversationRename;
  final Function(ChatConversation) onConversationPin;
  final bool isOpen;
  final VoidCallback onToggleSidebar;

  const ChatSidebar({
    super.key,
    required this.conversations,
    this.selectedConversationId,
    required this.onConversationSelect,
    required this.onNewChat,
    required this.onConversationDelete,
    required this.onConversationRename,
    required this.onConversationPin,
    required this.isOpen,
    required this.onToggleSidebar,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ChatSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<ConversationGroup, List<ChatConversation>> _getGroupedConversations() {
    final now = DateTime.now();
    final grouped = <ConversationGroup, List<ChatConversation>>{};

    for (var conversation in widget.conversations) {
      final diff = now.difference(conversation.lastModified);
      ConversationGroup group;

      if (diff.inDays == 0) {
        group = ConversationGroup.today;
      } else if (diff.inDays == 1) {
        group = ConversationGroup.yesterday;
      } else if (diff.inDays <= 7) {
        group = ConversationGroup.previous7Days;
      } else {
        group = ConversationGroup.older;
      }

      grouped.putIfAbsent(group, () => []).add(conversation);
    }

    grouped.forEach((key, value) {
      value.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    });

    return grouped;
  }

  List<ChatConversation> _filterConversations() {
    if (_searchQuery.isEmpty) return widget.conversations;
    return widget.conversations
        .where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth < 768 ? screenWidth * 0.85 : 300.0;

    final groupedConversations = _getGroupedConversations();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            // --- FIX: Wrapped Column in SafeArea ---
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onNewChat,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('محادثة جديدة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002319),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: widget.onToggleSidebar,
                          icon: const Icon(Icons.menu_open_rounded),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFF5F5F5)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'البحث في المحادثات',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: ConversationGroup.values.length,
                      itemBuilder: (context, groupIndex) {
                        final group = ConversationGroup.values[groupIndex];
                        final conversations = groupedConversations[group] ?? [];

                        if (conversations.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                group.displayName,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            ...conversations.map((conversation) {
                              final isSelected = widget.selectedConversationId == conversation.id;
                              return _ConversationItem(
                                conversation: conversation,
                                isSelected: isSelected,
                                onTap: () => widget.onConversationSelect(conversation.id),
                                onPin: () => widget.onConversationPin(conversation),
                                onDelete: () => widget.onConversationDelete(conversation),
                                onRename: () => _showRenameDialog(conversation),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(ChatConversation conversation) {
    final controller = TextEditingController(text: conversation.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تسمية المحادثة'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'اسم المحادثة')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                widget.onConversationRename(conversation.copyWith(title: controller.text.trim()));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002319)),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final ChatConversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ConversationItem({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف المحادثة'),
            content: const Text('هل أنت متأكد من حذف هذه المحادثة؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF002319) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  conversation.isPinned ? Icons.push_pin : Icons.chat_bubble_outline,
                  size: 18,
                  color: isSelected ? Colors.white : const Color(0xFF594020),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 18, color: isSelected ? Colors.white : Colors.grey),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(children: [
                        Icon(conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(conversation.isPinned ? 'إلغاء التثبيت' : 'تثبيت'),
                      ]),
                    ),
                    PopupMenuItem(value: 'rename', child: const Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('إعادة تسمية')])),
                    PopupMenuItem(value: 'delete', child: const Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
                  ],
                  onSelected: (value) {
                    if (value == 'pin') onPin();
                    if (value == 'rename') onRename();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}