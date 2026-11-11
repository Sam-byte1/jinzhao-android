import 'package:lpinyin/lpinyin.dart';
import '../models/poem.dart';

final _punctRegex = RegExp(
  r'[，。！？；：、“”‘’（）《》·—…\[\]【】\s,.!?;:()—]',
);

final _asciiLettersRegex = RegExp(r'^[a-zA-Z]+$');

/// lpinyin 返回的是带声调符号的拼音（如"wàn""lǐ"），而用户在搜索框里只会敲纯英文字母，
/// 所以要把声调符号归一成普通 ASCII 字母再参与匹配（ü 系列按手机拼音输入法惯例归一成 v）。
const _toneMap = {
  'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
  'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
  'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
  'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
  'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
  'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
  'ń': 'n', 'ň': 'n',
};

String _toPlainAscii(String pinyin) {
  final buf = StringBuffer();
  for (final ch in pinyin.split('')) {
    buf.write(_toneMap[ch] ?? ch);
  }
  return buf.toString();
}

/// 一行原文去掉标点后的「可比对文本」，以及每个保留字符对应的原始下标——
/// 用来把搜索命中的位置映射回带标点的原文，做高亮。
class _StrippedLine {
  final String text;
  final List<int> origIndex;
  _StrippedLine(this.text, this.origIndex);
}

_StrippedLine _strip(String line) {
  final buf = StringBuffer();
  final idx = <int>[];
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (!_punctRegex.hasMatch(ch)) {
      buf.write(ch);
      idx.add(i);
    }
  }
  return _StrippedLine(buf.toString(), idx);
}

/// 一行文字的拼音索引：全拼字符串 + 每个拼音字符对应的「去标点后文本」里的字符下标
/// （首字母缩写和去标点文本是严格一对一的，不需要单独的下标表）。
class _PinyinIndex {
  final String full;
  final List<int> charIndexForFullPos;
  final String initials;
  _PinyinIndex(this.full, this.charIndexForFullPos, this.initials);
}

_PinyinIndex _buildPinyinIndex(String strippedText) {
  final fullBuf = StringBuffer();
  final initialsBuf = StringBuffer();
  final charIndexForFullPos = <int>[];
  for (var i = 0; i < strippedText.length; i++) {
    final ch = strippedText[i];
    final arr = PinyinHelper.convertCharToPinyinArray(ch);
    final py = _toPlainAscii((arr.isEmpty ? ch : arr.first).toLowerCase());
    fullBuf.write(py);
    for (var k = 0; k < py.length; k++) {
      charIndexForFullPos.add(i);
    }
    initialsBuf.write(py.isEmpty ? '' : py[0]);
  }
  return _PinyinIndex(fullBuf.toString(), charIndexForFullPos, initialsBuf.toString());
}

/// 一首诗的搜索索引：标题 + 词牌 + 每一行原文，各自的去标点文本与拼音索引。
/// 诗词数据加载后不会再变，按 poem.id 缓存一次，避免每次搜索都重新计算拼音。
class _PoemIndex {
  final List<String> lines;
  final List<_StrippedLine> strippedLines;
  final List<_PinyinIndex> pinyinLines;
  final _StrippedLine strippedTitle;
  final _PinyinIndex pinyinTitle;
  final _StrippedLine? strippedCipai;
  final _PinyinIndex? pinyinCipai;

  _PoemIndex({
    required this.lines,
    required this.strippedLines,
    required this.pinyinLines,
    required this.strippedTitle,
    required this.pinyinTitle,
    this.strippedCipai,
    this.pinyinCipai,
  });
}

final Map<String, _PoemIndex> _indexCache = {};

_PoemIndex _indexFor(Poem poem) {
  return _indexCache.putIfAbsent(poem.id, () {
    final lines = poem.lines;
    final strippedLines = lines.map(_strip).toList();
    final pinyinLines = strippedLines.map((s) => _buildPinyinIndex(s.text)).toList();
    final strippedTitle = _strip(poem.title);
    final pinyinTitle = _buildPinyinIndex(strippedTitle.text);
    final strippedCipai = poem.cipai != null ? _strip(poem.cipai!) : null;
    final pinyinCipai = strippedCipai != null ? _buildPinyinIndex(strippedCipai.text) : null;
    return _PoemIndex(
      lines: lines,
      strippedLines: strippedLines,
      pinyinLines: pinyinLines,
      strippedTitle: strippedTitle,
      pinyinTitle: pinyinTitle,
      strippedCipai: strippedCipai,
      pinyinCipai: pinyinCipai,
    );
  });
}

/// 一条搜索结果：命中的诗 + 命中的那一行原文（或标题/词牌），
/// 以及该行里应该高亮的字符区间 [start, end)（按 line 本身的下标，闭区间前开后闭）。
class PoemSearchHit {
  final Poem poem;
  final String line;
  final int highlightStart;
  final int highlightEnd;
  PoemSearchHit({
    required this.poem,
    required this.line,
    required this.highlightStart,
    required this.highlightEnd,
  });
}

