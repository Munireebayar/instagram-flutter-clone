import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/add_post_screen.dart';
import 'package:instagram_clone_flutter/screens/event_screen.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/screens/discover.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

import '../screens/users.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          bottomNavigationBar: BottomAppBar(
            notchMargin: 10,
            shape: const CircularNotchedRectangle(),
            child: TabBar(
              controller: _tabController,
              indicatorColor: secondaryColor,
              tabs:const [
                Tab(
                  icon: Icon(
                    Icons.photo_album_outlined,
                    color: kouyesili,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.person_search, color: kouyesili),
                ),
                Tab(
                  icon: Icon(Icons.add, color: kouyesili),
                ),
                Tab(
                  icon: Icon(Icons.person, color: kouyesili),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const FeedScreen(),
              const SearchScreen(),
              const AddPostScreen(),
              ProfileScreen(
                uid: FirebaseAuth.instance.currentUser!.uid,
              ),
            ],
          )),
    );
  }
}
