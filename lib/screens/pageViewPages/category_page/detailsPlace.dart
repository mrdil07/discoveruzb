import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discoveruzb/screens/comment_page.dart';
import 'package:discoveruzb/view_models/details_vm.dart';
import 'package:discoveruzb/view_models/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/places_model.dart';
import '../../../service/utils.dart';

class DetailsOfPlace extends StatefulWidget {
  final Place place;

  const DetailsOfPlace({required this.place, Key? key}) : super(key: key);

  @override
  State<DetailsOfPlace> createState() => _DetailsOfPlaceState();
}

class _DetailsOfPlaceState extends State<DetailsOfPlace> {
  @override
  void initState() {
    final provider = Provider.of<DetailsVM>(context, listen: false);
    super.initState();
    Future.delayed(Duration.zero).then((value) => {
          provider.getWeather(widget.place.lat, widget.place.lon),
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsVM>(context, listen: true);
    final providerUser = Provider.of<HomeViewModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.place.placeName,
          maxLines: 2,
          style: Theme.of(context).textTheme.headline2?.copyWith(
                color: Colors.teal.shade700,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          /// °°°°°°°  °°°
          InkWell(
            onTap: () {
              provider.getWeather(widget.place.lat, widget.place.lon);
            },
            child: Row(
              children: [
                Text(
                  "${provider.temp}°",
                  style: Theme.of(context).textTheme.headline4,
                ),
                if (provider.temp != null)
                  Image.asset(
                    provider.temp! > 0
                        ? "assets/icons/sun.png"
                        : "assets/icons/cloudy.png",
                    scale: 2,
                  ),
                IconButton(
                    onPressed: () {
                      Utils.fireToast("QR code hozirda ishkab chiqilmoqda");
                    },
                    icon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.teal.shade400,
                    ))
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: CarouselSlider.builder(
                  itemCount: widget.place.placeImage.length,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.width / 1.2,
                    autoPlay: false,
                    autoPlayAnimationDuration: const Duration(seconds: 2),
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    initialPage: 2,
                  ),
                  itemBuilder:
                      (BuildContext context, int itemIndex, int pageViewIndex) {
                    return InkWell(
                      onTap: () {
                        provider.showImage(context, widget.place.placeImage);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          imageUrl: widget.place.placeImage[itemIndex],
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          widget.place.placeName,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .headline2
                              ?.copyWith(color: Colors.teal.shade700),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) =>
                                            CommentPage(place: widget.place)));
                              },
                              child: Icon(
                                Icons.comment_bank_outlined,
                                color: Colors.tealAccent.shade700,
                              ),
                            ),
                            Spacer(),
                            InkWell(
                                onTap: () {
                                  if (!widget.place.liked
                                      .contains(providerUser.userId)) {
                                    provider.apiPostLike(
                                        widget.place, providerUser.userId);
                                    widget.place.likeCount++;
                                  } else {
                                    provider.apiPostUnLike(
                                        widget.place, providerUser.userId);
                                    widget.place.likeCount--;
                                  }
                                },
                                child: widget.place.liked
                                        .contains(providerUser.userId)
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.tealAccent.shade700,
                                      )
                                    : Icon(
                                        Icons.favorite_border_outlined,
                                        color: Colors.tealAccent.shade700,
                                      )),
                            //saved button
                            const Spacer(),
                            InkWell(
                                onTap: () {
                                  if (!widget.place.saved
                                      .contains(providerUser.userId)) {
                                    provider.apiPostSave(
                                        widget.place, providerUser.userId);
                                    Utils.fireToast(
                                        AppLocalizations.of(context)!
                                            .addedSaved);
                                  } else {
                                    provider.apiPostUnSave(
                                        widget.place, providerUser.userId);
                                    Utils.fireToast(
                                        AppLocalizations.of(context)!
                                            .removeSaved);
                                  }
                                },
                                child: widget.place.saved
                                        .contains(providerUser.userId)
                                    ? Icon(
                                        Icons.bookmark,
                                        color: Colors.tealAccent.shade700,
                                      )
                                    : Icon(
                                        Icons.bookmark_border_outlined,
                                        color: Colors.tealAccent.shade700,
                                      )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 0.4,
                        )),
                    child: Column(
                      children: [
                        /// joy hududi
                        ListTile(
                          onTap: () {
                            provider.openMapsSheet(context, widget.place.lat,
                                widget.place.lon, widget.place.placeName);
                          },
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: Colors.tealAccent.shade700,
                            size: 30,
                          ),
                          title: Text(
                            widget.place.address,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(fontSize: 20, color: Colors.grey),
                          ),
                        ),

                        /// joy turi
                        ListTile(
                          leading: Icon(
                            Icons.lightbulb_outlined,
                            color: Colors.tealAccent.shade700,
                            size: 30,
                          ),
                          title: Text(
                            widget.place.type,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(fontSize: 20, color: Colors.grey),
                          ),
                        ),

                        /// like.lar soni ko'rsatuvchi joy
                        ListTile(
                          leading: Icon(
                            Icons.favorite,
                            color: Colors.tealAccent.shade700,
                            size: 30,
                          ),
                          title: Text(
                            '${widget.place.likeCount} ' +
                                AppLocalizations.of(context)!.likedBy,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(fontSize: 20, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.fullInfo,
                    style: Theme.of(context).textTheme.headline2?.copyWith(
                          color: Colors.teal.shade700,
                        ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place.placeInfo,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.copyWith(
                                    letterSpacing: 1,
                                    height: 1.4,
                                    fontSize: 21,
                                    color: Colors.teal.shade900),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Manba: ${widget.place.source}',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          provider.openMapsSheet(context, widget.place.lat, widget.place.lon,
              widget.place.placeName);
        },
        child: Text(
          "GO",
          style: Theme.of(context)
              .textTheme
              .headline5
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
