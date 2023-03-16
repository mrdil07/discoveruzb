import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/view_models/sub_category_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../components/dropdown_regions.dart';
import '../../search_page.dart';
import 'detailsPlace.dart';

class SubCategory extends StatefulWidget {
  final String subCategoryName;

  const SubCategory({required this.subCategoryName, Key? key})
      : super(key: key);

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final provider = Provider.of<SubCategoryVM>(context, listen: false);
    Future.delayed(Duration.zero).then((value) => {
          provider.apiLoadPosts(widget.subCategoryName),
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubCategoryVM>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.places,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .headline2
              ?.copyWith(color: Colors.teal.shade900),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => const SearchPage()));
            },
            child: const Icon(
              Icons.search,
              size: 35,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 15)
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          physics: const ClampingScrollPhysics(),
          controller: provider.mainController,
          child: Column(
            children: [
              //search
              DropDownRegions(widget.subCategoryName),
              !provider.isLoading
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      controller: provider.subController,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1 / 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        crossAxisCount: 2,
                      ),
                      itemCount: provider.subCategory.length,
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
                                      place: provider.subCategory[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width) / 1.2,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    width: MediaQuery.of(context).size.width,
                                    imageUrl: provider
                                        .subCategory[index].placeImage.first,
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
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 7.5, 15, 7.5),
                                    height: 60,
                                    child: Text(
                                      provider.subCategory[index].placeName,
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
                    )
                  : provider.subCategory.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.noInfo,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height / 2,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
