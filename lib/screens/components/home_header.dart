import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:discoveruzb/widgets/hero_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../models/places_model.dart';
import '../../view_models/home_vm.dart';

class HomeHeader extends StatefulWidget {
  HomeHeader({Key? key}) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  Place? data;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeViewModel>(context, listen: true);
    return Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.welcome,
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.tealAccent.shade400),
                    ),
                    Text(
                      provider.fullName,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.tealAccent.shade700),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(70),
                      border: Border.all(
                        width: 1.5,
                        color: const Color.fromRGBO(193, 53, 132, 1),
                      )),
                  child: const CircularProfileImg(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            //search places
            Autocomplete<Place>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Place>.empty();
                } else {
                  return provider.famousPlaces.where((word) => word.placeName
                      .toLowerCase()
                      .contains(
                          textEditingValue.text.toString().toLowerCase()));
                }
              },
              optionsViewBuilder:
                  (context, Function(Place) onSelected, Iterable options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    height: options.length > 4
                        ? MediaQuery.of(context).size.height / 2
                        : 200,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.blue)),
                    child: Material(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          Place option = options.elementAt(index);
                          return SizedBox(
                            height: 30,
                            child: ListTile(
                              title: SubstringHighlight(
                                text: options.toList()[index].placeName,
                                term: provider.searchController.text,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.black),
                                textStyleHighlight: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red),
                              ),
                              subtitle: Text(
                                '${options.toList()[index].address}',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              onTap: () {
                                onSelected(option);
                              },
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: const Divider()),
                        itemCount: options.length,
                      ),
                    ),
                  ),
                );
              },
              onSelected: (Place selectedItem) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => DetailsOfPlace(
                            place: Place(
                                placeName: selectedItem.placeName,
                                address: selectedItem.address,
                                comments: selectedItem.comments,
                                lat: selectedItem.lat,
                                lon: selectedItem.lon,
                                phoneNumber: selectedItem.phoneNumber,
                                placeImage: selectedItem.placeImage,
                                placeInfo: selectedItem.placeInfo,
                                price: selectedItem.price,
                                source: selectedItem.source,
                                time: selectedItem.time,
                                type: selectedItem.type))));
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                provider.searchController = controller;

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    hintText: "Mahsulotni izlash",
                    prefixIcon: const Icon(Icons.search),
                  ),
                );
              },
              displayStringForOption: (Place searchItem) =>
                  searchItem.placeName,
            ),
          ],
        ));
  }
}

class CircularProfileImg extends StatelessWidget {
  final double? height;
  final double? width;
  const CircularProfileImg({Key? key, this.height = 80, this.width = 80})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeViewModel>(context, listen: true);
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: provider.imgUrl.isNotEmpty
          ? InkWell(
              onTap: () {
                showImage(context);
              },
              child: CachedNetworkImage(
                imageUrl: provider.imgUrl,
                height: height,
                width: width,
                fit: BoxFit.cover,
                placeholder: (ctx, url) =>
                    Image.asset('assets/images/discoveruzb.png'),
              ),
            )
          : InkWell(
              onTap: () {
                showImage(context);
              },
              child: Image.asset(
                'assets/images/discoveruzb.png',
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}

void showImage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => HeroAssetImage(
        image: 'assets/images/discoveruzb.png',
      ),
    ),
  );
}
