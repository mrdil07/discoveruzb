import 'package:discoveruzb/view_models/sub_category_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/data_sources.dart';

class DropDownRegions extends StatelessWidget {
  final String subCategoryName;
  const DropDownRegions(this.subCategoryName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: MediaQuery.of(context).size.height / 18,
      child: Consumer<SubCategoryVM>(
        builder: (context, provider, child) {
          return DropdownButtonFormField<String>(
            isDense: true,
            value: provider.selectedRegion,
            items: regions.map((String val) {
              return DropdownMenuItem(
                value: val,
                child: Text(
                  val,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            }).toList(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.teal),
            onChanged: (item) {
              if (item != null) {
                provider.selectedRegion = item;
                provider.fetchPostsByCategoryAndRegion(subCategoryName);
              }
            },
            decoration: InputDecoration(
                hintText: 'Region',
                hintStyle:
                    TextStyle(fontSize: 20, color: Colors.teal.shade400),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.teal.shade400)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.teal.shade400))),
          );
        },
      ),
    );
  }
}
