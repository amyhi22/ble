import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../chat/models/chat_history_model.dart';
import '../chat/widgets/chat_sidebar.dart';
import '../chat/widgets/message_bubble.dart';
import '../chat/widgets/chat_input_area.dart';
import '../chat/widgets/welcome_screen.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatConversation> _conversations = [];
  ChatConversation? _currentConversation;
  bool _isSidebarOpen = false;
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  final List<SuggestedPrompt> _prompts = [
    SuggestedPrompt(
      title: 'كشف أمراض القمح',
      text: 'كيف يمكنني التعرف على أمراض القمح في حقلي؟',
      icon: Icons.bug_report_rounded,
    ),
    SuggestedPrompt(
      title: 'توصية علاجية',
      text: 'ما هي أفضل طريقة لعلاج آفة الحشرات في الطماطم؟',
      icon: Icons.medical_services_rounded,
    ),
    SuggestedPrompt(
      title: 'مراقبة المحاصيل',
      text: 'كيف أراقب نمو المحاصيل بشكل فعال؟',
      icon: Icons.visibility_rounded,
    ),
    SuggestedPrompt(
      title: 'نصيحة زراعية',
      text: 'ما هو أفضل وقت لري المحاصيل في الصيف؟',
      icon: Icons.water_drop_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isMobile = MediaQuery.of(context).size.width < 768;
      if (!isMobile && mounted) {
        setState(() {
          _isSidebarOpen = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    setState(() {
      _conversations.clear();
      _conversations.add(ChatConversation(
        id: _uuid.v4(),
        title: 'استشارة عن أمراض القمح',
        messages: [],
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        isPinned: true,
      ));
    });
  }

  void _createNewChat() {
    final newConversation = ChatConversation(
      id: _uuid.v4(),
      title: 'محادثة جديدة',
      messages: [],
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    setState(() {
      _currentConversation = newConversation;
      _conversations.insert(0, newConversation);
    });
  }

  void _selectConversation(String conversationId) {
    final conversation = _conversations.firstWhere(
          (c) => c.id == conversationId,
    );

    setState(() {
      _currentConversation = conversation;
    });

    _scrollToBottom();
  }

  void _deleteConversation(ChatConversation conversation) {
    setState(() {
      _conversations.removeWhere((c) => c.id == conversation.id);
      if (_currentConversation?.id == conversation.id) {
        _currentConversation = null;
      }
    });
  }

  void _renameConversation(ChatConversation conversation) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        _conversations[index] = conversation;
        if (_currentConversation?.id == conversation.id) {
          _currentConversation = conversation;
        }
      }
    });
  }

  void _pinConversation(ChatConversation conversation) {
    setState(() {
      final index = _conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        _conversations[index] = conversation.copyWith(
          isPinned: !conversation.isPinned,
        );
      }
    });
  }

  Future<void> _sendMessage(String content) async {
    if (_currentConversation == null) {
      _createNewChat();
      return;
    }

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, userMessage],
        lastModified: DateTime.now(),
        title: _currentConversation!.messages.isEmpty
            ? content.length > 30
            ? '${content.substring(0, 30)}...'
            : content
            : _currentConversation!.title,
      );
      _isLoading = true;
    });

    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 2));

    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      content: _generateAIResponse(content),
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, aiMessage],
        lastModified: DateTime.now(),
      );
      _isLoading = false;
    });

    _scrollToBottom();
  }

  String _generateAIResponse(String userMessage) {
    final responses = [
      'بناءً على سؤالك عن الزراعة، أنصحك بالتركيز على الري المنتظم والتسميد المتوازن. هل تريد تفاصيل أكثر؟',
      'للكشف عن أمراض القمح، ابحث عن بقع بنية أو صفراء على الأوراق. أنصحك باستخدام مبيدات فطرية مناسبة.',
      'لتحسين نمو المحاصيل، تأكد من توفر العناصر الغذائية الأساسية في التربة والري في الوقت المناسب.',
    ];
    return responses[userMessage.length % responses.length];
  }

  void _handleLike(ChatMessage message) {
    setState(() {
      final index = _currentConversation!.messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _currentConversation!.messages[index] = message.copyWith(isLiked: !message.isLiked, isDisliked: false);
      }
    });
  }

  void _handleDislike(ChatMessage message) {
    setState(() {
      final index = _currentConversation!.messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _currentConversation!.messages[index] = message.copyWith(isDisliked: !message.isDisliked, isLiked: false);
      }
    });
  }

  void _handleRegenerate(ChatMessage message) => _sendMessage('regenerate');

  void _handleCopy(ChatMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ إلى الحافظة')));
  }

  void _handleShare(ChatMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري المشاركة...')));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    Widget mainContent = Column(
      children: [
        // ✅ الـ AppBar الرسمي - يعطي ارتفاعاً ثابتاً ومناسباً لجميع الهواتف
        AppBar(
          backgroundColor: const Color(0xFF594020),
          elevation: 2,
          centerTitle: false,
          automaticallyImplyLeading: false,
          toolbarHeight: 60,
          leading: isMobile && !_isSidebarOpen
              ? IconButton(
            onPressed: () => setState(() => _isSidebarOpen = true),
            icon: const Icon(Icons.menu_rounded),
            color: Colors.white,
          )
              : null,
          title: Text(
            _currentConversation?.title ?? 'المساعد الزراعي الذكي',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
              color: Colors.white,
            ),
          ],
        ),

        // --- MESSAGES / WELCOME ---
        Expanded(
          child: _currentConversation == null || _currentConversation!.messages.isEmpty
              ? WelcomeScreen(prompts: _prompts, onPromptTap: _sendMessage)
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _currentConversation!.messages.length,
            itemBuilder: (context, index) {
              final message = _currentConversation!.messages[index];
              return MessageBubble(
                message: message,
                isLastMessage: index == _currentConversation!.messages.length - 1,
                onLike: _handleLike,
                onDislike: _handleDislike,
                onRegenerate: _handleRegenerate,
                onCopy: _handleCopy,
                onShare: _handleShare,
              );
            },
          ),
        ),

        // --- INPUT AREA ---
        ChatInputArea(
          onSendMessage: _sendMessage,
          onAttachImage: () {},
          onVoiceInput: () {},
          isLoading: _isLoading,
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9F8),
        body: Stack(
          children: [
            mainContent,
            if (_isSidebarOpen) ...[
              GestureDetector(
                onTap: () => setState(() => _isSidebarOpen = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
              ChatSidebar(
                conversations: _conversations,
                selectedConversationId: _currentConversation?.id,
                onConversationSelect: (id) {
                  _selectConversation(id);
                  setState(() => _isSidebarOpen = false);
                },
                onNewChat: () {
                  _createNewChat();
                  setState(() => _isSidebarOpen = false);
                },
                onConversationDelete: _deleteConversation,
                onConversationRename: _renameConversation,
                onConversationPin: _pinConversation,
                isOpen: _isSidebarOpen,
                onToggleSidebar: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
              ),
            ],
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9F8),
        body: Row(
          children: [
            if (_isSidebarOpen)
              ChatSidebar(
                conversations: _conversations,
                selectedConversationId: _currentConversation?.id,
                onConversationSelect: _selectConversation,
                onNewChat: _createNewChat,
                onConversationDelete: _deleteConversation,
                onConversationRename: _renameConversation,
                onConversationPin: _pinConversation,
                isOpen: _isSidebarOpen,
                onToggleSidebar: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
              ),
            Expanded(child: mainContent),
          ],
        ),
      );
    }
  }
}