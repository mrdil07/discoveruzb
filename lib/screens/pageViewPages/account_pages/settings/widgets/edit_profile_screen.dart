import 'package:discoveruzb/screens/pageViewPages/account_pages/settings/widgets/update_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../view_models/account_vm.dart';

void editProfileScreen(BuildContext context) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final provider = Provider.of<AccountViewModel>(context, listen: false);
  nameController.text = provider.fullName;
  showModalBottomSheet(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              updateImage(context, isEditPage: true),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 30),
              TextButton(
                  style: TextButton.styleFrom(
                      minimumSize: Size(200, 45),
                      backgroundColor: Colors.blue,
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  onPressed: () {},
                  child: const Text(
                    'Yangilash',
                    style: TextStyle(fontSize: 19),
                  ))
            ],
          ),
        );
      });
}
