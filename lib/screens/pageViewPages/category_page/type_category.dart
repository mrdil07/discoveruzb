import 'package:discoveruzb/screens/pageViewPages/category_page/sub_category.dart';
import 'package:flutter/material.dart';

import '../../../constants/data_sources.dart';
import '../../../models/types_model.dart';

class TypeOfPlaces extends StatefulWidget {
  const TypeOfPlaces({Key? key}) : super(key: key);

  @override
  State<TypeOfPlaces> createState() => _TypeOfPlacesState();
}

class _TypeOfPlacesState extends State<TypeOfPlaces> {
  List<Types> categName = [
    Types(typeName: 'Sanatoriya', image: ''),
    Types(typeName: 'Mehmonxona', image: ''),
    Types(typeName: 'Dacha', image: ''),
    Types(typeName: 'Dam olish maskanlari', image: ''),
    Types(typeName: "Cho'milish havzalari ", image: ''),
    Types(typeName: "Istirohat bog'i", image: ''),
    Types(typeName: 'Boshqalar', image: ''),
    Types(typeName: 'Sanatoriya', image: ''),
  ];
  // List<Map<String, String>> cateqgName = [
  //   {"Sanatoriya": AppLocalizations.of(context)!.sanatoriya},
  //   {"Mehmonxona": AppLocalizations.of(context)!.hotel},
  //   {"Dacha": AppLocalizations.of(context)!.dacha},
  //   {"Dam olish maskanlari": AppLocalizations.of(context)!.damOlish},
  //   {"Cho'milish havzalari": AppLocalizations.of(context)!.basseyn},
  //   {"Boshqalar": AppLocalizations.of(context)!.boshqalar}
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child: categName.isNotEmpty
            ? ListView.builder(
                itemCount: categImage.length,
                itemBuilder: (ctx, index) => InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => SubCategory(
                                  subCategoryName: categName[index].typeName,
                                )));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    alignment: Alignment.bottomLeft,
                    height: MediaQuery.of(context).size.width / 3,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      ],
                      image: DecorationImage(
                          image: AssetImage(categImage[index]),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Colors.black54,
                        Colors.black54,
                        Colors.black87
                      ], begin: Alignment.center, end: Alignment.bottomCenter)),
                      child: Text(
                        categName[index].typeName,
                        style:
                            const TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
