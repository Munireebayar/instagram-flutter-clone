import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class KullaniciEtkinlikleri extends StatefulWidget {
  final String kullaniciId;

  KullaniciEtkinlikleri({required this.kullaniciId});

  @override
  _KullaniciEtkinlikleriState createState() => _KullaniciEtkinlikleriState();
}

class _KullaniciEtkinlikleriState extends State<KullaniciEtkinlikleri> {
  final databaseReference = FirebaseDatabase.instance.reference();

  List<String> etkinlikler = [];

  @override
  void initState() {
    super.initState();
    getKullaniciEtkinlikleri();
  }

  void getKullaniciEtkinlikleri() {
  databaseReference
    .child('kullanicilar')
    .orderByChild('uid')
    .equalTo(widget.kullaniciId)
    .once()
    .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic>? kullanici = snapshot.value as Map<dynamic, dynamic>?;
      if (kullanici != null) {
        Map<dynamic, dynamic> etkinliklerMap = kullanici.values.first['etkinlikler'];
        if (etkinliklerMap != null) {
          etkinliklerMap.forEach((key, value) {
            setState(() {
              etkinlikler.add(value.toString());
            });
          });
        }
      }
    } as FutureOr Function(DatabaseEvent value));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Etkinlikleri'),
      ),
      body: ListView.builder(
        itemCount: etkinlikler.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(etkinlikler[index]),
          );
        },
      ),
    );
  }
}
