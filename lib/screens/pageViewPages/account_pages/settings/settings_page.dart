import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/edit_profile_screen.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/list_tile_widget.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/update_image.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../service/auth_service.dart';
import '../../../../service/pref_service.dart';
import '../../../../view_models/account_vm.dart';
import '../../../introPages/login_with_phone.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  // A separate function for showing the logout confirmation dialog
  void _showLogOutLabel(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.exit,
              style: Theme.of(context).textTheme.titleLarge, // Updated style
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium // Updated style
                        ?.copyWith(color: Colors.green, fontSize: 20),
                  )),
              TextButton(
                  onPressed: () async {
                    AuthService.signOutUser(context);
                    await Prefs.removePhone();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const LoginWithPhone()),
                        (route) => false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.continu,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium // Updated style
                        ?.copyWith(color: Colors.red, fontSize: 20),
                  )),
            ],
          );
        });
  }

  void _dialogLang(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Tilni tanlang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Uzbek')),
                  TextButton(onPressed: () {}, child: const Text('Russian')),
                  TextButton(onPressed: () {}, child: const Text('English'))
                ],
              ),
            ));
  }

  void _dialogCurrency(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Valyutani tanlang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {}, child: const Text('So\'m')),
                  TextButton(onPressed: () {}, child: const Text('Dollar')),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ViewModel methods after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountVM = Provider.of<AccountViewModel>(context, listen: false);
      accountVM.fetchUserProfile();
      accountVM.fetchMyPosts(); // Assuming this is needed on settings page too
    });

    final accountVM = Provider.of<AccountViewModel>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge, // Updated style
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            updateImage(context), // This widget might need refactoring too
            const SizedBox(height: 20),
            Text(accountVM.fullName,
                style: Theme.of(context).textTheme.headlineMedium), // Updated style
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                editProfileScreen(context);
              },
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, // Changed to foregroundColor
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Profil Tahrirlash',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium // Updated style
                        ?.copyWith(color: Colors.white, fontSize: 19),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 25,
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 15.0, right: 15, top: 30),
              child: Text(
                "Qo'shimcha imkoniyatlar",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium // Updated style
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  InkWell(
                      onTap: () {
                        _dialogLang(context);
                      },
                      child: ListTile1(
                        title: 'Til',
                        titleIcon: Icons.language_outlined,
                        suffixText: 'English',
                        icon: Icons.arrow_forward_ios_outlined,
                      )),
                  InkWell(
                      onTap: () {
                        _dialogCurrency(context);
                      },
                      child: ListTile1(
                        title: 'Valyuta',
                        titleIcon: Icons.currency_exchange_rounded,
                        suffixText: 'Dollar',
                        icon: Icons.arrow_forward_ios_outlined,
                      )),
                   ListTile1(
                    title: 'Orqa fon',
                    titleIcon: Icons.light_mode,
                    suffixText: 'Light',
                  ),
                ],
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ListTile(
                  title: Text(
                    'Logout',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium // Updated style
                        ?.copyWith(color: Colors.black54),
                  ),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    _showLogOutLabel(context);
                  },
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
