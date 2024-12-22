import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';



class ChatPage extends StatelessWidget {
  final String chatId;
  final String receiverName;
  final TextEditingController messageController = TextEditingController();

  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final ChatController chatController = Get.put(ChatController());

  ChatPage({super.key, required this.chatId, required this.receiverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .doc(chatId)
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs.map((doc) {
                  return ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message.senderId == FirebaseAuth.instance.currentUser!.uid;

                    return Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: message.mediaUrl != null
                            ? Image.network(
                          message.mediaUrl!,
                          errorBuilder: (context, error, stackTrace) =>  const Icon(Icons.error_outline),
                        )
                            : Text(
                          message.message,
                          style: TextStyle(color: isSender ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    final picker = ImagePicker();
                    pickedImage.value = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage.value != null) {
                      final mediaUrl = await chatController.uploadMedia(File(pickedImage.value!.path));
                      if (mediaUrl.isNotEmpty) {
                        chatController.sendMessage(chatId: chatId, mediaUrl: mediaUrl); // Provide chatId here
                      } else {
                        Get.snackbar("Error", "Failed to upload media.");
                      }
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      chatController.sendMessage(chatId: chatId, message: message); // Pass chatId here
                      messageController.clear();
                    } else {
                      Get.snackbar("Error", "Message cannot be empty.");
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
