import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/places_model.dart';
import '../service/data_service.dart';

class SearchResult extends StatefulWidget {
  String searchedPlace;

  SearchResult({this.searchedPlace = '', Key? key}) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  List<Place> searchItems = [];
  bool isLoading = false;

  var mainController = ScrollController();
  var subController = ScrollController();

  void _apiSearchPlace(String keyword) {
    setState(() {
      isLoading = true;
    });
    DataService.searchPosts(keyword).then((places) {
      _showSearchPlaces(places!);
    });
  }

  _showSearchPlaces(List<Place> places) {
    if (mounted) {
      setState(() {
        searchItems = places;
      });
      if (searchItems.isEmpty) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiSearchPlace(widget.searchedPlace);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.searchResult,
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? SafeArea(
                  bottom: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    physics: const ClampingScrollPhysics(),
                    controller: mainController,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      controller: subController,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        crossAxisCount: 2,
                      ),
                      itemCount: searchItems.length,
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
                                              place: searchItems[index],
                                            )));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  height:
                                      (MediaQuery.of(context).size.width - 32) /
                                          2,
                                  width:
                                      (MediaQuery.of(context).size.width - 32) /
                                          2,
                                  imageUrl: searchItems[index].placeImage.first,
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
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 7.5, 15, 7.5),
                                    height: 50,
                                    child: Text(
                                      searchItems[index].placeName,
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
                        );
                      },
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    AppLocalizations.of(context)!.searchInfo,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
        ],
      ),
    );
  }
}
