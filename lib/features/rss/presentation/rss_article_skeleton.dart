import 'package:flutter/material.dart';

class RssArticleSkeleton extends StatelessWidget {
  const RssArticleSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24,
      ),
      itemCount: 6,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Theme.of(context)
            .colorScheme
            .outlineVariant,
      ),
      itemBuilder: (_, __) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _SkeletonLine(
                widthFactor: 0.85,
                height: 15,
              ),
              SizedBox(height: 7),
              _SkeletonLine(
                widthFactor: 0.45,
                height: 11,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _SkeletonLine({
    required this.widthFactor,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(4),
        ),
      ),
    );
  }
}
