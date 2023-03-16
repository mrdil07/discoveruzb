import 'dart:convert';

import 'package:discoveruzb/models/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';

import '../models/places_model.dart';
import '../service/data_service.dart';
import '../widgets/hero_image.dart';

const String apiKey = '09d7f0162c04c0035e95d2891522debf';

class DetailsVM extends ChangeNotifier {
  bool isLoading = false;
  bool isLoadingWeather = false;
  List<Place> places = [];
  num? temp;

  void apiPostLike(Place place, String userId) async {
    place.liked.add(userId);
    notifyListeners();
    await DataService.likePost(place);
    notifyListeners();
  }

  void apiPostUnLike(Place place, String userId) async {
    place.liked.remove(userId);
    notifyListeners();
    await DataService.likePost(place);
    notifyListeners();
  }

  void apiPostSave(Place place, String userId) async {
    place.saved.add(userId);
    notifyListeners();
    await DataService.savePost(place);
    notifyListeners();
  }

  void apiPostUnSave(Place place, String userId) async {
    place.saved.remove(userId);
    notifyListeners();
    await DataService.savePost(place);
    notifyListeners();
  }

  openMapsSheet(context, double lat, double long, String placeName) async {
    try {
      final coords = Coords(lat, long);
      final title = placeName;
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
                          .headline4
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
                                style: Theme.of(context).textTheme.headline3,
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showImage(BuildContext context, List placeImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => HeroNetImage(
          images: [...placeImage],
        ),
      ),
    );
  }

  Future getWeather(double lat, double lon) async {
    isLoadingWeather = true;
    notifyListeners();
    try {
      String url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      var res = await http.get(Uri.parse(url));
      print(res.body);
      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        WeatherModel weatherModel = WeatherModel.fromJson(map);
        temp = weatherModel.main?.temp;
        isLoadingWeather = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }
}
