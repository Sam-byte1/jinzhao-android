import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/poem_search.dart';
import 'detail_screen.dart';

/// 诗词搜索：支持原文句子片段、标题、词牌，也支持拼音全拼/首字母缩写——
/// 用户可能只记得某首诗里的几句话，不一定记得标题，所以把搜索重点放在原文上。
class SearchScreen extends StatefulWidget {
  final AppState state;
  const SearchScreen({super.key, required this.state});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<PoemSearchHit> _hits = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    setState(() => _hits = searchPoems(widget.state.poems, query));
  }

  void _clear() {
    _controller.clear();
    setState(() => _hits = []);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasQuery = _controller.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
              decoration: BoxDecoration(color: c.bg, border: Border(bottom: BorderSide(color: c.border))),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: c.bgCard, shape: BoxShape.circle, border: Border.all(color: c.border)),
                      child: Icon(Icons.chevron_left, size: 18, color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: c.bgCard,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 18, color: c.inkFaint),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              onChanged: _onChanged,
                              style: TextStyle(fontSize: 14, color: c.ink),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: '按诗句、标题或拼音搜索',
                                hintStyle: TextStyle(fontSize: 13.5, color: c.inkFaint),
                              ),
                            ),
                          ),
                          if (hasQuery)
                            InkWell(
                              onTap: _clear,
                              child: Icon(Icons.close, size: 16, color: c.inkFaint),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !hasQuery
                  ? Center(
                      child: Text('输入几句记得的诗句、标题或拼音试试',
                          style: TextStyle(color: c.inkFaint, fontSize: 12.5)),
                    )
                  : _hits.isEmpty
                      ? Center(
                          child: Text('没找到相关诗句，换几个字试试',
                              style: TextStyle(color: c.inkFaint, fontSize: 12.5)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                          itemCount: _hits.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _resultTile(c, _hits[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultTile(AppColors c, PoemSearchHit hit) {
    final poem = hit.poem;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => DetailScreen(state: widget.state, poem: poem)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: c.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poem.title, style: TextStyle(fontFamily: 'serif', fontSize: 14.5, color: c.ink, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(poem.meta, style: TextStyle(fontSize: 11, color: c.inkFaint)),
            const SizedBox(height: 6),
            _highlightedLine(c, hit),
          ],
        ),
      ),
    );
  }

  Widget _highlightedLine(AppColors c, PoemSearchHit hit) {
    final line = hit.line;
    final s = hit.highlightStart.clamp(0, line.length);
    final e = hit.highlightEnd.clamp(s, line.length);
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(fontSize: 13, color: c.inkSoft, height: 1.5),
        children: [
          TextSpan(text: line.substring(0, s)),
          TextSpan(
            text: line.substring(s, e),
            style: TextStyle(color: c.sealDeep, fontWeight: FontWeight.w700, backgroundColor: c.gold.withValues(alpha: .18)),
          ),
          TextSpan(text: line.substring(e)),
        ],
      ),
    );
  }
}
