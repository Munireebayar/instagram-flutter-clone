import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/global_variable.dart';
import 'package:instagram_clone_flutter/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar:AppBar(
              backgroundColor: mobileBackgroundColor,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.messenger_outline,
                    color: primaryColor,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final posts = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data();

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(
                        imageUrl: post['photoUrl'].toString(),
                        likes: post['likes'] ?? 0,
                        comments: post['comments'] != null
                            ? List<String>.from(post['comments']!)
                            : [],
                      ),
                    ),
                  );
                },
                child: GridTile(
                  child: Image.network(
                    post['photoUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final int likes;
  final List<String> comments;

  const ImageViewer({
    required this.imageUrl,
    required this.likes,
    required this.comments,
    Key? key,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late int _currentLikes;
  late List<String> _currentComments;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.likes ?? 0;
    _currentComments = List<String>.from(widget.comments ?? []);
  }

  void _likePost() {
    setState(() {
      _currentLikes++;
    });
  }

  void _addComment(String comment) {
    setState(() {
      _currentComments.add(comment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            Positioned(
              top: 16.0,
              right: 16.0,
              child: IconButton(
                onPressed: _likePost,
                icon: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Likes: $_currentLikes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentComments.length,
                      itemBuilder: (context, index) {
                        final comment = _currentComments[index];
                        return ListTile(
                          title: Text(
                            comment,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(color: Colors.white),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white),
                          onSubmitted: _addComment,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Yorum ekleme işlevselliği
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
