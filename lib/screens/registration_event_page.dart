import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıtlı Etkinlikler'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Kayıtlı etkinlik bulunamadı'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final registrations = userData['registrations'] as List<dynamic>?;
          if (registrations == null || registrations.isEmpty) {
            return Center(child: Text('Kayıtlı etkinlik bulunamadı'));
          }

          return ListView.builder(
            itemCount: registrations.length,
            itemBuilder: (BuildContext context, int index) {
              final eventId = registrations[index];

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return SizedBox(); // Hata durumunda boş bir Widget döndürülür
                  }

                  final eventData =
                      snapshot.data!.data() as Map<String, dynamic>?;
                  final title = eventData?['title'] as String?;
                  final description = eventData?['description'] as String?;

                  if (title != null && description != null) {
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(description),
                    );
                  } else {
                    return SizedBox(); // Geçersiz veriler için boş bir Widget döndürülür
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
