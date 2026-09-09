import 'package:flutter/foundation.dart';
import '../models/user_role.dart';

class ChatMessage {
  final String text;
  final bool fromMe;
  final DateTime time;
  ChatMessage({required this.text, required this.fromMe, DateTime? time}) : time = time ?? DateTime.now();
}

class ChatThread {
  final String id;
  final UserRole audience;
  final String title;
  final String subtitle;
  final String? avatarAsset;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.audience,
    required this.title,
    required this.subtitle,
    this.avatarAsset,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}

/// Локальный чат для демо-проекта. Позже его можно без изменения UI
/// подключить к Firebase/REST/WebSocket.
class ChatProvider extends ChangeNotifier {
  final List<ChatThread> _threads = [
    ChatThread(
      id: 'support',
      audience: UserRole.buyer,
      title: 'ЭлектроМаркет',
      subtitle: 'Служба поддержки',
      messages: [
        ChatMessage(text: 'Здравствуйте! Чем можем помочь?', fromMe: false),
      ],
    ),
    ChatThread(
      id: 'seller-1',
      audience: UserRole.buyer,
      title: 'ЭлектроСнаб',
      subtitle: 'Продавец • Заказ #10482',
      messages: [
        ChatMessage(text: 'Здравствуйте! Ваш заказ уже собирается.', fromMe: false),
      ],
    ),
    ChatThread(
      id: 'buyer-1',
      audience: UserRole.seller,
      title: 'Айбек',
      subtitle: 'Покупатель • Заказ #10482',
      messages: [
        ChatMessage(text: 'Здравствуйте, когда будет доставка?', fromMe: false),
      ],
    ),
    ChatThread(
      id: 'buyer-2',
      audience: UserRole.seller,
      title: 'Нурбек',
      subtitle: 'Покупатель • Заказ #10476',
      messages: [
        ChatMessage(text: 'Можно уточнить наличие товара?', fromMe: false),
      ],
    ),
  ];

  List<ChatThread> threadsFor(UserRole? role) {
    if (role == null) return const [];
    return _threads.where((t) => t.audience == role).toList(growable: false);
  }

  ChatThread? byId(String id, UserRole? role) {
    for (final thread in _threads) {
      if (thread.id == id && thread.audience == role) return thread;
    }
    return null;
  }

  void send(String threadId, String text, UserRole? role) {
    final value = text.trim();
    if (value.isEmpty) return;
    final thread = byId(threadId, role);
    if (thread == null) return;
    thread.messages.add(ChatMessage(text: value, fromMe: true));
    notifyListeners();

    // Демо-ответ, чтобы чат ощущался живым.
    Future.delayed(const Duration(milliseconds: 850), () {
      if (!thread.messages.any((m) => m.text == value && m.fromMe)) return;
      final reply = thread.id == 'support'
          ? 'Спасибо! Мы получили сообщение и скоро ответим.'
          : role == UserRole.seller
              ? 'Спасибо, сообщение получил. Сейчас уточню информацию.'
              : 'Спасибо! Сейчас уточню информацию по вашему заказу.';
      thread.messages.add(ChatMessage(text: reply, fromMe: false));
      notifyListeners();
    });
  }
}
