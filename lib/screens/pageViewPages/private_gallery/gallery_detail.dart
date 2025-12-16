import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discoveruzb/service/file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../service/data_service.dart';
import '../../../view_models/create_gallery_vm.dart';

class GalleryDetail extends StatefulWidget {
  final int index;
  final List<dynamic> images;
  final String placeName;
  const GalleryDetail(
      {Key? key,
      required this.images,
      required this.placeName,
      required this.index})
      : super(key: key);

  @override
  State<GalleryDetail> createState() => _GalleryDetailState();
}

class _GalleryDetailState extends State<GalleryDetail> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateGalleryVM>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.placeName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: GridView.builder(
          itemCount: widget.images.length,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (ctx, index) => CachedNetworkImage(
                width: double.infinity,
                height: double.infinity,
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) {
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
              )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _imgFromGallery().then((value) => {
                updateImages(),
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future _imgFromGallery() async {
    final provider = Provider.of<CreateGalleryVM>(context, listen: false);
    try {
      var image = await provider.imagePicker.pickMultiImage(imageQuality: 50);
      if (image != null) {
        for (int i = 0; i < image.length; i++) {
          if (mounted) {
            setState(() {
              provider.imagesFile.add(File(image[i].path));
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('image error: $e');
      }
    }
  }

  Future updateImages() async {
    final provider = Provider.of<CreateGalleryVM>(context, listen: false);
    await FileService.uploadFiles(
            provider.imagesFile, FileService.folderGallery)
        .then((imageLink) => {
              DataService.updateGallery(imageLink, widget.index),
              provider.imagesFile.clear(),
            });
  }
}
