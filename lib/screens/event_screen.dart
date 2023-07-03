import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Event {
  final String title;
  final String description;

  Event({
    required this.title,
    required this.description,
  });
}

class EventPagee extends StatefulWidget {
  const EventPagee({Key? key}) : super(key: key);
  @override
  State<EventPagee> createState() => _EventPageeState();
}

class _EventPageeState extends State<EventPagee> {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  Future<List<Event>> getEvents() async {
    QuerySnapshot querySnapshot = await eventsCollection.get();
    List<Event> events = [];

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      String title = documentSnapshot['title'];
      String description = documentSnapshot['description'];

      events.add(Event(
        title: title,
        description: description,
      ));
    }

    return events;
  }

    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etkinlik Sayfası'),
      ),
      body: FutureBuilder<List<Event>>(
        future: getEvents(),
        builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Veri okuma hatası: ${snapshot.error}'));
          }

          List<Event> events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(child: Text('Henüz etkinlik yok'));
          }

          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Colors.grey,
                height: 1,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              final event = events[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                ),
                title: Text(event.title),
                subtitle: Text(event.description),
              );
            },
          );
        },
      ),
    );
  }
}
