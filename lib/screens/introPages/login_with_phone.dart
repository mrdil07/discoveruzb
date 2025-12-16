import 'package:discoveruzb/view_models/login_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import 'otp.dart';

class LoginWithPhone extends StatelessWidget {
  const LoginWithPhone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

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
              children: [
                Text(
                  AppLocalizations.of(context)!.enterPhoneNumber,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width / 6,
                ),
                TextFormField(
                  validator: (input) => input!.isEmpty
                      ? AppLocalizations.of(context)!.enterPhoneNumber
                      : null,
                  controller: loginVM.phoneController,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: "## ### ## ##"),
                  ],
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => loginVM.updatePhoneNumber(value),
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
                Consumer<LoginViewModel>(
                  builder: (context, vm, child) {
                    return TextButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await vm.submitPhoneNumber();
                                if (vm.error == null) {
                                  // Only navigate if no error occurred during submission
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => OTPScreen(
                                          '998${vm.phoneNumber.replaceAll(' ', '')}'), // Pass formatted phone number
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(vm.error!)),
                                  );
                                }
                              }
                            },
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: Colors.white,
                                  width: 0.5,
                                  style: BorderStyle.solid))),
                      child: vm.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.getSMS,
                              style: const TextStyle(
                                fontSize: 28,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
