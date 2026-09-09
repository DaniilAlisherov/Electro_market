import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_role.dart';
import '../../state/app_settings_provider.dart';
import '../../state/chat_provider.dart';
import '../../state/user_provider.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isSeller = role == UserRole.seller;
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;
    final chats = context.watch<ChatProvider>().threadsFor(role);

    return Scaffold(
      appBar: AppBar(title: Text(isKyrgyz ? 'Чаттар' : 'Чаты')),
      body: chats.isEmpty
          ? Center(child: Text(isKyrgyz ? 'Чаттар азырынча жок' : 'Пока нет чатов'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final last = chat.lastMessage;
                return Material(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/chats/${chat.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isSeller ? Icons.person_outline_rounded : (chat.id == 'support' ? Icons.support_agent_outlined : Icons.storefront_outlined), color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(chat.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(chat.subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.inkFaint)),
                                if (last != null) ...[
                                  const SizedBox(height: 5),
                                  Text(last.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 19, color: AppColors.inkFaint),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ChatConversationScreen extends StatefulWidget {
  final String chatId;
  const ChatConversationScreen({super.key, required this.chatId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final role = context.read<UserProvider>().role;
    context.read<ChatProvider>().send(widget.chatId, _controller.text, role);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final chat = context.watch<ChatProvider>().byId(widget.chatId, role);
    final isKyrgyz = context.watch<AppSettingsProvider>().language == AppLanguage.kyrgyz;

    if (chat == null) {
      return Scaffold(appBar: AppBar(title: Text(isKyrgyz ? 'Чат' : 'Чат')), body: const Center(child: Text('Чат не найден')));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(radius: 17, backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10), child: Icon(chat.id == 'support' ? Icons.support_agent_outlined : Icons.person_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(chat.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), Text(chat.subtitle, style: const TextStyle(fontSize: 9.5, color: AppColors.inkFaint))])),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                return Align(
                  alignment: message.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.fromMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16).copyWith(bottomRight: Radius.circular(message.fromMe ? 5 : 16), bottomLeft: Radius.circular(message.fromMe ? 16 : 5)),
                      border: message.fromMe ? null : Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Text(message.text, style: TextStyle(fontSize: 12.5, height: 1.3, color: message.fromMe ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 10),
              child: Row(children: [
                Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: isKyrgyz ? 'Билдирүү жазыңыз...' : 'Напишите сообщение...', filled: true, fillColor: Theme.of(context).colorScheme.surfaceContainer, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11)))),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded, size: 18)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
