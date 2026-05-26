import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discoveruzb/screens/comment_page.dart';
import 'package:discoveruzb/view_models/details_vm.dart';
import 'package:discoveruzb/view_models/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../models/places_model.dart';
import '../../../service/utils.dart';
import '../../../widgets/external_reviews_section.dart';
import '../../../widgets/hero_image.dart';

/// Modern full-screen tourism details (Airbnb / Hopper style).
///
/// Tuzilma:
///   - SliverAppBar with hero image carousel
///   - Bottom content card with rounded top corners
///   - Quick action chips (like, save, comment)
///   - Info pills (category, price, likes, contact)
///   - Description with "Manba" footnote
///   - External reviews section
///   - Floating "Xaritada ko'rsatish" CTA
class DetailsOfPlace extends StatefulWidget {
  final Place place;

  const DetailsOfPlace({required this.place, super.key});

  @override
  State<DetailsOfPlace> createState() => _DetailsOfPlaceState();
}

class _DetailsOfPlaceState extends State<DetailsOfPlace> {
  int _currentImage = 0;

  Place get place => widget.place;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailsVM>().fetchWeather(place.lat, place.lon);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(child: _buildContentCard(context, l10n)),
              ],
            ),
            _buildFloatingTopBar(context),
            _buildFloatingCTA(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final heroHeight = screenWidth * 0.95;

    return SliverAppBar(
      expandedHeight: heroHeight,
      automaticallyImplyLeading: false,
      pinned: false,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              itemCount: place.placeImage.length,
              options: CarouselOptions(
                height: heroHeight,
                viewportFraction: 1,
                autoPlay: place.placeImage.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (i, _) =>
                    setState(() => _currentImage = i),
              ),
              itemBuilder: (_, i, __) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HeroNetImage(
                        images: place.placeImage,
                        initialIndex: i,
                      ),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: place.placeImage[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceVariant),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x66000000),
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),
            ),
            if (place.placeImage.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    place.placeImage.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImage == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentImage == i
                            ? Colors.white
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              _CircleButton(
                icon: Icons.qr_code_scanner_rounded,
                onTap: () => Utils.fireToast('QR code yaqinda'),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _WeatherChip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, AppLocalizations l10n) {
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);

    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.placeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActionRow(place: place, homeVM: homeVM, l10n: l10n),
            const SizedBox(height: AppSpacing.xl),
            _InfoPills(place: place, l10n: l10n),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fullInfo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    place.placeInfo,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.05,
                    ),
                  ),
                  if (place.source.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.base),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bookmark_border_rounded,
                              size: 16, color: AppColors.accentDark),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Manba: ${place.source}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ExternalReviewsSection(place: place),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCTA(BuildContext context) {
    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.base),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: () => _showMapsBottomSheet(context),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.base,
                  horizontal: AppSpacing.lg,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_rounded,
                        color: Colors.white, size: 22),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Xaritada ko\'rsatish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMapsBottomSheet(BuildContext context) async {
    final coords = Coords(place.lat, place.lon);
    final availableMaps = await MapLauncher.installedMaps;
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Xarita ilovasi tanlang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (availableMaps.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Xarita ilovasi topilmadi',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...availableMaps.map(
                  (m) => ListTile(
                    leading: SvgPicture.asset(m.icon, width: 36, height: 36),
                    title: Text(
                      m.mapName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    onTap: () {
                      m.showMarker(coords: coords, title: place.placeName);
                      Navigator.pop(ctx);
                    },
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
// Helpers
// ─────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip();

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsVM>(
      builder: (context, vm, _) {
        final temp = vm.temp;
        if (temp == null) {
          return _CircleButton(
            icon: Icons.cloud_outlined,
            onTap: () {},
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                (temp > 0) ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded,
                size: 14,
                color: (temp > 0) ? AppColors.accent : AppColors.info,
              ),
              const SizedBox(width: 4),
              Text(
                '${temp.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  final Place place;
  final HomeViewModel homeVM;
  final AppLocalizations l10n;

  const _ActionRow({
    required this.place,
    required this.homeVM,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final detailsVM = Provider.of<DetailsVM>(context, listen: true);
    final isLiked = place.liked.contains(homeVM.userId);
    final isSaved = place.saved.contains(homeVM.userId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: '${place.likeCount}',
              color: isLiked ? AppColors.terracotta : AppColors.textPrimary,
              onTap: () => detailsVM.toggleLikePost(place, homeVM.userId),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ActionButton(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              label: 'Saqlash',
              color: isSaved ? AppColors.accent : AppColors.textPrimary,
              onTap: () async {
                await detailsVM.toggleSavePost(place, homeVM.userId);
                if (!context.mounted) return;
                Utils.fireToast(isSaved ? l10n.removeSaved : l10n.addedSaved);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Izoh',
              color: AppColors.textPrimary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommentPage(place: place),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPills extends StatelessWidget {
  final Place place;
  final AppLocalizations l10n;
  const _InfoPills({required this.place, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _Pill(
            icon: Icons.category_outlined,
            iconColor: AppColors.primary,
            bg: AppColors.primarySurface,
            label: 'Tur',
            value: place.type,
          ),
          if (place.price.isNotEmpty)
            _Pill(
              icon: Icons.local_offer_outlined,
              iconColor: AppColors.accent,
              bg: AppColors.accentSurface,
              label: 'Narx',
              value: place.price,
            ),
          _Pill(
            icon: Icons.favorite_outline_rounded,
            iconColor: AppColors.terracotta,
            bg: AppColors.terracottaSurface,
            label: l10n.likedBy,
            value: '${place.likeCount}',
          ),
          if (place.phoneNumber.isNotEmpty)
            _Pill(
              icon: Icons.phone_outlined,
              iconColor: AppColors.info,
              bg: const Color(0xFFE0F0FF),
              label: 'Aloqa',
              value: place.phoneNumber.first,
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final String label;
  final String value;

  const _Pill({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
