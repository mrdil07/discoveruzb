import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../models/places_model.dart';
import '../../view_models/home_vm.dart';

/// Modern tourism header — greeting + avatar + search bar.
///
/// Dizayn falsafasi:
/// - Sabohlik salom + ismi (warm, personal)
/// - Tag-line: "O'zbekistonni kashf eting"
/// - Pill-shape search bar Booking/Airbnb uslubida
/// - Avatar yumshoq soya bilan, ring yo'q
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.isGuest
                              ? l10n.guestUser
                              : (vm.fullName.isEmpty ? '...' : vm.fullName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  _Avatar(imageUrl: vm.imgUrl),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SearchBar(places: vm.famousPlaces),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.appTagline,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Xayrli tong 👋';
    if (hour < 17) return 'Xayrli kun 👋';
    if (hour < 21) return 'Xayrli kech 👋';
    return 'Xayrli tun 🌙';
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => _fallback(),
              errorWidget: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() => const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 28,
      );
}

/// Pill-shape search bar (Airbnb pattern).
class _SearchBar extends StatelessWidget {
  final List<Place> places;
  const _SearchBar({required this.places});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.full),
        onTap: () {
          // Future: open dedicated SearchPage
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.surface,
            builder: (_) => _SearchSheet(places: places),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: AppShadows.sm,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.searchPlaceholder,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  final List<Place> places;
  const _SearchSheet({required this.places});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.places.take(10).toList()
        : widget.places
            .where((p) =>
                p.placeName.toLowerCase().contains(_query.toLowerCase()) ||
                p.address.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.base,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Joy nomi yoki manzilni qidiring...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: AppColors.textTertiary),
                            SizedBox(height: 12),
                            Text(
                              'Hech narsa topilmadi',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _SearchResultTile(place: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SearchResultTile extends StatelessWidget {
  final Place place;
  const _SearchResultTile({required this.place});

  @override
  Widget build(BuildContext context) {
    final img = place.placeImage.isNotEmpty ? place.placeImage.first : null;
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 44,
          height: 44,
          child: img == null
              ? Container(color: AppColors.surfaceVariant)
              : CachedNetworkImage(imageUrl: img, fit: BoxFit.cover),
        ),
      ),
      title: Text(
        place.placeName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        place.address,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsOfPlace(place: place),
          ),
        );
      },
    );
  }
}

/// Legacy export — boshqa joylar (account_vm) ishlatishi mumkin.
class CircularProfileImg extends StatelessWidget {
  final double? height;
  final double? width;
  final String imageUrl;
  const CircularProfileImg({
    super.key,
    this.height = 80,
    this.width = 80,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              height: height,
              width: width,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Image.asset('assets/images/discoveruzb.png'),
              errorWidget: (_, __, ___) => Image.asset(
                'assets/images/discoveruzb.png',
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/discoveruzb.png',
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
    );
  }
}
