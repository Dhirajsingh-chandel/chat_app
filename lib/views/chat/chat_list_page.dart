import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/controllers/auth_controller.dart';
import 'package:untitled3/views/profile_page.dart';
import '../../models/user_model.dart';
import 'chat_page.dart';



class ChatListPage extends StatelessWidget {
   ChatListPage({super.key});

  final auth = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Chats"),
        actions: [
          IconButton(
              onPressed: (){
                auth.logout();
              },
              icon: const Icon(Icons.login_outlined)
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .map((doc) =>
              UserModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          // Exclude the current user from the chat list
          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          final otherUsers = users.where((user) => user.uid != currentUserId).toList();

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final user = otherUsers[index];

              return ListTile(
                leading: InkWell(
                  onTap: (){
                    Get.to(() => ProfilePage(userId: user.uid)); // Pass user ID
                  },
                  child: CircleAvatar(
                    backgroundImage: user.profileImageUrl.isNotEmpty
                        ? NetworkImage(user.profileImageUrl)
                        : const AssetImage("assets/images/profile.png")
                    as ImageProvider,
                  ),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () {
                  final chatId = _getChatId(user.uid);
                  Get.to(() => ChatPage(chatId: chatId, receiverName: user.name));
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getChatId(String receiverId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Ensure the chat ID is consistent regardless of the sender/receiver
    return currentUserId.compareTo(receiverId) < 0
        ? "${currentUserId}_$receiverId"
        : "${receiverId}_$currentUserId";
  }
}
