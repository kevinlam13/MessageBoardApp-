import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class MessageBoardsPage extends StatelessWidget {
  const MessageBoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Each board has an id (used in Firestore) and a title
    final boards = [
      {'id': 'general', 'title': 'General', 'icon': Icons.forum},
      {'id': 'homework', 'title': 'Homework Help', 'icon': Icons.school},
      {'id': 'announcements', 'title': 'Announcements', 'icon': Icons.campaign},
      {'id': 'random', 'title': 'Random', 'icon': Icons.tag},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Boards'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.email ?? 'User'),
              accountEmail: Text(user?.uid ?? ''),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text('Message Boards'),
              onTap: () {
                Navigator.pop(context); // already here
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: boards.length,
        itemBuilder: (context, index) {
          final board = boards[index];
          return ListTile(
            leading: Icon(board['icon'] as IconData),
            title: Text(board['title'] as String),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    boardId: board['id'] as String,
                    boardTitle: board['title'] as String,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
