import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'auth_pages.dart';
import 'message_boards_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MessageBoardApp());
}

class MessageBoardApp extends StatelessWidget {
  const MessageBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Board App',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

/// Decides whether to show Login/Register or the Message Boards
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still initializing Firebase / auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // User NOT logged in
        if (!snapshot.hasData) {
          return const AuthPage();
        }

        // User is logged in → go to message boards
        return const MessageBoardsPage();
      },
    );
  }
}

/// Simple splash while Firebase initializes
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "MessageBoardApp",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
