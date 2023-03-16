import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/edit_profile_screen.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/list_tile_widget.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/update_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../service/auth_service.dart';
import '../../../../service/pref_service.dart';
import '../../../../view_models/account_vm.dart';
import '../../../introPages/login_with_phone.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AccountViewModel>(context, listen: false);
    Future.delayed(Duration.zero).then((value) => {
          provider.apiloadUser(),
          provider.apiLoadMyPosts(),
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountViewModel>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            updateImage(context),
            const SizedBox(height: 20),
            Text(provider.fullName,
                style: Theme.of(context).textTheme.headline4),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                editProfileScreen(context);
              },
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  primary: Colors.white,
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
                        .headline5
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
                    .headline4
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
                        dialogLang();
                      },
                      child: ListTile1(
                        title: 'Til',
                        titleIcon: Icons.language_outlined,
                        suffixText: 'English',
                        icon: Icons.arrow_forward_ios_outlined,
                      )),
                  InkWell(
                      onTap: () {
                        dialogCurrency();
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
                        .headline4
                        ?.copyWith(color: Colors.black54),
                  ),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    _showLogOutLabel();
                  },
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  void dialogLang() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Tilni tanlang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {}, child: Text('Uzbek')),
                  TextButton(onPressed: () {}, child: Text('Russian')),
                  TextButton(onPressed: () {}, child: Text('English'))
                ],
              ),
            ));
  }

  void dialogCurrency() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Valyutani tanlang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {}, child: Text('So\'m')),
                  TextButton(onPressed: () {}, child: Text('Dollar')),
                ],
              ),
            ));
  }

  void _showLogOutLabel() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.exit,
              style: Theme.of(context).textTheme.headline3,
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
                        .headline3
                        ?.copyWith(color: Colors.green, fontSize: 20),
                  )),
              TextButton(
                  onPressed: () {
                    AuthService.signOutUser(context);
                    Prefs.removePhone();
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
                        .headline3
                        ?.copyWith(color: Colors.red, fontSize: 20),
                  )),
            ],
          );
        });
  }
}
