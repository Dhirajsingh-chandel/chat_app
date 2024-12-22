import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../utils/firebase_helper.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Rx<XFile?> profileImage = Rx<XFile?>(null);

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<bool> login() async {
    isLoading.value = true;
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          Get.snackbar("Login Error", "No user found with this email.");
          break;
        case "wrong-password":
          Get.snackbar("Login Error", "Invalid password. Try again.");
          break;
        case "invalid-email":
          Get.snackbar("Login Error", "The email address is not valid.");
          break;
        default:
          Get.snackbar("Login Error", "Something went wrong. Try again.");
      }
      return false;
    } catch (e) {
      Get.snackbar("Login Error", "Unexpected error: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  void signupWithProfile() async {
    isLoading.value = true;
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
    String profileUrl = "";
    if (profileImage.value != null) {
      profileUrl = (await FirebaseHelper().uploadMedia(File(profileImage.value!.path), "profile_images/${email}_avatar")) ?? "";
    }
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        profileImageUrl: profileUrl,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userModel.uid)
          .set(userModel.toJson());

      Get.snackbar("Success", "Account created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      clearSignupForm();
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", "Failed to log out: ${e.toString()}");
    } finally {
      clearLoginForm();
      isLoading.value = false;
    }
  }


  clearLoginForm(){
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  clearSignupForm(){
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

}
