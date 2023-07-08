import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  List<String> postImageUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kouyesili,
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration: const InputDecoration(labelText: 'Search for a user...'),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
          ),
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as QuerySnapshot).docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as QuerySnapshot).docs[index]['photoUrl'],
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          (snapshot.data! as QuerySnapshot).docs[index]['username'],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').orderBy('datePublished').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final posts = (snapshot.data! as QuerySnapshot).docs;
                postImageUrls = posts.map((post) => post['postUrl'].toString()).toList();

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final imageUrl = posts[index]['postUrl'];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImageViewer(
                              imageUrls: postImageUrls,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        imageUrl.toString(),
                        fit: BoxFit.cover,
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
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewer({required this.imageUrls, required this.initialIndex, Key? key}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPageIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            return PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = widget.imageUrls[index];
                double currentPage = _currentPageIndex.toDouble();
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = _pageController.page! - currentPage;
                  value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                }
                return Center(
                  child: SizedBox(
                    height: Curves.easeOut.transform(value) * MediaQuery.of(context).size.height,
                    child: child,
                  ),
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
            );
          },
          child: Hero(
            tag: widget.imageUrls[_currentPageIndex],
            child: Image.network(
              widget.imageUrls[_currentPageIndex],
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ),
    );
  }
}