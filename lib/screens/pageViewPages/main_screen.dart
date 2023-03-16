import 'package:discoveruzb/screens/pageViewPages/category_page/type_category.dart';
import 'package:discoveruzb/screens/pageViewPages/private_gallery/private_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/home_vm.dart';
import '../../view_models/main_vm.dart';
import 'account_pages/account_page.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MainViewModel>(context, listen: false);
    provider.loadUser();
    final provider1 = Provider.of<HomeViewModel>(context, listen: false);
    Future.delayed(Duration.zero).then((value) => {provider1.refresh()});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: provider.pageController,
        onPageChanged: (index) => provider.onPageChanged(index),
        children: [
          HomePage(),
          TypeOfPlaces(),
          MediaPage(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentPage,
        onTap: (index) => provider.onTap(index),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.tealAccent.shade700,
        unselectedItemColor: Colors.black,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.white54),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.slow_motion_video_sharp), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}
