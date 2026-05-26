import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../components/home_header.dart';
import '../../components/product_box.dart';
import '../../components/title_name.dart';
import '../../../view_models/home_vm.dart';

/// Modern tourism home page.
///
/// Tuzilma:
///   1. Pull-to-refresh wrapper
///   2. Greeting + search header
///   3. "Mashhur joylar" — horizontal hero cards (280px hi)
///   4. "Yangi qo'shilgan" — horizontal cards (240px hi)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await context.read<HomeViewModel>().refreshAllData();
        },
        child: Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox.shrink(),
                  ),
                ),
                const SliverToBoxAdapter(child: HomeHeader()),

                // ─── Mashhur joylar ───
                SliverToBoxAdapter(
                  child: TitleName(
                    headerName: l10n.famousPlaces,
                    subtitle: 'Eng ko\'p sevilgan joylar',
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    isLoading: vm.isLoading,
                    isEmpty: vm.famousPlaces.isEmpty,
                    height: 280,
                    child: ProductBox(
                      height: 280,
                      weight: 240,
                      place: vm.famousPlaces,
                    ),
                  ),
                ),

                // ─── Yangi qo'shilgan ───
                const SliverToBoxAdapter(
                  child: TitleName(
                    headerName: 'Yangi qo\'shilganlar',
                    subtitle: 'Eng so\'nggi joylar',
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    isLoading: vm.isLoading,
                    isEmpty: vm.newAdded.isEmpty,
                    height: 240,
                    child: ProductBox(
                      height: 240,
                      weight: 200,
                      place: vm.newAdded,
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Universal section wrapper — loading skeleton, empty, content.
class _Section extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final double height;
  final Widget child;

  const _Section({
    required this.isLoading,
    required this.isEmpty,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && isEmpty) {
      return _LoadingSkeleton(height: height);
    }
    if (isEmpty) {
      return _EmptyState(height: height);
    }
    return child;
  }
}

class _LoadingSkeleton extends StatelessWidget {
  final double height;
  const _LoadingSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: 240,
          margin: const EdgeInsets.only(right: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final double height;
  const _EmptyState({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_outlined,
                size: 40, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Hozircha joylar yo\'q',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
