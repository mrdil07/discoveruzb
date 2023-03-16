import 'package:discoveruzb/models/users_model.dart';
import 'package:discoveruzb/screens/pageViewPages/main_screen.dart';
import 'package:discoveruzb/service/data_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Registration extends StatefulWidget {
  String phone;
  Registration(this.phone, {Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _controller = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final famController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xff2084E9),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          controller: _controller,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ma’lumotlaringizni kiriting',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                //ism
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Ism',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                  ),
                  validator: (input) =>
                      input!.isEmpty ? 'Ismizni kiriting' : null,
                ),
                const SizedBox(height: 20),
                //familya
                TextFormField(
                  controller: famController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Familiya',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.transparent)),
                  ),
                  validator: (input) =>
                      input!.isEmpty ? 'Familyangizni kiriting' : null,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String fullname =
                          '${nameController.text.trim()} ${famController.text.trim()}';
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => const MainPage()),
                          (route) => false);
                      Users users =
                          Users(fullname: fullname, phoneNumber: widget.phone);
                      DataService.storeUser(users);
                    }
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      backgroundColor: const Color(0xff2084E9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: Colors.white,
                              width: 0.6,
                              style: BorderStyle.solid))),
                  child: const Text(
                    'Keyingisi',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
