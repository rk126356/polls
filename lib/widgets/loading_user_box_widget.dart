import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingUserBoxShimmer extends StatelessWidget {
  const LoadingUserBoxShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.white,
            ),
            title: Container(
              width: double.infinity,
              height: 14.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 12.0,
              color: Colors.white,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60.0,
                  height: 10.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 2.0),
                Container(
                  width: 80.0,
                  height: 10.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
