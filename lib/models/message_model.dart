class MessageModel {
  String senderId;
  String receiverId;
  String message;
  String? mediaUrl;
  DateTime timestamp;

  MessageModel({
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

  static MessageModel fromJson(Map<String, dynamic> json) => MessageModel(
    senderId: json['senderId'],
    receiverId: json['receiverId'],
    message: json['message'],
    mediaUrl: json['mediaUrl'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
