import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createEvent() {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'description': description,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik oluşturuldu')),
        );
        _titleController.clear();
        _descriptionController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlik oluşturma hatası: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Başlık ve açıklama alanları boş bırakılamaz')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Sayfası'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _createEvent,
              child: const Text('Etkinlik Oluştur'),
            ),
          ),
          const SizedBox(height: 16.0),
          const Expanded(child: EventList()),
        ],
      ),
    );
  }
}

class EventList extends StatelessWidget {
  const EventList({Key? key}) : super(key: key);

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
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Henüz etkinlik yok'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            String title = document['title'];
            String description = document['description'];
            return ListTile(
              title: Text(title),
              subtitle: Text(description),
              trailing: ElevatedButton(
                onPressed: () {
                  // Etkinliğe kaydolma işlemleri
                  // Burada gerekli işlemleri gerçekleştirebilirsiniz
                  String eventId =
                      snapshot.data!.docs[index].id; // Etkinlik ID'sini alın
                  String userId =
                      "kullanici_adi"; // Kullanıcının kimliğini alın veya belirleyin

                  // Kaydolma işlemi için Firestore'da ilgili etkinliğe referans oluşturun
                  DocumentReference eventRef = FirebaseFirestore.instance
                      .collection('events')
                      .doc(eventId);

                  // Kullanıcının kaydolduğunu işaretlemek için Firestore'da bir koleksiyon oluşturun veya güncelleyin
                  eventRef.collection('registrations').doc(userId).set({
                    'user_id': userId,
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Etkinliğe kayıt oldunuz')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Etkinliğe kayıt olma hatası: $error')),
                    );
                  });
                },
                child: const Text('Kayıt Ol'),
              ),
            );
          },
        );
      },
    );
  }
}