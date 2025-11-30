import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chat_screen.dart'; // Chat ekranını çağırıyoruz

void main() async {
  // Flutter motoru ile native tarafın bağını kurar.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlatır. Bu olmazsa uygulama çöker.
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-time Comment List',
      debugShowCheckedModeBanner: false, // Debug yazısını kaldırır
      theme: ThemeData(
        // Ödevdeki gibi morumsu bir tema
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(), // Doğrudan sohbet ekranını aç
    );
  }
}