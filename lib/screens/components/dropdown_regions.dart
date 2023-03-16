import 'package:discoveruzb/view_models/sub_category_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/data_sources.dart';

class DropDownRegions extends StatefulWidget {
  String subCategoryName;
  DropDownRegions(this.subCategoryName, {Key? key}) : super(key: key);

  @override
  State<DropDownRegions> createState() => _DropDownRegionsState();
}

class _DropDownRegionsState extends State<DropDownRegions> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubCategoryVM>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: MediaQuery.of(context).size.height / 18,
      child: DropdownButtonFormField<String>(
        isDense: true,
        items: regions.map((String? val) {
          return DropdownMenuItem(
            value: val,
            child: Text(
              val!,
              style: Theme.of(context).textTheme.headline6,
            ),
          );
        }).toList(),
        style:
            Theme.of(context).textTheme.headline6?.copyWith(color: Colors.teal),
        onChanged: (item) {
          setState(() {
            provider.address1 = item;
          });
          provider.apiLoadPostsNew(widget.subCategoryName);
        },
        decoration: InputDecoration(
            hintText: provider.address1,
            hintStyle: TextStyle(fontSize: 20, color: Colors.teal.shade400),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.teal.shade400)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.teal.shade400))),
      ),
    );
  }
}
