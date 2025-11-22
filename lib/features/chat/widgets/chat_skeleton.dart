import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      effect: ShimmerEffect(
        baseColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(0x33),
        highlightColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(0x66),
        duration: const Duration(milliseconds: 1800),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          final messageWidths = [0.8, 0.6, 0.7, 0.5, 0.75, 0.65, 0.7, 0.6];
          final lineWidths = [0.9, 0.7, 0.85, 0.6, 0.8, 0.75, 0.7, 0.65];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80 + (index * 10) % 40,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(0xCC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(0x66),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        index % 3 == 0 ? 3 : (index % 2 == 0 ? 2 : 1),
                        (lineIndex) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width *
                                (lineIndex ==
                                        (index % 3 == 0
                                            ? 2
                                            : (index % 2 == 0 ? 1 : 0))
                                    ? lineWidths[index % lineWidths.length] *
                                          0.7
                                    : messageWidths[index %
                                          messageWidths.length]),
                            height: 14,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(0x99),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
