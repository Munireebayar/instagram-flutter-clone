import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'event_screen.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _saatController;
  late TextEditingController _konumController;
  late TextEditingController _tarihController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tarihController = TextEditingController();
    _saatController = TextEditingController();
    _konumController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tarihController.dispose();
    _saatController.dispose();
    _konumController.dispose();
    super.dispose();
  }

  void _createEvent() {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String tarih = _tarihController.text;
    String saat = _saatController.text;
    String konum = _konumController.text;

    if (title.isNotEmpty && description.isNotEmpty && tarih.isNotEmpty && saat.isNotEmpty && konum.isNotEmpty) {
      FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'description': description,
        'tarih': tarih,
        'saat': saat,
        'konum': konum,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik oluşturuldu')),
        );
        _titleController.clear();
        _descriptionController.clear();
        _tarihController.clear();
        _saatController.clear();
        _konumController.clear();

        // Yeni etkinlik oluşturulduktan sonra etkinlik sayfasına yönlendirme
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EventPage()),
          (route) => false,
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlik oluşturma hatası: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bütün alanlar doldurulmalıdır!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Etkinlik Oluştur'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                controller: _saatController,
                decoration: const InputDecoration(
                  labelText: 'Saat',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _konumController,
                decoration: const InputDecoration(
                  labelText: 'Konum',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _tarihController,
                decoration: const InputDecoration(
                  labelText: 'Tarih',
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
          ],
        ),
      ),
    );
  }
}
