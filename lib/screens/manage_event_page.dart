import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

import 'event_detail_page.dart';

class ManageEventsPage extends StatelessWidget {
  const ManageEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kouyesili,
        title: const Text('Etkinlikleri Yönet'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Veri okuma hatası: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz etkinlik yok'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              String title = document['title'];
              String description = document['description'];
              String tarih = document['tarih'];
              String saat = document['saat'];
              String konum = document['konum'];
              String eventId = document.id;
              return ListTile(
                title: Text(title),
                subtitle: Text(description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailPage(eventId: eventId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
