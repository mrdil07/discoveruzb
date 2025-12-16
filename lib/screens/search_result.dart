import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/places_model.dart';
import '../view_models/search_vm.dart';

class SearchResult extends StatelessWidget {
  final String searchedPlace;

  const SearchResult({this.searchedPlace = '', Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load search results when the widget is built (or when the SearchViewModel is initialized)
    // This ensures the search is performed when navigating to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchViewModel>(context, listen: false).searchPosts(searchedPlace);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.searchResult,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, searchViewModel, child) {
          if (searchViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (searchViewModel.error != null) {
            return Center(child: Text('Xatolik: ${searchViewModel.error}'));
          } else if (searchViewModel.searchResults.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noDataFound,
                style: Theme.of(context).textTheme.bodyLarge, // Changed to bodyLarge
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  crossAxisCount: 2,
                ),
                itemCount: searchViewModel.searchResults.length,
                itemBuilder: (context, index) {
                  Place place = searchViewModel.searchResults[index];
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            height: (MediaQuery.of(context).size.width - 32) / 2,
                            width: (MediaQuery.of(context).size.width - 32) / 2,
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
