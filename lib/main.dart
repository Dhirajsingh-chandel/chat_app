import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:untitled3/views/auth/login_page.dart';
import 'package:untitled3/views/auth/signup_page.dart';
import 'package:untitled3/views/chat/chat_list_page.dart';

import 'controllers/auth_controller.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with custom options
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBhq0xmG1t4O3dneQx2v7PxlSR3krMVBfU',
      appId: '1:701301178975:android:baa664906401000ee1d1ea',
      messagingSenderId: '701301178975',
      projectId: 'chat-app-1865e',
      storageBucket: 'chat-app-1865e.firebasestorage.app',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/signup', page: () => SignupPage()),
        GetPage(name: '/chatList', page: () =>  ChatListPage()),
      ],
      home: LoginPage(),  // Your login page
    );
  }
}
