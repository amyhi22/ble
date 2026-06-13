import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final List<SuggestedPrompt> prompts;
  final Function(String) onPromptTap;

  const WelcomeScreen({
    super.key,
    required this.prompts,
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF002319), Color(0xFF594020)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF002319).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'كيف يُمكنني مساعدتك اليوم؟',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'مساعدك الذكي للزراعة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 48),

            // Suggested prompts mapped correctly
            ...prompts.map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PromptCard(
                  prompt: prompt,
                  onTap: () => onPromptTap(prompt.text),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Corrected Class Definition with proper 'final' keywords
class SuggestedPrompt {
  final String title;
  final String text;
  final IconData icon;

  const SuggestedPrompt({
    required this.title,
    required this.text,
    required this.icon,
  });
}

class PromptCard extends StatefulWidget {
  final SuggestedPrompt prompt;
  final VoidCallback onTap;

  const PromptCard({
    super.key,
    required this.prompt,
    required this.onTap,
  });

  @override
  State<PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<PromptCard> {
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF002319) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? const Color(0xFF002319) : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: const Color(0xFF002319).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.prompt.icon,
                  color: _isHovered ? Colors.white : const Color(0xFF594020),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prompt.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isHovered ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.prompt.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: _isHovered
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _isHovered ? Colors.white : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}