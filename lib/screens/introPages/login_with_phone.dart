import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'otp.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  bool isLoading = false;
  final phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    print(isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          color: Colors.tealAccent.shade400,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //mainAxisSize: MainAxisSize.m,
              children: [
                Text(
                  AppLocalizations.of(context)!.enterPhoneNumber,
                  style: const TextStyle(fontSize: 28, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 6,
                ),
                //phone
                TextFormField(
                  validator: (input) => input!.isEmpty
                      ? AppLocalizations.of(context)!.enterPhoneNumber
                      : null,
                  controller: phoneController,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: "## ### ## ##"),
                  ],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "+998",
                        style: TextStyle(fontSize: 19, color: Colors.black),
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 10, minHeight: 0),
                    contentPadding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'XX XXX XX XX',
                    prefixStyle:
                        const TextStyle(fontSize: 18, color: Colors.black),
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 5,
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              OTPScreen(phoneController.text)));
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      primary: Colors.white,
                      backgroundColor: Colors.teal.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: Colors.white,
                              width: 0.5,
                              style: BorderStyle.solid))),
                  child: !isLoading
                      ? Text(
                          AppLocalizations.of(context)!.getSMS,
                          style: const TextStyle(
                            fontSize: 28,
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                ),
                // Expanded(
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Text(
                //         AppLocalizations.of(context)!.registerWith,
                //         style: Theme.of(context).textTheme.headline3?.copyWith(
                //             color: Colors.black54, fontWeight: FontWeight.w400),
                //       ),
                //       const SizedBox(height: 20),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Container(
                //             child: Image.asset(
                //               'assets/images/google.png',
                //               width: 60,
                //             ),
                //           ),
                //           const SizedBox(width: 30),
                //           Container(
                //             child: Image.asset(
                //               'assets/images/facebook.png',
                //               width: 60,
                //             ),
                //           )
                //         ],
                //       )
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void loginWithFacebook() {}
  //
  // void loginWithGoogle() {}
}
