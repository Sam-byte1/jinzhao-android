import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/chinese_number.dart';
import '../utils/responsive.dart';
import '../widgets/feel_sheet.dart';
import '../widgets/illustration.dart';
import '../widgets/verse_text.dart';

/// 常读常新：沉浸式逐篇阅读，读到最后一首不退出——直接循环回第一首继续读。
class StudyScreen extends StatefulWidget {
  final AppState state;
  final int startIndex;
  const StudyScreen({super.key, required this.state, required this.startIndex});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late int _idx;
  Map<String, dynamic>? _peekGloss;
  bool _favoriting = false;
  bool _showPinyin = true;

  @override
  void initState() {
    super.initState();
    _idx = widget.startIndex;
  }

  void _go(int delta) {
    final total = widget.state.poems.length;
    setState(() {
      if (delta > 0) {
        _idx = _idx < total - 1 ? _idx + 1 : 0;
      } else {
        if (_idx > 0) _idx--;
      }
      _peekGloss = null;
    });
  }

  Future<void> _toggleFavorite(String poemId) async {
    final progress = widget.state.progressFor(poemId);
    if (progress.favorite || _favoriting) return;
    setState(() => _favoriting = true);
    await Future.delayed(const Duration(milliseconds: 450));
    await widget.state.markFavorite(poemId);
    if (mounted) setState(() => _favoriting = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final poems = widget.state.poems;
        final poem = poems[_idx];
        final progress = widget.state.progressFor(poem.id);
        final total = poems.length;
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: List.generate(total, (i) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 3,
                                decoration: BoxDecoration(
                                  color: i <= _idx ? c.seal : c.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${_idx + 1}/$total', style: TextStyle(fontSize: context.sp(11), color: c.inkSoft)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 10, 0),
                  child: Row(
                    children: [
                      Text('注音', style: TextStyle(fontSize: context.sp(11), color: c.inkSoft)),
                      Transform.scale(
                        scale: 0.78,
                        child: Switch(
                          value: _showPinyin,
                          activeTrackColor: c.seal,
                          onChanged: (v) => setState(() => _showPinyin = v),
                        ),
                      ),
                      const Spacer(),
                      if (!progress.favorite)
                        GestureDetector(
                          onTap: () => _toggleFavorite(poem.id),
                          child: AnimatedScale(
                            scale: _favoriting ? 1.25 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _favoriting ? c.seal : c.bgCard,
                                border: Border.all(color: _favoriting ? c.seal : c.border),
                              ),
                              child: Icon(Icons.star_rounded,
                                  size: 18, color: _favoriting ? const Color(0xFFFBF5E6) : c.gold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Responsive.centered(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(height: 130, width: double.infinity, child: PoemIllustration(poem: poem)),
                    ),
                  ),
                  maxWidth: Responsive.maxReadingWidth,
                ),
                Expanded(
                  child: Responsive.centered(
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        children: [
                          Text(poem.title, style: TextStyle(fontSize: context.sp(19), color: c.ink)),
                          const SizedBox(height: 3),
                          Text(poem.meta, style: TextStyle(fontSize: context.sp(11.5), color: c.inkSoft)),
                          const SizedBox(height: 10),
                          VerseText(
                            poem: poem,
                            textAlign: TextAlign.center,
                            fontSize: context.sp(15),
                            showPinyin: _showPinyin,
                            onGlossTap: (idx) {
                              final g = poem.gloss[idx - 1];
                              setState(() => _peekGloss = {'idx': idx, 'w': g.word, 'd': g.def});
                            },
                          ),
                          if (_peekGloss != null)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: c.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: c.border),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: context.sp(12.5), color: c.inkSoft, height: 1.6),
                                    children: [
                                      TextSpan(
                                          text: '${_peekGloss!['idx']}. ${_peekGloss!['w']}',
                                          style: TextStyle(color: c.sealDeep, fontWeight: FontWeight.w600)),
                                      TextSpan(text: '  ${_peekGloss!['d']}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    maxWidth: Responsive.maxReadingWidth,
                  ),
                ),
                Responsive.centered(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: OutlinedButton(
                            onPressed: () => widget.state.recordStudy(poem.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: c.sealDeep,
                              side: BorderSide(color: c.seal),
                              backgroundColor: c.sealWash,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                            ),
                            child: Text('学习完${chineseCount(progress.studyCount + 1)}次打卡',
                                style: TextStyle(fontSize: context.sp(12), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: () => showFeelSheet(context, widget.state, poem),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: c.inkSoft,
                              side: BorderSide(color: c.border),
                              backgroundColor: c.bgCard,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                            ),
                            child: Text('写感受', style: TextStyle(fontSize: context.sp(12))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  maxWidth: Responsive.maxReadingWidth,
                ),
                Responsive.centered(
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: _idx > 0 ? () => _go(-1) : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: c.ink,
                            side: BorderSide(color: c.border),
                            backgroundColor: c.bgCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          ),
                          child: Text('‹ 上一篇', style: TextStyle(fontSize: context.sp(14))),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _go(1),
                            style: FilledButton.styleFrom(
                              backgroundColor: c.ink,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                            ),
                            child: Text(
                              _idx == total - 1 ? '常读常新 ↺' : '下一篇 ›',
                              style: TextStyle(fontSize: context.sp(14), color: c.bg, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  maxWidth: Responsive.maxReadingWidth,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
