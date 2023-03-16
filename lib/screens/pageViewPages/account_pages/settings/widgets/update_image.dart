import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../view_models/account_vm.dart';

Widget updateImage(BuildContext context, {bool isEditPage = false}) {
  final provider = Provider.of<AccountViewModel>(context, listen: true);
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70),
            border: Border.all(
              width: 1.5,
              color: const Color.fromRGBO(193, 53, 132, 1),
            )),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: provider.imgUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: provider.imgUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/discoveruzb.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.fitHeight,
                  ),
                )
              : Image.asset(
                  'assets/images/discoveruzb.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
        ),
      ),
      isEditPage
          ? SizedBox(
              width: 110,
              height: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      provider.showPicker(context);
                    },
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.purple,
                      size: 26,
                    ),
                  )
                ],
              ),
            )
          : Container()
    ],
  );
}
