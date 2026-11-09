import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/poem.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/poem_card.dart';
import 'detail_screen.dart';
import 'study_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';

  void _openDetail(Poem poem) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => DetailScreen(state: widget.state, poem: poem)),
    );
  }

  void _openStudy(int startIndex) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => StudyScreen(state: widget.state, startIndex: startIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = widget.state;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final poems = state.poems;
        final total = poems.length;
        final studiedCount = state.studiedCount;
        final nextIdx = poems.indexWhere((p) => state.progressFor(p.id).studyCount == 0);
        final allStudied = studiedCount == total && total > 0;
        final shown = _filter == 'researched' ? poems.where((p) => p.authoritative).toList() : poems;

        return Column(
          children: [
            Responsive.centered(
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('今朝 · 读毛泽东诗词',
                        style: TextStyle(
                            fontSize: context.sp(11.5),
                            letterSpacing: 2,
                            color: c.gold,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('诗词', style: TextStyle(fontFamily: 'serif', fontSize: context.sp(24), color: c.ink)),
                    const SizedBox(height: 2),
                    Text('$total首作品 · 一篇一篇慢慢读', style: TextStyle(fontSize: context.sp(12.5), color: c.inkSoft)),
                  ],
                ),
              ),
              maxWidth: Responsive.maxContentWidth,
            ),
            Responsive.centered(
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: total == 0 ? null : () => _openStudy(nextIdx < 0 ? 0 : nextIdx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: c.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(alignment: Alignment.center, children: [
                            CircularProgressIndicator(
                              value: total == 0 ? 0 : studiedCount / total,
                              strokeWidth: 3,
                              backgroundColor: c.border,
                              color: c.seal,
                            ),
                            Text('$studiedCount/$total',
                                style: TextStyle(fontSize: context.sp(10), color: c.seal, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allStudied ? '全部读过，温故知新' : '继续学习《${poems[nextIdx].title}》',
                                style: TextStyle(fontSize: context.sp(13.5), color: c.ink, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                allStudied ? '点击进入常读常新，温习旧篇' : '进入沉浸阅读，一篇一篇读',
                                style: TextStyle(fontSize: context.sp(11.5), color: c.inkSoft),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              maxWidth: Responsive.maxContentWidth,
            ),
            Responsive.centered(
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(children: [
                  _filterChip(c, 'researched', '已出版 (${state.authoritativeCount})'),
                  const SizedBox(width: 6),
                  _filterChip(c, 'all', '全部 (${poems.length})'),
                ]),
              ),
              maxWidth: Responsive.maxContentWidth,
            ),
            Expanded(
              child: Responsive.centered(
                GridView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  // 卡片高度随字号缩放联动，否则平板上放大字体后文字/插画会被固定的格子高度裁掉。
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 520,
                    mainAxisExtent: 52 * Responsive.typeScale(context) + 34,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final p = shown[i];
                    return PoemCard(
                      poem: p,
                      progress: state.progressFor(p.id),
                      onTap: () => _openDetail(p),
                    );
                  },
                ),
                maxWidth: Responsive.maxContentWidth,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip(AppColors c, String value, String label) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c.seal : c.bgCard,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? c.seal : c.border),
        ),
        child: Text(label, style: TextStyle(fontSize: context.sp(12.5), color: active ? const Color(0xFFFBF5E6) : c.inkSoft)),
      ),
    );
  }
}
