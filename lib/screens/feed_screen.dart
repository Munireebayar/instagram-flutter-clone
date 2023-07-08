import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_flutter/screens/story_page.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final CollectionReference<Map<String, dynamic>> _storiesCollection =
      FirebaseFirestore.instance.collection('stories');

  final TextEditingController _captionController = TextEditingController();

  late File _selectedImage;

  Future<void> _uploadStory() async {
    const String userId =
        'uid'; // Burada kullanıcının kimliğini almanız gerekmektedir

    // Firebase Storage'a story resmini yükleme
    final String storagePath =
        'stories/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference storageRef =
        FirebaseStorage.instance.ref().child(storagePath);
    final UploadTask uploadTask = storageRef.putFile(_selectedImage);
    final TaskSnapshot uploadSnapshot = await uploadTask;

    // Yükleme başarılıysa story bilgilerini Firestore'a kaydetme
    if (uploadSnapshot.state == TaskState.success) {
      final String downloadUrl = await uploadSnapshot.ref.getDownloadURL();

      await _storiesCollection.add({
        'userId': userId,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Yükleme tamamlandıktan sonra resim ve yazı alanını temizleme
      _captionController.clear();
      _selectedImage = File(''); // Seçili resmi sıfırlama
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildStorySection(),
          Expanded(child: _buildFeedSection()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUploadDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStorySection() {
  return Container(
    padding: EdgeInsets.only(top: 35, bottom: 10),
    height: 150,
    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _storiesCollection
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final stories = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stories.map((story) {
              String userId = story['userId'];
              String imageUrl = story['imageUrl'];

              return GestureDetector(
                onTap: () {
                    List<String> imageUrls = stories.map<String>((story) => story['imageUrl'] as String).toList();
                    int initialIndex = stories.indexOf(story);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenStoryPage(
                          imageUrls: imageUrls,
                          initialIndex: initialIndex,
                        ),
                      ),
                    );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    ),
  );
}


  Widget _buildFeedSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (ctx, index) => Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 200 : 0,
              vertical: MediaQuery.of(context).size.width > 600 ? 15 : 0,
            ),
            child: PostCard(
              snap: posts[index].data(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Story Paylaş'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImageFromGallery(); // Galeriden resim seçme işlemi
              },
              child: Text('Resim Seç'),
            ),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(labelText: 'Açıklama'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _uploadStory();
              Navigator.of(context).pop();
            },
            child: Text('Paylaş'),
          ),
        ],
      );
    },
  );
}

void _pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.getImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    _selectedImage = File(pickedFile.path);
  }
}
}
