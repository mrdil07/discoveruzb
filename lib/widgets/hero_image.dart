import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HeroNetImage extends StatelessWidget {
  List images;
  HeroNetImage({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: UniqueKey(),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: CarouselSlider.builder(
              itemCount: images.length,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.width / 1.2,
                autoPlay: false,
                autoPlayAnimationDuration: const Duration(seconds: 2),
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                initialPage: 2,
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InteractiveViewer(
                    panEnabled: false, // Set it to false to prevent panning.
                    boundaryMargin: const EdgeInsets.all(50),
                    minScale: 1,
                    maxScale: 4,
                    child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      imageUrl: images[index],
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
      ),
    );
  }
}

class HeroAssetImage extends StatelessWidget {
  String image;
  HeroAssetImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Image.asset(image),
      ),
    );
  }
}
