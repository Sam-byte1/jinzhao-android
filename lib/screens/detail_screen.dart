import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/poem.dart';
import '../theme/app_colors.dart';
import '../utils/chinese_number.dart';
import '../utils/text_format.dart';
import '../widgets/feel_sheet.dart';
import '../widgets/illustration.dart';
import '../widgets/verse_text.dart';
import 'study_screen.dart';

class DetailScreen extends StatefulWidget {
  final AppState state;
  final Poem poem;
  const DetailScreen({super.key, required this.state, required this.poem});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _showPinyin = true;
  bool _favoriting = false;
  int? _highlightGloss;
  Timer? _highlightTimer;
  final Map<int, GlobalKey> _glossKeys = {};
  final ScrollController _glossScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _highlightTimer?.cancel();
    _glossScroll.dispose();
    super.dispose();
  }

  void _jumpToGloss(int idx) {
    setState(() {
      _tab.index = 1;
      _highlightGloss = idx;
    });
    _highlightTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _glossKeys[idx];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.3);
      }
    });
    _highlightTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _highlightGloss = null);
    });
  }

  Future<void> _toggleFavorite() async {
    final progress = widget.state.progressFor(widget.poem.id);
    if (progress.favorite || _favoriting) return;
    setState(() => _favoriting = true);
    await Future.delayed(const Duration(milliseconds: 450));
    await widget.state.markFavorite(widget.poem.id);
    if (mounted) setState(() => _favoriting = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final poem = widget.poem;
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final progress = widget.state.progressFor(poem.id);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHero(c, poem),
                Container(
                  color: c.bg,
                  child: TabBar(
                    controller: _tab,
                    isScrollable: true,
                    labelColor: const Color(0xFFFBF5E6),
                    unselectedLabelColor: c.inkSoft,
                    labelStyle: const TextStyle(fontSize: 12.5),
                    indicator: BoxDecoration(color: c.seal, borderRadius: BorderRadius.circular(99)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 13),
                    tabs: const [
                      Tab(text: '原文'),
                      Tab(text: '词语解释'),
                      Tab(text: '白话译文'),
                      Tab(text: '创作背景'),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      TabBarView(
                        controller: _tab,
                        children: [
                          _buildTextPane(c, poem),
                          _buildGlossPane(c, poem),
                          _buildProsePane(c, '白话文', poem.vernacular),
                          _buildProsePane(c, '创作背景', poem.background),
                        ],
                      ),
                      if (!progress.favorite)
                        Positioned(right: 18, bottom: 18, child: _favoriteButton(c)),
                    ],
                  ),
                ),
                _buildActions(c, poem, progress),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _favoriteButton(AppColors c) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: AnimatedScale(
        scale: _favoriting ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _favoriting ? c.seal : c.bgCard,
            border: Border.all(color: _favoriting ? c.seal : c.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .14), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Icon(Icons.star_rounded, color: _favoriting ? const Color(0xFFFBF5E6) : c.gold, size: 24),
        ),
      ),
    );
  }

  Widget _buildHero(AppColors c, Poem poem) {
    return SizedBox(
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PoemIllustration(poem: poem),
          Positioned(
            left: 14,
            top: 10,
            child: _circleButton(c, icon: Icons.chevron_left, onTap: () => Navigator.of(context).pop()),
          ),
          Align(
            alignment: const Alignment(0, -0.25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(poem.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFBF0),
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black87),
                            Shadow(blurRadius: 2, color: Colors.black87),
                          ])),
                  const SizedBox(height: 4),
                  Text(poem.meta,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFBF0),
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black87),
                            Shadow(blurRadius: 2, color: Colors.black87),
                          ])),
                  if (poem.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(poem.subtitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFBF0),
                            shadows: [Shadow(blurRadius: 6, color: Colors.black87)])),
                  ],
                  if (poem.disputedAuthorship)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white.withValues(alpha: .4)),
                      ),
                      child: const Text('存疑', style: TextStyle(fontSize: 10, color: Color(0xFFFFFBF0))),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(AppColors c, {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .45), shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: const Color(0xFFF4EEDD)),
      ),
    );
  }

  Widget _buildTextPane(AppColors c, Poem poem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (poem.preface != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(color: c.bgSunk, borderRadius: BorderRadius.circular(10)),
              child: Text(poem.preface!,
                  style: TextStyle(fontSize: 11.5, color: c.inkFaint, fontStyle: FontStyle.italic, height: 1.6)),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('注音', style: TextStyle(fontSize: 11.5, color: c.inkSoft)),
                Switch(
                  value: _showPinyin,
                  activeTrackColor: c.seal,
                  onChanged: (v) => setState(() => _showPinyin = v),
                ),
              ],
            ),
          ),
          VerseText(
            poem: poem,
            showPinyin: _showPinyin,
            onGlossTap: _jumpToGloss,
          ),
          const SizedBox(height: 56), // 给悬浮收藏星留出空间，避免被盖住最后一行
        ],
      ),
    );
  }

  Widget _buildGlossPane(AppColors c, Poem poem) {
    if (poem.gloss.isEmpty) {
      return Center(child: Text('这首诗的词语解释还在整理中', style: TextStyle(color: c.inkFaint, fontSize: 12)));
    }
    return ListView.separated(
      controller: _glossScroll,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 70),
      itemCount: poem.gloss.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: c.border),
      itemBuilder: (context, i) {
        final idx = i + 1;
        final key = _glossKeys.putIfAbsent(idx, () => GlobalKey());
        final g = poem.gloss[i];
        final highlighted = _highlightGloss == idx;
        return AnimatedContainer(
          key: key,
          duration: const Duration(milliseconds: 300),
          color: highlighted ? c.sealWash : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: '$idx ', style: TextStyle(fontSize: 10.5, color: c.gold)),
                  TextSpan(
                      text: g.word,
                      style: TextStyle(fontSize: 14, color: c.sealDeep, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 4),
              Text(g.def, style: TextStyle(fontSize: 13, color: c.inkSoft, height: 1.6)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProsePane(AppColors c, String tag, String? content) {
    final paragraphs = content != null && tag == '白话文' ? splitIntoParagraphs(content) : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(border: Border.all(color: c.gold), borderRadius: BorderRadius.circular(5)),
            child: Text(tag, style: TextStyle(fontSize: 11, color: c.gold)),
          ),
          const SizedBox(height: 10),
          if (content == null)
            Text(
              '${tag == '白话文' ? '白话翻译' : '创作背景'}还在整理中，敬请期待。',
              style: TextStyle(fontSize: 13.5, color: c.inkSoft, height: 1.95),
            )
          else if (paragraphs != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(p, style: TextStyle(fontSize: 13.5, color: c.inkSoft, height: 1.8)),
                  ),
              ],
            )
          else
            Text(content, style: TextStyle(fontSize: 13.5, color: c.inkSoft, height: 1.95)),
        ],
      ),
    );
  }

  Widget _buildActions(AppColors c, Poem poem, PoemProgress progress) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: c.bg, border: Border(top: BorderSide(color: c.border))),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => widget.state.recordStudy(poem.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.sealDeep,
                side: BorderSide(color: c.seal),
                backgroundColor: c.sealWash,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Text('学习完${chineseCount(progress.studyCount + 1)}次打卡',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _secondaryButton(c, '写感受', () => showFeelSheet(context, widget.state, poem)),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _primaryButton(c, '常读常新', () {
                  final idx = widget.state.poems.indexWhere((p) => p.id == poem.id);
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => StudyScreen(state: widget.state, startIndex: idx < 0 ? 0 : idx),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(AppColors c, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.inkSoft,
        side: BorderSide(color: c.border),
        backgroundColor: c.bgCard,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }

  Widget _primaryButton(AppColors c, String label, VoidCallback onTap) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: c.ink,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.bg)),
    );
  }
}
