import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/illustration.dart';
import 'detail_screen.dart';

/// 我的收藏：取消收藏是改回未收藏状态的唯一入口，内容页里不能随手改。
class RecordsScreen extends StatelessWidget {
  final AppState state;
  const RecordsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            final favorites = state.poems.where((p) => state.progressFor(p.id).favorite).toList();
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  decoration: BoxDecoration(color: c.bg, border: Border(bottom: BorderSide(color: c.border))),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              color: c.bgCard, shape: BoxShape.circle, border: Border.all(color: c.border)),
                          child: Icon(Icons.chevron_left, size: 18, color: c.ink),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 28),
                            child: Text('我的收藏', style: TextStyle(fontSize: context.sp(18), color: c.ink)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: favorites.isEmpty
                      ? Center(child: Text('还没有收藏的诗', style: TextStyle(color: c.inkFaint, fontSize: context.sp(12))))
                      : Responsive.centered(
                          ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                            itemCount: favorites.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final p = favorites[i];
                              final prog = state.progressFor(p.id);
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(builder: (_) => DetailScreen(state: state, poem: p)),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                      color: c.bgCard,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: c.border)),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(width: 52, height: 52, child: PoemIllustration(poem: p)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.title,
                                                style: TextStyle(fontSize: context.sp(15), color: c.ink)),
                                            Text('${prog.favoriteDate ?? ''} 收藏',
                                                style: TextStyle(fontSize: context.sp(11), color: c.inkSoft)),
                                          ],
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => state.unfavorite(p.id),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: c.inkFaint,
                                          side: BorderSide(color: c.border),
                                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text('取消收藏', style: TextStyle(fontSize: context.sp(11))),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          maxWidth: Responsive.maxContentWidth,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
