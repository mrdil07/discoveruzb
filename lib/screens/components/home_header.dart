import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:discoveruzb/widgets/hero_image.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../models/places_model.dart';
import '../../view_models/home_vm.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeViewModel, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.tealAccent.shade400,
                          fontWeight: FontWeight.w600,
                        ), 
                      ),
                      Text(
                        homeViewModel.fullName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.tealAccent.shade700,
                          fontWeight: FontWeight.w600,
                        ), 
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
                    child: CircularProfileImg(imageUrl: homeViewModel.imgUrl),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              //search places
              Autocomplete<Place>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Place>.empty();
                  } else {
                    return homeViewModel.famousPlaces.where((word) => word.placeName
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
                                  text: option.placeName,
                                  term: homeViewModel.searchController.text,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: Colors.black),
                                  textStyleHighlight: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red),
                                ),
                                subtitle: Text(
                                  option.address,
                                  style: Theme.of(context).textTheme.bodySmall,
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
                              place: selectedItem, // Pass the entire Place object
                          ),
                      ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  // Bind the controller to the HomeViewModel's searchController
                  homeViewModel.searchController.text = controller.text;
                  homeViewModel.searchController.selection = controller.selection;

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
                      hintText: AppLocalizations.of(context)!.searchPlaceholder,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  );
                },
                displayStringForOption: (Place searchItem) =>
                    searchItem.placeName,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CircularProfileImg extends StatelessWidget {
  final double? height;
  final double? width;
  final String imageUrl;
  const CircularProfileImg({Key? key, this.height = 80, this.width = 80, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: imageUrl.isNotEmpty
          ? InkWell(
              onTap: () {
                // The showImage function is removed from ViewModel, should be handled in UI
                // You might want to navigate to a full-screen image view here
              },
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: height,
                width: width,
                fit: BoxFit.cover,
                placeholder: (ctx, url) =>
                    Image.asset('assets/images/discoveruzb.png'),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/discoveruzb.png',
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : InkWell(
              onTap: () {
                // The showImage function is removed from ViewModel, should be handled in UI
                // You might want to navigate to a full-screen image view here
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

// showImage funksiyasi bu yerdan olib tashlandi, uni UI qatlamida boshqarish kerak.
