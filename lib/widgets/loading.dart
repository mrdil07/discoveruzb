import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200 + 8 + 16 + 60,
      padding: const EdgeInsets.all(8.0),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
