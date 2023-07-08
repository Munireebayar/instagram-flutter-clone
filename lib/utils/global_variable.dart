import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/add_post_screen.dart';
import 'package:instagram_clone_flutter/screens/event_screen_2.dart';
import 'package:instagram_clone_flutter/screens/feed_screen.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/screens/search_screen.dart';
import '../screens/create_event_page.dart';
import '../screens/story_page.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const EventPage(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
