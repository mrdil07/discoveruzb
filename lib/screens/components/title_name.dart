import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';

import '../famouses.dart';

class TitleName extends StatelessWidget {
  final String? headerName;
  const TitleName({Key? key, this.headerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            headerName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineSmall // Changed to headlineSmall
                ?.copyWith(color: Colors.tealAccent.shade700),
          ),
          Expanded(child: Container()),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => const FamousPlace()));
            },
            child: Text(
              AppLocalizations.of(context)!.all,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.tealAccent.shade400,
                  fontSize: 20), // Changed to titleMedium
            ),
          ),
        ],
      ),
    );
  }
}
