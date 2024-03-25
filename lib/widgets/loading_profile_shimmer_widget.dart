import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../const/colors.dart';

class LoadingProfileShimmer extends StatelessWidget {
  const LoadingProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.fourthColor, AppColors.primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[500]!,
          child: Column(
            children: [
              SizedBox(
                height: 220, // Adjust the height based on your UI
                width: 120, // Adjust the width based on your UI
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.black,
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.black,
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.black,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatShimmerItem(),
                        _StatShimmerItem(),
                        _StatShimmerItem(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 20,
          width: 50,
          color: Colors.black,
        ),
        SizedBox(height: 4),
        Container(
          height: 12,
          width: 50,
          color: Colors.black,
        ),
      ],
    );
  }
}
