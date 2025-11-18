import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class MessageBoardsPage extends StatelessWidget {
  MessageBoardsPage({super.key});

  // Each board has an id (used in Firestore), a title, an icon, and gradient colors
  final List<Map<String, dynamic>> boards = [
    {
      'id': 'general',
      'title': 'General',
      'icon': Icons.forum,
      'colors': [const Color(0xFFFF6F61), const Color(0xFFFF8C5A)],
    },
    {
      'id': 'homework',
      'title': 'Homework Help',
      'icon': Icons.school,
      'colors': [const Color(0xFF4A90E2), const Color(0xFF6EB6FF)],
    },
    {
      'id': 'announcements',
      'title': 'Announcements',
      'icon': Icons.campaign,
      'colors': [const Color(0xFFFFC851), const Color(0xFFFFA726)],
    },
    {
      'id': 'random',
      'title': 'Random',
      'icon': Icons.auto_awesome,
      'colors': [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Select A Room",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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
                Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: boards.length,
          itemBuilder: (context, index) {
            final board = boards[index];
            return _buildRoomCard(
              context,
              board['id'] as String,
              board['title'] as String,
              board['icon'] as IconData,
              board['colors'] as List<Color>,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomCard(
      BuildContext context,
      String boardId,
      String title,
      IconData icon,
      List<Color> colors,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              boardId: boardId,
              boardTitle: title,
            ),
          ),
        );
      },
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Large faded icon in the background
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 140,
                color: Colors.white.withOpacity(0.15),
              ),
            ),

            // Foreground icon + title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
