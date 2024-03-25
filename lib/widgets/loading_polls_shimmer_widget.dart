import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPollsShimmer extends StatelessWidget {
  const LoadingPollsShimmer({super.key, this.length});

  final int? length;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 40,
                    color: Colors.white,
                  ),
                  Container(
                    width: 100,
                    height: 40,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 150,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  if (length != null)
                    for (int i = 0; i < length!; i++) _buildOptionShimmer()
                  else
                    Column(
                      children: [
                        _buildOptionShimmer(),
                        _buildOptionShimmer(),
                      ],
                    ),
                  _buildInfoShimmer()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 5,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 10,
                      color: Colors.white,
                    ),
                    Container(
                      width: 60,
                      height: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 40,
                color: Colors.white,
              ),
              Container(
                width: 40,
                height: 40,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 30,
                color: Colors.white,
              ),
              Container(
                width: 40,
                height: 30,
                color: Colors.white,
              ),
              Container(
                width: 40,
                height: 30,
                color: Colors.white,
              ),
              Container(
                width: 40,
                height: 30,
                color: Colors.white,
              ),
              Container(
                width: 40,
                height: 30,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
