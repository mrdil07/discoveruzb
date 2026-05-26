import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../models/places_model.dart';
import '../../../view_models/account_vm.dart';
import '../category_page/detailsPlace.dart';

/// Modern profile page (Airbnb/Booking pattern).
///
/// Tuzilma:
///   - Hero profile header (avatar + name + email)
///   - Stats row (likes / saved / posts)
///   - Tab segmented control (Liked / Saved)
///   - 2-column grid of place cards
///   - Settings access in app bar
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _showDeleteDialog(BuildContext context, Place place) {
    final accountVM = Provider.of<AccountViewModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(l10n.wantDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await accountVM.deletePost(place);
              if (!context.mounted) return;
              if (accountVM.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(accountVM.error!)),
                );
                accountVM.clearError();
              }
            },
            child: Text(l10n.continu),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AccountViewModel>(context, listen: false);
      vm.fetchUserProfile();
      vm.fetchMyPosts();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AccountViewModel>(
          builder: (context, vm, _) {
            if (vm.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.error ?? '')),
                );
                vm.clearError();
              });
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── App bar ───
                SliverToBoxAdapter(
                  child: _AppBar(),
                ),

                // ─── Hero profile header ───
                SliverToBoxAdapter(
                  child: _ProfileHeader(vm: vm),
                ),

                // ─── Stats row ───
                SliverToBoxAdapter(
                  child: _StatsRow(vm: vm),
                ),

                // ─── Tab segmented ───
                SliverToBoxAdapter(
                  child: _TabSegmented(vm: vm),
                ),

                // ─── Grid of places ───
                if (vm.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (vm.places.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(label: l10n.noInfo),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final place = vm.places[i];
                          return _PlaceGridCard(
                            place: place,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailsOfPlace(place: place),
                              ),
                            ),
                            onLongPress: vm.isAdmin
                                ? () => _showDeleteDialog(context, place)
                                : null,
                          );
                        },
                        childCount: vm.places.length,
                      ),
                    ),
                  ),

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

// ─────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            l10n.profile,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Profile header — avatar + name + email
// ─────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final AccountViewModel vm;
  const _ProfileHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    final initial = vm.fullName.isNotEmpty
        ? vm.fullName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.md,
            ),
            clipBehavior: Clip.antiAlias,
            child: vm.imgUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: vm.imgUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _avatarFallback(initial),
                  )
                : _avatarFallback(initial),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.fullName.isEmpty ? '...' : vm.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  vm.email.isNotEmpty
                      ? vm.email
                      : (vm.phone ?? ''),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (vm.isAdmin) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String initial) {
    return Container(
      color: AppColors.primarySurface,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final AccountViewModel vm;
  const _StatsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    final count = vm.places.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.favorite_rounded,
              iconColor: AppColors.terracotta,
              bg: AppColors.terracottaSurface,
              value: vm.isSelected[0] ? '$count' : '—',
              label: 'Layklar',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              icon: Icons.bookmark_rounded,
              iconColor: AppColors.accent,
              bg: AppColors.accentSurface,
              value: vm.isSelected[1] ? '$count' : '—',
              label: 'Saqlangan',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              icon: Icons.explore_rounded,
              iconColor: AppColors.primary,
              bg: AppColors.primarySurface,
              value: '${count > 0 ? count : 0}',
              label: 'Joylar',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Tab segmented control (Liked / Saved)
// ─────────────────────────────────────────────────────────────────

class _TabSegmented extends StatelessWidget {
  final AccountViewModel vm;
  const _TabSegmented({required this.vm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: l10n.myLiked,
            icon: Icons.favorite_rounded,
            isActive: vm.isSelected[0],
            onTap: () {
              vm.toggleSelected(0);
              vm.fetchMyPosts();
            },
          ),
          _SegmentButton(
            label: l10n.mySaved,
            icon: Icons.bookmark_rounded,
            isActive: vm.isSelected[1],
            onTap: () {
              vm.toggleSelected(1);
              vm.fetchMySavedPosts();
            },
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isActive ? AppShadows.sm : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Place card (grid)
// ─────────────────────────────────────────────────────────────────

class _PlaceGridCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PlaceGridCard({
    required this.place,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final img = place.placeImage.isNotEmpty ? place.placeImage.first : null;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (img != null)
                CachedNetworkImage(
                  imageUrl: img,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceVariant),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surfaceVariant),
                )
              else
                Container(color: AppColors.surfaceVariant),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Text(
                  place.placeName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: Color(0x80000000),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_off_outlined,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
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
