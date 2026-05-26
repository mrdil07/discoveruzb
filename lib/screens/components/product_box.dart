import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../models/places_model.dart';
import '../pageViewPages/category_page/detailsPlace.dart';

/// Modern tourism hero card (Airbnb meets local heritage).
///
/// Asosiy o'zgarishlar (eski versiyaga nisbatan):
/// - Full-bleed rasm + gradient overlay (Booking/Airbnb pattern)
/// - Rasm ustida nom + manzil oq matnda (yaxshi kontrast)
/// - Top-right'da like count chip
/// - Top-left'da rangli type badge (kategoriya)
/// - Material 3 elevation soyalari (flat o'rniga)
/// - Modern radius (4 → 20)
/// - Slide-in transition (cubic curve)
class ProductBox extends StatelessWidget {
  final double height;
  final double weight;
  final List<Place> place;

  const ProductBox({
    super.key,
    required this.height,
    required this.place,
    this.weight = 240,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = weight.clamp(200.0, 320.0);
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: place.length,
        itemBuilder: (ctx, i) => _PlaceCard(
          place: place[i],
          width: cardWidth,
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final double width;

  const _PlaceCard({required this.place, required this.width});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        place.placeImage.isNotEmpty ? place.placeImage.first : null;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(_createRoute(place)),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Ink(
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.card,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed image
                Positioned.fill(
                  child: imageUrl == null
                      ? Container(color: AppColors.surfaceVariant)
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceVariant,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 32,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                ),

                // Gradient overlay (bottom)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                    ),
                  ),
                ),

                // Top-left: type badge
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: _TypeBadge(type: place.type),
                ),

                // Top-right: like count chip
                if (place.likeCount > 0)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: _Chip(
                      icon: Icons.favorite,
                      iconColor: AppColors.terracotta,
                      label: _formatCount(place.likeCount),
                    ),
                  ),

                // Bottom: title + address
                Positioned(
                  left: AppSpacing.base,
                  right: AppSpacing.base,
                  bottom: AppSpacing.base,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        place.placeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Color(0x80000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              place.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  Route _createRoute(Place place) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => DetailsOfPlace(place: place),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _Chip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _typeMeta(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _typeMeta(String t) {
    switch (t.toLowerCase()) {
      case 'historical':
        return (Icons.museum_outlined, 'Tarixiy');
      case 'mountain':
        return (Icons.terrain_outlined, 'Tog\'lar');
      case 'nature':
        return (Icons.forest_outlined, 'Tabiat');
      case 'museum':
        return (Icons.account_balance_outlined, 'Muzey');
      case 'bazaar':
        return (Icons.storefront_outlined, 'Bozor');
      case 'religious':
        return (Icons.mosque_outlined, 'Diniy');
      case 'park':
        return (Icons.park_outlined, 'Park');
      case 'food':
        return (Icons.restaurant_outlined, 'Oshxona');
      default:
        return (Icons.place_outlined, t);
    }
  }
}
