import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone_flutter/screens/registration_event_page.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

import 'create_event_page.dart';
import 'event_detail_page.dart';
import 'manage_event_page.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kouyesili,
        title: const Text('Etkinlik Sayfası'),
        actions: [
          IconButton(
            icon: Icon(Icons.manage_accounts),
            onPressed: () {
              //oluşturduğum etkinlikler
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageEventsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              // Kaydolduğum etkinliklerin olduğu sayfaya yönlendirme işlemleri
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyEventsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            const Expanded(child: EventList(userId: 'userId')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
        },
        backgroundColor: secondaryColor,
        child: const Icon(
          Icons.add,
          color: kouyesili,
        ),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final String userId;

  const EventList({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Veri okuma hatası: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Henüz etkinlik yok'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            String title = data['title'];
            String description = data['description'];

            return ListTile(
              title: Text(title),
              subtitle: Text(description),
              trailing: ElevatedButton(
                onPressed: () {
                  // Kaydolma işlemleri...
                  String eventId = document.id; // Etkinlik ID'sini alın
                  String userId = FirebaseAuth.instance.currentUser!.uid; // Kullanıcının kimliğini alın veya belirleyin

                  // Kaydolma işlemi için Firestore'da ilgili etkinliğe referans oluşturun
                  DocumentReference eventRef = FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId);
                  // Kullanıcının kaydolduğunu işaretlemek için Firestore'da bir koleksiyon oluşturun veya güncelleyin
                  eventRef.collection('registrations').doc(userId).set({
                    'user_id': userId,
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Etkinliğe kayıt oldunuz')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Etkinliğe kayıt olma hatası: $error')),
                    );
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(kouyesili),
                ),
                child: const Text('Kayıt Ol'),
              ),
            );
          },
        );
      },
    );
  }
}
