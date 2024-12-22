// models/chat_message_model.dart
class ChatMessageModel {
  String senderId;
  String receiverId;
  String message;
  String? mediaUrl;
  DateTime timestamp;

  ChatMessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.mediaUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    "senderId": senderId,
    "receiverId": receiverId,
    "message": message,
    "mediaUrl": mediaUrl,
    "timestamp": timestamp.toIso8601String(),
  };

  static ChatMessageModel fromJson(Map<String, dynamic> json) => ChatMessageModel(
    senderId: json['senderId'],
    receiverId: json['receiverId'],
    message: json['message'],
    mediaUrl: json['mediaUrl'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
