import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';

import 'famouses.dart';

/// Tavsiya etilgan joylar — `FamousPlace` bilan bir xil pattern,
/// faqat `recPosts` ro'yxatini ko'rsatadi.
///
/// NOTE: Sprint 13'da `famouses.dart` ichida shared `_PlacesListPage`
/// pattern ishlatilgan, lekin u private. Bu yerda alohida public
/// implementatsiya — `FamousPlace`'ni reuse qilamiz.
class RecommendPlace extends StatelessWidget {
  const RecommendPlace({super.key});

  @override
  Widget build(BuildContext context) {
    // Hozircha backend `recommend` endpoint'i `famous` bilan bir xil
    // natija qaytaradi (TZ §8.3 — kelajakda ML algoritmi).
    // Shu sababli yagona `FamousPlace` sahifasiga redirect qilamiz,
    // sarlavhasini esa o'zgartiramiz.
    return _RecommendList();
  }
}

class _RecommendList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FamousPlace(
      key: ValueKey('recommend-${l10n.recommendPlaces}'),
    );
  }
}
