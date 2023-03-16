import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/settings_page.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/update_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/places_model.dart';
import '../../../view_models/account_vm.dart';
import '../category_page/detailsPlace.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: TextStyle(
            color: Colors.teal.shade500,
            fontSize: 30,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                // _showLogOutLabel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const SettingsPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.settings,
                color: Color.fromRGBO(12, 191, 204, 1),
              )),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Column(
              children: [
                //profile image
                updateImage(context),
                const SizedBox(height: 20),
                Text(
                  provider.fullName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  provider.email,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.normal),
                ),

                const SizedBox(height: 20),
                ToggleButtons(
                    fillColor: Colors.tealAccent.shade100,
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(0),
                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < provider.isSelected.length; i++) {
                          provider.isSelected[i] = i == index;
                        }
                      });
                      provider.isSelected[0]
                          ? provider.apiLoadMyPosts()
                          : provider.apiLoadMySaved();
                    },
                    isSelected: provider.isSelected,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0),
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: Text(
                            AppLocalizations.of(context)!.myLiked,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.tealAccent.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0),
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: Text(
                            AppLocalizations.of(context)!.mySaved,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(color: Colors.tealAccent.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ]),
                provider.places.isNotEmpty
                    ? Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          controller: provider.subController,
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            crossAxisCount: 3,
                          ),
                          itemCount: provider.places.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  hoverColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (ctx) => DetailsOfPlace(
                                                  place: provider.places[index],
                                                )));
                                  },
                                  onLongPress: () {
                                    if (provider.phone ==
                                        'KvlFpnpu4ETTQHWKJpvXw3K15Cn1') {
                                      _showDialog(
                                        title: AppLocalizations.of(context)!
                                            .wantDelete,
                                        place: provider.places[index],
                                      );
                                    }
                                  },
                                  child: CachedNetworkImage(
                                    height: (MediaQuery.of(context).size.width -
                                            32) /
                                        2,
                                    width: (MediaQuery.of(context).size.width -
                                            32) /
                                        2,
                                    imageUrl:
                                        provider.places[index].placeImage.first,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          color: Colors.grey[350],
                                          strokeWidth: 3,
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: Colors.grey[350],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(child: Container()),
                                    Container(
                                      color: Colors.black.withAlpha(150),
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 7.5, 15, 3),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              21,
                                      child: Text(
                                        provider.places[index].placeName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.noInfo,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          provider.isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  void _showDialog({required String title, required Place place}) {
    final provider = Provider.of<AccountViewModel>(context, listen: true);
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              title,
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
                    provider.resDelPosts(place, context);
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
