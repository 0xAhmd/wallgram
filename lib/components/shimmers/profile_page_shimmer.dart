import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePageShimmer extends StatelessWidget {
  const ProfilePageShimmer({super.key});

  Widget shimmerBox({double width = double.infinity, double height = 16}) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: color.primary.withOpacity(0.3),
      highlightColor: color.primary.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(child: shimmerBox(width: 120, height: 20)),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => shimmerBox(width: 60, height: 20)),
          ),
          const SizedBox(height: 16),
          Center(child: shimmerBox(width: 120, height: 40)),
          const SizedBox(height: 16),
          shimmerBox(width: 80, height: 18),
          shimmerBox(width: 200, height: 16),
          shimmerBox(width: 180, height: 16),
          shimmerBox(width: 160, height: 16),
          const SizedBox(height: 12),
          shimmerBox(width: 80, height: 18),
          const SizedBox(height: 8),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
