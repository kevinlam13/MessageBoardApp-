import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String boardId;
  final String boardTitle;

  const ChatPage({
    super.key,
    required this.boardId,
    required this.boardTitle,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.boardId)
          .collection('messages');

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _sending = true;
    });

    try {
      await _messagesRef.add({
        'text': text,
        'userId': user.uid,
        'userEmail': user.email ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }

    if (mounted) {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardTitle),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesRef
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Be the first to say hi!'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // newest at bottom visually
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final text = data['text'] as String? ?? '';
                    final userEmail = data['userEmail'] as String? ?? 'Unknown';
                    final ts = data['timestamp'] as Timestamp?;
                    final timeString = ts != null
                        ? '${ts.toDate().month}/${ts.toDate().day} '
                        '${ts.toDate().hour.toString().padLeft(2, '0')}:'
                        '${ts.toDate().minute.toString().padLeft(2, '0')}'
                        : '';

                    return ListTile(
                      title: Text(text),
                      subtitle: Text('$userEmail • $timeString'),
                    );
                  },
                );
              },
            ),
          ),

          // Input row
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _sending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _sending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
