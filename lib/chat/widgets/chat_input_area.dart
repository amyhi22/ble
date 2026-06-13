import 'package:flutter/material.dart';

class ChatInputArea extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function() onAttachImage;
  final Function() onVoiceInput;
  final bool isLoading;

  const ChatInputArea({
    super.key,
    required this.onSendMessage,
    required this.onAttachImage,
    required this.onVoiceInput,
    this.isLoading = false,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attach button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: widget.isLoading ? null : widget.onAttachImage,
                    icon: const Icon(Icons.attach_file_rounded),
                    color: const Color(0xFF594020),
                  ),
                ),
                const SizedBox(width: 8),

                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      enabled: !widget.isLoading,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'سأل أي شيء عن الزراعة...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Voice/Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _controller.text.trim().isEmpty && !widget.isLoading
                        ? null
                        : const LinearGradient(
                      colors: [Color(0xFF002319), Color(0xFF594020)],
                    ),
                    color: _controller.text.trim().isEmpty && !widget.isLoading
                        ? const Color(0xFFF5F5F5)
                        : null,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _controller.text.trim().isNotEmpty && !widget.isLoading
                        ? [
                      BoxShadow(
                        color: const Color(0xFF002319).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (widget.isLoading) return;
                        if (_controller.text.trim().isEmpty) {
                          widget.onVoiceInput();
                        } else {
                          _handleSend();
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Center(
                        child: widget.isLoading
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : Icon(
                          _controller.text.trim().isEmpty
                              ? Icons.mic_rounded
                              : Icons.send_rounded,
                          color: _controller.text.trim().isEmpty
                              ? const Color(0xFF594020)
                              : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF002319),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جاري الكتابة...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}