import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var userModel = Rxn<UserModel>();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> fetchUserDetails(String userId) async {
    try {
      isLoading.value = true;
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        userModel.value = UserModel.fromJson(doc.data()!);
      } else {
        userModel.value = null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      userModel.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
