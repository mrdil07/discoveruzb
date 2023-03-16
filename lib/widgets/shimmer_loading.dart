import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      highlightColor: Colors.white,
      baseColor: Colors.grey.shade300,
      child: const ShimmerLayout(),
    );
  }
}

class ShimmerLayout extends StatelessWidget {
  const ShimmerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
    );
  }
}
