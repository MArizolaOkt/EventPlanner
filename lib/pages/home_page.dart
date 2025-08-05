import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore.dart';
import 'form_event_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirestoreService firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('User belum login'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Event"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getEventsStream(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore Stream Error: ${snapshot.error}');
            return const Center(child: Text("Terjadi Kesalahan"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          if (events.isEmpty) {
            return const Center(child: Text("Belum ada event"));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final Map<String, dynamic>? eventData =
                  event.data() as Map<String, dynamic>?;

              if (eventData == null || eventData['title'] == null) {
                return const SizedBox(); // lewati jika data tidak lengkap
              }

              final title = eventData['title'] ?? 'Tanpa Judul';
              final description = eventData['description'] ?? '';
              final timestamp = eventData['timestamp'] is Timestamp
                  ? eventData['timestamp'] as Timestamp
                  : null;

              return ListTile(
                title: Text(title),
                subtitle: Text(description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timestamp != null ? _formatDate(timestamp) : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Hapus Event"),
                            content: const Text(
                              "Apakah Anda yakin ingin menghapus event ini?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Hapus"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await firestoreService.deleteEvent(event.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Event berhasil dihapus'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigasi ke halaman edit event
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormEventPage(
                        eventId: event.id,
                        existingData: eventData,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add_event',
          ); // arahkan ke form tambah event
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
