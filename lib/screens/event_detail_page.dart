import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
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

  void _updateEvent() {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({
        'title': title,
        'description': description,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik güncellendi')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlik güncelleme hatası: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Başlık ve açıklama alanları boş bırakılamaz')),
      );
    }
    setState(() {});
  }

  void _deleteEvent() {
    FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Etkinlik silindi')),
      );
      Navigator.pop(context); // Detay sayfasından çıkış yapılıyor.
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etkinlik silme hatası: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kouyesili,
        title: Text('Etkinlik Detayları'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(widget.eventId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Veri okuma hatası: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Etkinlik bulunamadı'));
                }

                Map<String, dynamic>? eventData =
                    snapshot.data!.data() as Map<String, dynamic>?;

                _titleController.text = eventData?['title'] ?? '';
                _descriptionController.text = eventData?['description'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etkinlik Başlığı:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(eventData?['title'] ?? ''),
                    SizedBox(height: 16.0),
                    Text(
                      'Etkinlik Açıklaması:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(eventData?['description'] ?? ''),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Etkinlik Düzenle'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: _titleController,
                                        decoration: InputDecoration(
                                          labelText: 'Başlık',
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      TextField(
                                        controller: _descriptionController,
                                        decoration: InputDecoration(
                                          labelText: 'Açıklama',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('İptal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: _updateEvent,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                kouyesili),
                                      ),
                                      child: Text('Güncelle'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kouyesili),
                          ),
                          child: Text('Düzenle'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Etkinlik Sil'),
                                  content: Text(
                                      'Bu etkinliği silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('İptal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: _deleteEvent,
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .red), // Silme düğmesi rengi
                                      ),
                                      child: Text('Sil'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red), // Silme düğmesi rengi
                          ),
                          child: Text('Sil'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
