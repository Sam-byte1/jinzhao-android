import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'records_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppState state;
  const ProfileScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final notes = state.allNotesWithPoem.reversed.toList();
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('学习总览',
                      style: TextStyle(fontSize: 11.5, letterSpacing: 2, color: c.gold, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('我的', style: TextStyle(fontFamily: 'serif', fontSize: 24, color: c.ink)),
                  const SizedBox(height: 2),
                  Text('看看自己走过的路', style: TextStyle(fontSize: 12.5, color: c.inkSoft)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Row(children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => RecordsScreen(state: state)),
                    ),
                    child: _statTile(c, '${state.favoriteCount}', '收藏'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _statTile(c, '${state.checkins.length}', '累计打卡')),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text('我的感受记录', style: TextStyle(fontSize: 11.5, color: c.inkFaint, letterSpacing: 1)),
            ),
            if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(child: Text('还没有感受记录，去读一首诗吧', style: TextStyle(color: c.inkFaint, fontSize: 12))),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    for (final e in notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                          decoration: BoxDecoration(
                              color: c.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.value.date, style: TextStyle(fontSize: 10.5, color: c.gold)),
                                  Text(e.key.title, style: TextStyle(fontSize: 10.5, color: c.inkFaint)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(e.value.text, style: TextStyle(fontSize: 12.5, color: c.inkSoft, height: 1.6)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _statTile(AppColors c, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: c.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'serif', fontSize: 20, color: c.sealDeep)),
          Text(label, style: TextStyle(fontSize: 10.5, color: c.inkSoft)),
        ],
      ),
    );
  }
}
