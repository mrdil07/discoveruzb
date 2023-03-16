import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/places_model.dart';
import '../service/data_service.dart';
import 'pageViewPages/category_page/detailsPlace.dart';

class FamousPlace extends StatefulWidget {
  const FamousPlace({Key? key}) : super(key: key);

  @override
  State<FamousPlace> createState() => _FamousPlaceState();
}

class _FamousPlaceState extends State<FamousPlace> {
  bool isLoading = false;
  List<Place> fPosts = [];

  _apiLoadPosts() async {
    setState(() {
      isLoading = true;
    });
    await DataService.loadFamousPlace().then((value) => {resLoadPost(value)});
  }

  resLoadPost(List<Place> places) {
    setState(() {
      fPosts = places;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _apiLoadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.famousPlaces,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
      body: Container(
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
          itemCount: fPosts.length,
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
                          place: fPosts[index],
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
                        imageUrl: fPosts[index].placeImage.first,
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
                          fPosts[index].placeName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
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
    );
  }
}
