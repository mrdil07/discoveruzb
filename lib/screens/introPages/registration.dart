import 'package:discoveruzb/screens/pageViewPages/main_screen.dart';
import 'package:discoveruzb/view_models/registration_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Registration extends StatefulWidget {
  final String phone;
  const Registration(this.phone, {Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  bool _hasNavigated = false;
  String? _lastShownError;

  void _handleNavigation(RegistrationViewModel vm) {
    if (vm.isRegistered && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => const MainPage()),
          (route) => false,
        );
      });
    }
  }

  void _showError(RegistrationViewModel vm) {
    if (vm.error != null && vm.error != _lastShownError) {
      _lastShownError = vm.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? '')),
          );
          vm.clearError();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationVM = Provider.of<RegistrationViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        color: const Color(0xff2084E9),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Ma'lumotlaringizni kiriting",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: registrationVM.nameController,
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
                TextFormField(
                  controller: registrationVM.famController,
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
                Consumer<RegistrationViewModel>(
                  builder: (context, vm, child) {
                    // Handle navigation and errors
                    _handleNavigation(vm);
                    _showError(vm);

                    return TextButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await vm.registerUser(widget.phone);
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
                      child: vm.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Keyingisi',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
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
