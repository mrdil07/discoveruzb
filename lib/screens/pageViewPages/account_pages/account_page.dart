import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/settings_page.dart';
import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/update_image.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/places_model.dart';
import '../../../view_models/account_vm.dart';
import '../category_page/detailsPlace.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  // A separate function for showing the confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, Place place) {
    final accountVM = Provider.of<AccountViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.wantDelete,
            style: Theme.of(context).textTheme.displaySmall,
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
                    .displaySmall
                    ?.copyWith(color: Colors.green, fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog first
                await accountVM.deletePost(place); // Call ViewModel method
                // Display error if any
                if (accountVM.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(accountVM.error!)),
                  );
                  accountVM.clearError(); // Clear error after showing
                }
              },
              child: Text(
                AppLocalizations.of(context)!.continu,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: Colors.red, fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load user profile and posts when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountVM = Provider.of<AccountViewModel>(context, listen: false);
      accountVM.fetchUserProfile();
      accountVM.fetchMyPosts();
    });

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
            ),
          ),
        ],
      ),
      body: Consumer<AccountViewModel>(
        builder: (context, accountVM, child) {
          // Show error message if any - use addPostFrameCallback to avoid setState during build
          if (accountVM.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(accountVM.error ?? '')),
              );
              accountVM.clearError();
            });
          }
          
          return SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      updateImage(context),
                      const SizedBox(height: 20),
                      Text(
                        accountVM.fullName,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        accountVM.email,
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
                        constraints: BoxConstraints(
                          minWidth: (MediaQuery.of(context).size.width - 60) / 2,
                          minHeight: 50,
                        ),
                        onPressed: (index) {
                          accountVM.toggleSelected(index);
                          if (accountVM.isSelected[0]) {
                            accountVM.fetchMyPosts();
                          } else {
                            accountVM.fetchMySavedPosts();
                          }
                        },
                        isSelected: accountVM.isSelected,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context)!.myLiked,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.tealAccent.shade700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context)!.mySaved,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.tealAccent.shade700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      accountVM.places.isNotEmpty
                          ? Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                controller: accountVM.subController,
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  crossAxisCount: 3,
                                ),
                                itemCount: accountVM.places.length,
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
                                                place: accountVM.places[index],
                                              ),
                                            ),
                                          );
                                        },
                                        onLongPress: () {
                                          if (accountVM.phone ==
                                              'KvlFpnpu4ETTQHWKJpvXw3K15Cn1') {
                                            _showDeleteConfirmationDialog(
                                              context,
                                              accountVM.places[index],
                                            );
                                          }
                                        },
                                        child: CachedNetworkImage(
                                          height: (MediaQuery.of(context).size.width - 32) / 2,
                                          width: (MediaQuery.of(context).size.width - 32) / 2,
                                          imageUrl: accountVM.places[index].placeImage.first,
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
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(child: Container()),
                                          Container(
                                            color: Colors.black.withAlpha(150),
                                            padding: const EdgeInsets.fromLTRB(15, 7.5, 15, 3),
                                            height: MediaQuery.of(context).size.height / 21,
                                            child: Text(
                                              accountVM.places[index].placeName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
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
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                if (accountVM.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
