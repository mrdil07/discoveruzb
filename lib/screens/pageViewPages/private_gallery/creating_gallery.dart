import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../view_models/create_gallery_vm.dart';
import '../../../view_models/main_vm.dart';
import '../../../widgets/custom_textfield.dart';

class CreatingGallery extends StatefulWidget {
  const CreatingGallery({Key? key}) : super(key: key);

  @override
  State<CreatingGallery> createState() => _CreatingGalleryState();
}

class _CreatingGalleryState extends State<CreatingGallery> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateGalleryVM>(context, listen: false);
    final provider1 = Provider.of<MainViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Biz bilan shaxsiy galleriyangizni yarating",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: Form(
        key: provider.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                showPicker(context);
              },
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width,
                color: Colors.grey.withOpacity(0.4),
                child: provider.imagesFile.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 60,
                          color: Colors.grey,
                        ),
                      )
                    : Stack(
                        children: [
                          CarouselSlider.builder(
                            itemCount: provider.imagesFile.length,
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.width,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              viewportFraction: 0.9,
                              initialPage: 2,
                            ),
                            itemBuilder: (BuildContext context, int itemIndex,
                                    int pageViewIndex) =>
                                Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Image.file(
                                provider.imagesFile[itemIndex],
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.black12,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        provider.imagesFile.removeAt(0);
                                        provider.isLoading = false;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.highlight_remove,
                                      color: Colors.white54,
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ),
            //place name
            CustomTextField(
              hintText: 'Joy nomini kiriting',
              controller: provider.placeNameController,
              keyboardType: TextInputType.multiline,
            ),
            Expanded(child: Container()),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    maximumSize:
                        Size(MediaQuery.of(context).size.width * 0.75, 55),
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.7, 52)),
                onPressed: () {
                  provider.uploadNewPost(context).then((value) => {
                        Navigator.pop(context),
                      });
                },
                child: Text(
                  "Galleriya yaratish",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.white),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  _imgFromGallery() async {
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

  /// pick images from gallery
  _imgFromCamera() async {
    final provider = Provider.of<CreateGalleryVM>(context, listen: false);
    XFile? image = await provider.imagePicker
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    if (mounted) {
      setState(() {
        provider.imagesFile.add(File(image!.path));
      });
    }
  }
}
