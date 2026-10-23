import 'package:flutter/material.dart';
import 'package:plant/AiInput.dart';
import 'package:plant/UserInput.dart';
import 'package:plant/services/gemini_service.dart';
import 'package:plant/services/localization_service.dart';
import 'package:plant/services/weather_service.dart';

class ChatPage extends StatefulWidget {
  final WeatherAdvisoryData? weatherContext;
  final String? initialPrompt;
  final String? plantContext;

  const ChatPage({
    super.key,
    this.weatherContext,
    this.initialPrompt,
    this.plantContext,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Welcome message in current language
    _messages.add({
      'content': LocalizationService.tr('chat_greeting'),
      'isUser': false,
      'isLoading': false,
    });

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isGenerating) return;

    _textController.clear();

    setState(() {
      _messages.add({
        'content': cleanText,
        'isUser': true,
        'isLoading': false,
      });
      _messages.add({
        'content': LocalizationService.tr('chat_thinking'),
        'isUser': false,
        'isLoading': true,
      });
      _isGenerating = true;
    });
    _scrollToBottom();

    try {
      final responseText = await GeminiService.chatMessage(
        message: cleanText,
        chatHistory: _messages,
        weatherContext: widget.weatherContext,
        currentPlantContext: widget.plantContext,
      );

      if (mounted) {
        setState(() {
          // Replace loading placeholder with actual response
          _messages.removeLast();
          _messages.add({
            'content': responseText,
            'isUser': false,
            'isLoading': false,
          });
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add({
            'content': LocalizationService.tr('chat_error'),
            'isUser': false,
            'isLoading': false,
          });
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  List<String> _getQuickChips() {
    return [
      LocalizationService.tr('quick_tomato'),
      LocalizationService.tr('quick_fertilizer'),
      LocalizationService.tr('quick_fungal'),
      LocalizationService.tr('quick_weather'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E4032), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF517159).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Color(0xFF517159), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.tr('chat_title'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E4032),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'Gemini Krishi AI • Evidence-based',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF517159)),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'content': LocalizationService.tr('chat_greeting'),
                  'isUser': false,
                  'isLoading': false,
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Weather banner indicator if context is present
          if (widget.weatherContext != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFEFF5F0),
              child: Row(
                children: [
                  const Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF517159)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.weatherContext!.cityName}: ${widget.weatherContext!.temperature}°C, ${widget.weatherContext!.weatherDescription}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF517159)),
                    ),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isUser'] == true) {
                  return UserInput(message: msg['content']);
                } else {
                  return AiInput(
                    message: msg['content'],
                    isLoading: msg['isLoading'] == true,
                  );
                }
              },
            ),
          ),

          // Quick Suggestion Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _getQuickChips().map((chipText) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.green.shade200),
                    label: Text(
                      chipText,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF3F6F4C)),
                    ),
                    onPressed: _isGenerating ? null : () => _sendMessage(chipText),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Text Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: LocalizationService.tr('chat_hint'),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => _sendMessage(val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF517159),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isGenerating
                          ? null
                          : () => _sendMessage(_textController.text),
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
