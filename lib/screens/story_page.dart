import 'package:flutter/material.dart';

class FullScreenStoryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenStoryPage({Key? key, 
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenStoryPageState createState() => _FullScreenStoryPageState();
}

class _FullScreenStoryPageState extends State<FullScreenStoryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        onHorizontalDragEnd: (details) {
          // Sağa veya sola kaydırma hareketi algılandığında
          if (details.primaryVelocity! < 0) {
            // Sola kaydırma hareketi
            if (_currentIndex < widget.imageUrls.length - 1) {
              setState(() {
                _currentIndex++;
              });
              _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          } else if (details.primaryVelocity! > 0) {
            // Sağa kaydırma hareketi
            if (_currentIndex > 0) {
              setState(() {
                _currentIndex--;
              });
              _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            String imageUrl = widget.imageUrls[index];
            return Center(
              child: Hero(
                tag: imageUrl,
                child: Image.network(imageUrl),
              ),
            );
          },
        ),
      ),
    );
  }
}
