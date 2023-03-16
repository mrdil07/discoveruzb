import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/places_model.dart';
import '../service/data_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var isLoading = false;
  List items = [];

  String searchedPlace = '';

  void _apiSearchUser(String keyword) {
    setState(() {
      isLoading = true;
    });
    DataService.searchPosts(keyword).then((places) {
      _showSearchUsers(places!);
    });
  }

  _showSearchUsers(List<Place> places) {
    if (mounted) {
      setState(() {
        isLoading = false;
        items = places;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    //search field
                    SizedBox(
                      height: 50,
                      child: TextField(
                        style: const TextStyle(color: Colors.black),
                        onChanged: (input) {
                          setState(() {
                            searchedPlace = input;
                          });
                          _apiSearchUser(input);
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
                    Expanded(
                        child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
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
                                                place: items[index],
                                              )));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    height: (MediaQuery.of(context).size.width -
                                            32) /
                                        2,
                                    width: (MediaQuery.of(context).size.width -
                                            32) /
                                        2,
                                    imageUrl: items[index].placeImage.first,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(child: Container()),
                                    Container(
                                      color: Colors.black.withAlpha(150),
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 7.5, 15, 7.5),
                                      height: 50,
                                      child: Text(
                                        items[index].placeName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
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
                    ))
                  ],
                ),
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ));
  }
}
