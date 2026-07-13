// lib/models/chat_message.model.dart
import 'package:json_annotation/json_annotation.dart';

part 'chat_message.model.g.dart';

@JsonSerializable()
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}