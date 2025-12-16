import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/view_models/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/places_model.dart';
import 'pageViewPages/category_page/detailsPlace.dart';

class FamousPlace extends StatelessWidget {
  const FamousPlace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.famousPlaces,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, homeViewModel, child) {
          if (homeViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (homeViewModel.error != null) {
            return Center(child: Text('Xatolik: ${homeViewModel.error}'));
          } else if (homeViewModel.famousPlaces.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noDataFound));
          } else {
            return Container(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1 / 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  crossAxisCount: 2,
                ),
                itemCount: homeViewModel.famousPlaces.length,
                itemBuilder: (context, index) {
                  Place place = homeViewModel.famousPlaces[index];
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
                                place: place,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: (MediaQuery.of(context).size.width) / 1.2,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              imageUrl: place.placeImage.first,
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
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(child: Container()),
                            Container(
                              color: Colors.black.withAlpha(150),
                              padding: const EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
                              height: 50,
                              child: Text(
                                place.placeName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium! // Changed to titleMedium
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
