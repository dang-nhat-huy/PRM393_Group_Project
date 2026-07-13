// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  content: json['content'] as String,
  isUser: json['isUser'] as bool,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'content': instance.content,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
    };
