import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoData extends StatelessWidget {
  const NoData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200 + 8 + 16 + 60,
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noInfo,
            style: Theme.of(context).textTheme.headline5,
          ),
        ));
  }
}
