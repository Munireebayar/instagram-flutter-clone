import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FullScreenImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageSlider({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  _FullScreenImageSliderState createState() => _FullScreenImageSliderState();
}

class _FullScreenImageSliderState extends State<FullScreenImageSlider> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              initialPage: widget.initialIndex,
              enableInfiniteScroll: false,
              onPageChanged: (index, _) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: widget.imageUrls.map((imageUrl) {
              return Container(
                color: Colors.black,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}