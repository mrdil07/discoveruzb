import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/places_model.dart';
import '../view_models/search_vm.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Consumer<SearchViewModel>(
          builder: (context, searchViewModel, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      controller: searchViewModel.searchController,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (input) {
                        searchViewModel.searchPosts(input);
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20),
                          hintText: AppLocalizations.of(context)!.findPlaces,
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Colors.grey.shade100,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Colors.blue.shade400,
                              width: 0.5,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true),
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (searchViewModel.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (searchViewModel.error != null) {
                        return Center(child: Text('Xatolik: ${searchViewModel.error}'));
                      } else if (searchViewModel.searchResults.isEmpty) {
                        return Center(child: Text(AppLocalizations.of(context)!.noDataFound));
                      } else {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemCount: searchViewModel.searchResults.length,
                          itemBuilder: (ctx, index) {
                            Place place = searchViewModel.searchResults[index];
                            return SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
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
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