/// 在「去标点文本」里找子串，返回去标点空间里的 [start, end) 下标；找不到返回 null。
List<int>? _findIn(String haystack, String needle) {
  if (needle.isEmpty) return null;
  final i = haystack.indexOf(needle);
  if (i < 0) return null;
  return [i, i + needle.length];
}

/// 把「去标点空间」或「拼音空间」里的命中区间映射回原文下标。
(int, int) _mapToOriginal(List<int> strippedRange, _StrippedLine stripped) {
  final startStripped = strippedRange[0];
  final endStripped = strippedRange[1] - 1; // 闭区间右端点
  final origStart = stripped.origIndex[startStripped];
  final origEnd = stripped.origIndex[endStripped] + 1;
  return (origStart, origEnd);
}

(int, int) _mapPinyinToOriginal(List<int> pinyinRange, _PinyinIndex pinyin, _StrippedLine stripped) {
  final startStrippedCharIdx = pinyin.charIndexForFullPos[pinyinRange[0]];
  final endStrippedCharIdx = pinyin.charIndexForFullPos[pinyinRange[1] - 1];
  final origStart = stripped.origIndex[startStrippedCharIdx];
  final origEnd = stripped.origIndex[endStrippedCharIdx] + 1;
  return (origStart, origEnd);
}

/// 在拼音索引里找 q：优先全拼匹配，找不到再试首字母缩写匹配。
/// 返回命中区间 + 命中区间是否属于「全拼空间」（决定后续怎么映射回原文下标）。
({List<int> range, bool isFull})? _matchPinyin(_PinyinIndex py, String q) {
  final fullRange = _findIn(py.full, q);
  if (fullRange != null) return (range: fullRange, isFull: true);
  final initialsRange = _findIn(py.initials, q);
  if (initialsRange != null) return (range: initialsRange, isFull: false);
  return null;
}

/// 在诗词库里搜索：支持汉字片段（自动忽略标点）、拼音全拼、拼音首字母缩写。
/// 一首诗最多出现一条结果（优先命中原文，其次标题/词牌）。
List<PoemSearchHit> searchPoems(List<Poem> poems, String rawQuery) {
  final query = rawQuery.trim();
  if (query.isEmpty) return [];
  final isPinyinQuery = _asciiLettersRegex.hasMatch(query);
  final q = isPinyinQuery ? query.toLowerCase() : _strip(query).text;
  if (q.isEmpty) return [];

  final hits = <PoemSearchHit>[];
  for (final poem in poems) {
    final idx = _indexFor(poem);
    PoemSearchHit? hit;

    for (var i = 0; i < idx.lines.length; i++) {
      if (isPinyinQuery) {
        final m = _matchPinyin(idx.pinyinLines[i], q);
        if (m != null) {
          final (s, e) = m.isFull
              ? _mapPinyinToOriginal(m.range, idx.pinyinLines[i], idx.strippedLines[i])
              : _mapToOriginal(m.range, idx.strippedLines[i]);
          hit = PoemSearchHit(poem: poem, line: idx.lines[i], highlightStart: s, highlightEnd: e);
          break;
        }
      } else {
        final r = _findIn(idx.strippedLines[i].text, q);
        if (r != null) {
          final (s, e) = _mapToOriginal(r, idx.strippedLines[i]);
          hit = PoemSearchHit(poem: poem, line: idx.lines[i], highlightStart: s, highlightEnd: e);
          break;
        }
      }
    }

    if (hit == null) {
      if (isPinyinQuery) {
        final m = _matchPinyin(idx.pinyinTitle, q);
        if (m != null) {
          final (s, e) = m.isFull
              ? _mapPinyinToOriginal(m.range, idx.pinyinTitle, idx.strippedTitle)
              : _mapToOriginal(m.range, idx.strippedTitle);
          hit = PoemSearchHit(poem: poem, line: poem.title, highlightStart: s, highlightEnd: e);
        } else if (idx.pinyinCipai != null && _matchPinyin(idx.pinyinCipai!, q) != null) {
          hit = PoemSearchHit(poem: poem, line: poem.cipai!, highlightStart: 0, highlightEnd: poem.cipai!.length);
        }
      } else {
        final r = _findIn(idx.strippedTitle.text, q);
        if (r != null) {
          final (s, e) = _mapToOriginal(r, idx.strippedTitle);
          hit = PoemSearchHit(poem: poem, line: poem.title, highlightStart: s, highlightEnd: e);
        } else if (idx.strippedCipai != null && _findIn(idx.strippedCipai!.text, q) != null) {
          hit = PoemSearchHit(poem: poem, line: poem.cipai!, highlightStart: 0, highlightEnd: poem.cipai!.length);
        }
      }
    }

    if (hit != null) hits.add(hit);
  }
  return hits;
}
