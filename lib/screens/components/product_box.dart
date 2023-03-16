import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/places_model.dart';
import '../pageViewPages/category_page/detailsPlace.dart';

class ProductBox extends StatelessWidget {
  double height;
  double weight;
  List<Place> place;
  ProductBox({
    Key? key,
    required this.height,
    required this.place,
    this.weight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: height,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: place.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        physics: const ClampingScrollPhysics(),
        itemBuilder: (con, i) {
          return InkWell(
            splashColor: Colors.red[600]!.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            onTap: () {
              Navigator.of(context).push(
                createRoute(place[i]),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,
                    blurRadius: 1.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0.3, 0.7),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: weight,
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: place[i].placeImage.first,
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
                    width: weight,
                    height: 60,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place[i].placeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                        ),
                        Text(
                          place[i].address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey[400]!,
                                    fontSize: 16,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Route createRoute(Place place) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailsOfPlace(place: place),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset(0.0, 0.0);
          const curves = Curves.easeIn;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curves));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }
}
