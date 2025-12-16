import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:discoveruzb/screens/comment_page.dart';
import 'package:discoveruzb/view_models/details_vm.dart';
import 'package:discoveruzb/view_models/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:map_launcher/map_launcher.dart'; // Added import
import 'package:flutter_svg/flutter_svg.dart'; // Added import

import '../../../models/places_model.dart';
import '../../../service/utils.dart';
import '../../../widgets/hero_image.dart'; // Added import

class DetailsOfPlace extends StatelessWidget {
  final Place place;

  const DetailsOfPlace({required this.place, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detailsVM = Provider.of<DetailsVM>(context, listen: true);
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);

    // Fetch weather when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detailsVM.fetchWeather(place.lat, place.lon);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          place.placeName,
          maxLines: 2,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.teal.shade700,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          InkWell(
            onTap: () {
              detailsVM.fetchWeather(place.lat, place.lon);
            },
            child: Row(
              children: [
                Text(
                  "${detailsVM.temp ?? '--'}°",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (detailsVM.temp != null)
                  Image.asset(
                    detailsVM.temp! > 0
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
                  itemCount: place.placeImage.length,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => HeroNetImage(
                              images: place.placeImage,
                              initialIndex: itemIndex,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          imageUrl: place.placeImage[itemIndex],
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
                          place.placeName,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
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
                                            CommentPage(place: place)));
                              },
                              child: Icon(
                                Icons.comment_bank_outlined,
                                color: Colors.tealAccent.shade700,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                detailsVM.toggleLikePost(place, homeVM.userId);
                              },
                              child: place.liked.contains(homeVM.userId)
                                  ? Icon(
                                      Icons.favorite,
                                      color: Colors.tealAccent.shade700,
                                    )
                                  : Icon(
                                      Icons.favorite_border_outlined,
                                      color: Colors.tealAccent.shade700,
                                    ),
                            ),
                            //saved button
                            const Spacer(),
                            InkWell(
                              onTap: () async {
                                await detailsVM.toggleSavePost(place, homeVM.userId);
                                if (place.saved.contains(homeVM.userId)) {
                                  Utils.fireToast(
                                      AppLocalizations.of(context)!.addedSaved);
                                } else {
                                  Utils.fireToast(
                                      AppLocalizations.of(context)!.removeSaved);
                                }
                              },
                              child: place.saved.contains(homeVM.userId)
                                  ? Icon(
                                      Icons.bookmark,
                                      color: Colors.tealAccent.shade700,
                                    )
                                  : Icon(
                                      Icons.bookmark_border_outlined,
                                      color: Colors.tealAccent.shade700,
                                    ),
                            ),
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
                          onTap: () async {
                            final coords = Coords(place.lat, place.lon);
                            final title = place.placeName;
                            final availableMaps = await MapLauncher.installedMaps;

                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black54.withOpacity(0.7),
                              context: context,
                              builder: (BuildContext context) {
                                return SafeArea(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15, bottom: 10),
                                          child: Text(
                                            'Open with',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(fontSize: 25, color: Colors.white),
                                          ),
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20))),
                                          alignment: Alignment.center,
                                          child: Wrap(
                                            children: <Widget>[
                                              for (var map in availableMaps)
                                                Container(
                                                  height: 70,
                                                  alignment: Alignment.center,
                                                  child: ListTile(
                                                    onTap: () => map.showMarker(
                                                      coords: coords,
                                                      title: title,
                                                    ),
                                                    title: Text(
                                                      map.mapName,
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                                    leading: SvgPicture.asset(
                                                      map.icon,
                                                      height: 60.0,
                                                      width: 60.0,
                                                    ),
                                                  ),
                                                ),
                                              const Divider(
                                                height: 0.5,
                                                color: Colors.grey,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: Colors.tealAccent.shade700,
                            size: 30,
                          ),
                          title: Text(
                            place.address,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium // Changed to titleMedium
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
                            place.type,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium // Changed to titleMedium
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
                            '${place.likeCount} ' +
                                AppLocalizations.of(context)!.likedBy,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium // Changed to titleMedium
                                ?.copyWith(fontSize: 20, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.fullInfo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                            place.placeInfo,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge // Changed to bodyLarge
                                ?.copyWith(
                                    letterSpacing: 1,
                                    height: 1.4,
                                    fontSize: 21,
                                    color: Colors.teal.shade900),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Manba: ${place.source}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium // Changed to titleMedium
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
        onPressed: () async {
          final coords = Coords(place.lat, place.lon);
          final title = place.placeName;
          final availableMaps = await MapLauncher.installedMaps;

          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black54.withOpacity(0.7),
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 10),
                        child: Text(
                          'Open with',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 25, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        alignment: Alignment.center,
                        child: Wrap(
                          children: <Widget>[
                            for (var map in availableMaps)
                              Container(
                                height: 70,
                                alignment: Alignment.center,
                                child: ListTile(
                                  onTap: () => map.showMarker(
                                    coords: coords,
                                    title: title,
                                  ),
                                  title: Text(
                                    map.mapName,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  leading: SvgPicture.asset(
                                    map.icon,
                                    height: 60.0,
                                    width: 60.0,
                                  ),
                                ),
                              ),
                            const Divider(
                              height: 0.5,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Text(
          "GO",
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
