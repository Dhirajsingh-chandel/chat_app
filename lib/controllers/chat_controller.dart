import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isUploading = false.obs;
  List<XFile> selectedImages = [];
  List<String> imageUrls = [];



  Future<void> sendMessage({String? message, String? mediaUrl, required String chatId}) async {
    if (message == null && mediaUrl == null) {
      Get.snackbar("Error", "Cannot send an empty message.");
      return;
    }

    if (chatId.isEmpty) {
      Get.snackbar("Error", "Invalid chat ID.");
      return;
    }

    final senderId = FirebaseAuth.instance.currentUser?.uid;
    if (senderId == null) {
      Get.snackbar("Error", "User not authenticated.");
      return;
    }

    final receiverId = chatId.replaceAll(senderId, "").replaceAll("_", "");
    final chatMessage = ChatMessageModel(
      senderId: senderId,
      receiverId: receiverId,
      message: message ?? "",
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
    );

    try {
      await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .add(chatMessage.toJson());
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: ${e.toString()}");
    }
  }



  Future<String> uploadMedia(File file) async {
    try {
      // Get the reference to the Firebase storage bucket
      final FirebaseStorage storage = FirebaseStorage.instance;
      final storageRef = storage.refFromURL("gs://chat-app-1865e.firebasestorage.app");

      // Create a reference to the specific file within your storage
      final storagePath = "chat_media/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      final mediaRef = storageRef.child(storagePath);  // Child reference for the specific file

      // Start uploading the file to Firebase Storage
      final uploadTask = mediaRef.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});

      // Once the upload is complete, get the download URL
      final mediaUrl = await snapshot.ref.getDownloadURL();
      return mediaUrl;
    } catch (e) {
      Get.snackbar("Upload Error", "Failed to upload media: ${e.toString()}");
      return "";
    }
  }



  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection("chats/$chatId/messages")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MessageModel.fromJson(doc.data())).toList());
  }



}
