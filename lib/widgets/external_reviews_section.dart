import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/external_review.dart';
import '../models/places_model.dart';
import '../view_models/external_reviews_vm.dart';

/// Joy tafsilotlari ekranida tashqi xaritalardan kommentlarni
/// ko'rsatadigan widget — Google, Yandex, 2GIS tabbar bilan.
///
/// `Place.googlePlaceId` / `yandexPlaceId` / `gisPlaceId` hech qaysisi
/// to'ldirilmagan bo'lsa, widget chizilmaydi (bo'sh `SizedBox` qaytadi).
class ExternalReviewsSection extends StatefulWidget {
  final Place place;
  const ExternalReviewsSection({Key? key, required this.place})
      : super(key: key);

  @override
  State<ExternalReviewsSection> createState() => _ExternalReviewsSectionState();
}

class _ExternalReviewsSectionState extends State<ExternalReviewsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.place.id;
      if (id != null && widget.place.hasExternalReviews) {
        context.read<ExternalReviewsVM>().load(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!widget.place.hasExternalReviews) {
      return const SizedBox.shrink();
    }
    return Consumer<ExternalReviewsVM>(
      builder: (context, vm, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, l10n, vm),
              const SizedBox(height: 12),
              _buildTabBar(context, vm),
              const SizedBox(height: 12),
              _buildBody(context, l10n, vm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ExternalReviewsVM vm,
  ) {
    return Row(
      children: [
        Icon(Icons.public, color: Colors.teal.shade600, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.externalReviewsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (vm.isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            onPressed: () {
              final id = widget.place.id;
              if (id != null) vm.load(id, force: true);
            },
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Yangilash',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, ExternalReviewsVM vm) {
    final summaries = vm.summariesNonEmpty;
    if (summaries.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: summaries.map((s) {
          final isActive = s.source == vm.selectedSource;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => vm.selectSource(s.source),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.teal.shade600
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? Colors.teal.shade600
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SourceIcon(source: s.source, active: isActive),
                    const SizedBox(width: 6),
                    Text(
                      _sourceLabel(s.source),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (s.averageRating != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.star,
                        size: 13,
                        color: isActive
                            ? Colors.amber.shade300
                            : Colors.amber.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        s.averageRating!.toStringAsFixed(1),
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ExternalReviewsVM vm,
  ) {
    if (vm.error != null) {
      return _ErrorView(message: vm.error!);
    }
    if (vm.isLoading && vm.response == null) {
      return const _LoadingView();
    }
    final summary = vm.summaryForSelected;
    if (summary?.error != null && (summary?.error?.isNotEmpty ?? false)) {
      return _ProviderErrorView(
        source: vm.selectedSource,
        message: summary!.error!,
      );
    }
    final reviews = vm.reviewsForSelected;
    if (reviews.isEmpty) {
      return _EmptyView(label: l10n.externalReviewsEmpty);
    }
    return Column(
      children: [
        if (summary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.externalReviewsCount(summary.reviewCount.toString()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
        ...reviews.take(10).map((r) => _ReviewCard(review: r)),
        if (reviews.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.externalReviewsMore((reviews.length - 10).toString()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }

  String _sourceLabel(String source) {
    switch (source) {
      case 'google':
        return 'Google Maps';
      case 'yandex':
        return 'Yandex Maps';
      case '2gis':
        return '2GIS';
      default:
        return source;
    }
  }
}

class _SourceIcon extends StatelessWidget {
  final String source;
  final bool active;
  const _SourceIcon({required this.source, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : Colors.black87;
    final icon = switch (source) {
      'google' => Icons.location_on_rounded,
      'yandex' => Icons.travel_explore,
      '2gis' => Icons.map_outlined,
      _ => Icons.public,
    };
    return Icon(icon, size: 14, color: color);
  }
}

class _ReviewCard extends StatelessWidget {
  final ExternalReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final initials = review.authorName.isNotEmpty
        ? review.authorName.substring(0, 1).toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                imageUrl: review.authorAvatarUrl,
                fallbackInitial: initials,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (review.postedAt != null)
                      Text(
                        _formatDate(review.postedAtDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              if (review.rating != null) _RatingChip(rating: review.rating!),
            ],
          ),
          if (review.text != null && review.text!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.text!,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyn',
      'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
    ];
    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackInitial;
  const _Avatar({required this.imageUrl, required this.fallbackInitial});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initial(),
          errorWidget: (_, __, ___) => _initial(),
        ),
      );
    }
    return _initial();
  }

  Widget _initial() => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          fallbackInitial,
          style: TextStyle(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

class _RatingChip extends StatelessWidget {
  final double rating;
  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 13, color: Colors.amber.shade800),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.amber.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String label;
  const _EmptyView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.comment_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderErrorView extends StatelessWidget {
  final String source;
  final String message;
  const _ProviderErrorView({required this.source, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 8),
              Text(
                source.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
