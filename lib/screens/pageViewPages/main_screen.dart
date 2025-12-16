import 'package:discoveruzb/screens/pageViewPages/category_page/type_category.dart';
import 'package:discoveruzb/screens/pageViewPages/private_gallery/private_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/home_vm.dart';
import '../../view_models/main_vm.dart';
import 'account_pages/account_page.dart';
import 'home/home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainVM = Provider.of<MainViewModel>(context, listen: false);
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);

    // Initialize ViewModels after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainVM.loadUser();
      homeVM.refreshAllData(); // Use the optimized refresh method
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: mainVM.pageController,
        onPageChanged: (index) => mainVM.onPageChanged(index),
        children: [
          HomePage(),
          TypeOfPlaces(),
          MediaPage(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: Consumer<MainViewModel>(
        builder: (context, vm, child) {
          return BottomNavigationBar(
            currentIndex: vm.currentPage,
            onTap: (index) => vm.onTap(index),
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
          );
        },
      ),
    );
  }
}
