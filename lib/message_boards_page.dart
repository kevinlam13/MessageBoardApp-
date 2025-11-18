import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageBoardsPage extends StatelessWidget {
  const MessageBoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Hard-coded message boards for now
    final boards = [
      {'title': 'General', 'icon': Icons.forum},
      {'title': 'Homework Help', 'icon': Icons.school},
      {'title': 'Announcements', 'icon': Icons.campaign},
      {'title': 'Random', 'icon': Icons.tag},
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
                // TODO: navigate to Profile page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // TODO: navigate to Settings page
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                // AuthGate in main.dart will send user back to AuthPage
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
              // TODO: later this will open a ChatPage for that board
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped board: ${board['title']} (chat coming later)',
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
