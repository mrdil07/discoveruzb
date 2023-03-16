import 'package:discoveruzb/models/places_model.dart';
import 'package:discoveruzb/screens/pageViewPages/category_page/detailsPlace.dart';
import 'package:discoveruzb/screens/pageViewPages/home/home_page.dart';
import 'package:flutter/material.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    switch (routeSettings.name) {
      case '/homepage':
        return MaterialPageRoute(builder: (_) {
          return const HomePage();
        });

      case "/details":
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return DetailsOfPlace(
              place: Place(
                  placeName: '',
                  placeImage: [],
                  price: '',
                  placeInfo: '',
                  address: '',
                  type: '',
                  source: '',
                  lat: 43.2,
                  lon: 32.3,
                  time: 323,
                  phoneNumber: [],
                  comments: []),
            );
          });
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Page Not Found"),
        ),
      );
    });
  }
}
