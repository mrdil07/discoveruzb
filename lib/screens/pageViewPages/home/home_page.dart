import 'package:discoveruzb/screens/components/home_header.dart';
import 'package:discoveruzb/screens/components/product_box.dart';
import 'package:discoveruzb/widgets/loading.dart';
import 'package:discoveruzb/widgets/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../view_models/home_vm.dart';
import '../../components/title_name.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeViewModel>(context, listen: true);
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: provider.refresh,
          child: SingleChildScrollView(
            controller: provider.scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeHeader(),

                /// new added places
                /// TODO: headername: AppLocalizations.of(context)!.newAdded
                TitleName(headerName: "Turistik hududlar"),
                provider.isLoading
                    ? const LoadingWidget()
                    : provider.newAdded.isEmpty //284
                        ? const NoData()
                        : ProductBox(
                            height: 284,
                            place: provider.newAdded,
                          ),

                // ///recommend place
                // /// ///
                // /// place list:  provider.recPosts
                // TitleName(
                //     headerName: AppLocalizations.of(context)!.recommendPlaces),
                // provider.isLoading
                //     ? const LoadingWidget()
                //     : provider.recPosts.isEmpty
                //         ? const NoData()
                //         : ProductBox(
                //             height: 304,
                //             weight: 220,
                //             place: provider.recPosts,
                //           ),

                ///popular place
                TitleName(
                    headerName: AppLocalizations.of(context)!.famousPlaces),
                provider.isLoading
                    ? const LoadingWidget()
                    : provider.famousPlaces.isEmpty
                        ? const NoData()
                        : ProductBox(
                            height: 284,
                            place: provider.famousPlaces,
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//
// List<Place> servicesT = [
// //
//   Place(
//     placeImage: [
//       "https://5.imimg.com/data5/BB/FL/MY-2146287/transportation-services-500x500.jpg"
//     ],
//     price: "",
//     placeInfo: "",
//     address: "Samarqand",
//     placeName: "Transport xizmatalari",
//     type: "",
//     source: "source",
//     lat: 12,
//     lon: 12,
//     time: 12,
//     phoneNumber: [],
//     comments: [],
//   ),
//   Place(
//     placeImage: ["https://xabar.uz/static/crop/3/3/920__95_3314860812.jpg"],
//     price: "",
//     placeInfo: "",
//     address: "Buxoro",
//     placeName: "Tarjimonlik xizmati",
//     type: "",
//     source: "source",
//     lat: 12,
//     lon: 12,
//     time: 12,
//     phoneNumber: [],
//     comments: [],
//   )
// ];

///  keytool -genkey -v -keystore c:\Users\User\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
