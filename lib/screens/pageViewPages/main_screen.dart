import 'package:discoveruzb/screens/pageViewPages/category_page/type_category.dart';
import 'package:discoveruzb/screens/pageViewPages/private_gallery/private_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../view_models/home_vm.dart';
import '../../view_models/main_vm.dart';
import 'account_pages/account_page.dart';
import 'home/home_page.dart';

/// Main app shell with modern bottom navigation.
///
/// Tab'lar:
///   0. Discover (home) — turistik joylar
///   1. Explore — kategoriya bo'yicha qidiruv
///   2. Trips (gallery) — shaxsiy galereya
///   3. Profile — foydalanuvchi
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainVM = Provider.of<MainViewModel>(context, listen: false);
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainVM.loadUser();
      homeVM.refreshAllData();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      // IndexedStack — sahifa holatlarini saqlaydi, oraliq sahifalarsiz
      // bir zumda almashtiradi (native iOS/Android tab pattern).
      body: Consumer<MainViewModel>(
        builder: (context, vm, _) => IndexedStack(
          index: vm.currentPage,
          children: const [
            HomePage(),
            TypeOfPlaces(),
            MediaPage(),
            AccountPage(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<MainViewModel>(
        builder: (context, vm, _) {
          return _ModernBottomNav(
            currentIndex: vm.currentPage,
            onTap: vm.onTap,
          );
        },
      ),
    );
  }
}

/// Modern floating bottom navigation (iOS-style).
class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.explore_outlined, Icons.explore_rounded, 'Kashf et'),
    _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Qidiruv'),
    _NavItem(Icons.photo_library_outlined, Icons.photo_library_rounded, 'Galereya'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        // Fixed height — sahifalararo o'tishda o'zgarmaydi
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(_items.length, (i) {
              final isActive = currentIndex == i;
              return Expanded(
                child: _NavButton(
                  item: _items[i],
                  isActive: isActive,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData inactive;
  final IconData active;
  final String label;
  const _NavItem(this.inactive, this.active, this.label);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.active : item.inactive,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.1,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
