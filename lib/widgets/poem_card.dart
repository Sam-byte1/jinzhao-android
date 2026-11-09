import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/poem.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'illustration.dart';

class PoemCard extends StatelessWidget {
  final Poem poem;
  final PoemProgress progress;
  final VoidCallback onTap;

  const PoemCard({super.key, required this.poem, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final studied = progress.studyCount > 0;
    final thumbSize = 52 * Responsive.typeScale(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(width: thumbSize, height: thumbSize, child: PoemIllustration(poem: poem)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          poem.title,
                          style: TextStyle(
                              fontSize: context.sp(16),
                              color: c.ink,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (progress.favorite) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.star_rounded, size: context.sp(14), color: c.gold),
                      ],
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: poem.authoritative ? c.seal : c.border,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(poem.meta, style: TextStyle(fontSize: context.sp(11.5), color: c.inkSoft)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: studied ? c.sealWash : c.bgSunk,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                studied ? '读过${progress.studyCount}次' : '未读',
                style: TextStyle(
                  fontSize: context.sp(10.5),
                  fontWeight: FontWeight.w600,
                  color: studied ? c.sealDeep : c.inkFaint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
