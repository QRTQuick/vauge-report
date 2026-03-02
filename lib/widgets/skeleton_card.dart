import 'package:flutter/material.dart';

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key, this.height = 140});

  final double height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withValues(alpha: 0.08);
    final highlightColor = Colors.white.withValues(alpha: 0.4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmer = _controller.value;
        final start = -1.0 + shimmer * 2.0;
        return Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: baseColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(start, 0),
                  end: Alignment(start + 1.4, 0),
                  colors: [baseColor, highlightColor, baseColor],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

