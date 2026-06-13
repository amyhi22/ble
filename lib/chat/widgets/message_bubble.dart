import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_history_model.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isLastMessage;
  final Function(ChatMessage) onLike;
  final Function(ChatMessage) onDislike;
  final Function(ChatMessage) onRegenerate;
  final Function(ChatMessage) onCopy;
  final Function(ChatMessage) onShare;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isLastMessage,
    required this.onLike,
    required this.onDislike,
    required this.onRegenerate,
    required this.onCopy,
    required this.onShare,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.message.role == MessageRole.user
          ? const Offset(0.2, 0)
          : const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF002319), Color(0xFF594020)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF002319)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        boxShadow: isUser
                            ? []
                            : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          if (widget.message.attachments != null &&
                              widget.message.attachments!.isNotEmpty)
                            const SizedBox(height: 8),
                          if (widget.message.attachments != null)
                            ...widget.message.attachments!.map((attachment) {
                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: isUser
                                          ? Colors.white
                                          : const Color(0xFF594020),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'صورة',
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    if (!isUser && widget.isLastMessage)
                      AnimatedOpacity(
                        opacity: _showActions ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ActionButton(
                                icon: Icons.copy_outlined,
                                label: 'نسخ',
                                onTap: () => widget.onCopy(widget.message),
                              ),
                              const SizedBox(width: 4),
                              _ActionButton(
                                icon: Icons.refresh_rounded,
                                label: 'إعادة',
                                onTap: () => widget.onRegenerate(widget.message),
                              ),
                              const SizedBox(width: 4),
                              _ActionButton(
                                icon: widget.message.isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                label: 'إعجاب',
                                onTap: () => widget.onLike(widget.message),
                                isActive: widget.message.isLiked,
                              ),
                              const SizedBox(width: 4),
                              _ActionButton(
                                icon: widget.message.isDisliked
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                label: 'عدم إعجاب',
                                onTap: () => widget.onDislike(widget.message),
                                isActive: widget.message.isDisliked,
                              ),
                              const SizedBox(width: 4),
                              _ActionButton(
                                icon: Icons.share_outlined,
                                label: 'مشاركة',
                                onTap: () => widget.onShare(widget.message),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                      child: Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF594020),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inHours < 1) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inDays < 1) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF002319).withOpacity(0.1)
                : _isHovered
                ? Colors.grey.shade100
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isActive
                    ? const Color(0xFF002319)
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isActive
                      ? const Color(0xFF002319)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}