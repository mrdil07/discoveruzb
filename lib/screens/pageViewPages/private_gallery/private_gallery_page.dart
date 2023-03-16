import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/screens/pageViewPages/private_gallery/creating_gallery.dart';
import 'package:discoveruzb/screens/pageViewPages/private_gallery/gallery_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/create_gallery_vm.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({Key? key}) : super(key: key);

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CreateGalleryVM>(context, listen: false);
    Future.delayed(Duration.zero).then((value) => {
          provider.getData(),
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateGalleryVM>(context, listen: true);
    return SafeArea(
        bottom: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Shaxsiy Galleriya',
              style: Theme.of(context).textTheme.headline4,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const CreatingGallery()))
                      .then((value) => setState(() {
                            provider.getData();
                          }));
                },
              )
            ],
          ),
          body: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemBuilder: (ctx, index) => InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => GalleryDetail(
                                    images: provider.images[index].images,
                                    placeName: provider.images[index].placeName,
                                    index: index,
                                  )));
                    },
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey[400]!,
                          blurRadius: 1.0,
                          spreadRadius: 0.0,
                          offset: const Offset(0.3, 0.7),
                        )
                      ], borderRadius: BorderRadius.circular(5)),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              height: double.infinity,
                              imageUrl: provider.images[index].images.first,
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
                          Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 10),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(5))),
                            child: Text(
                              provider.images[index].placeName,
                              style: Theme.of(context).textTheme.headline4,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
