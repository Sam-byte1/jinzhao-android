import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import '../data/pinyin_lines.dart';
import '../models/poem.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

const _punctuation = {
  '，', '。', '；', '：', '！', '？', '、',
  '“', '”', '‘', '’',
  '（', '）', '《', '》', '·', '—', '…', '［', '］', '【', '】',
};

class _Token {
  final String char;
  final String? pinyin;
  _Token(this.char, this.pinyin);
}

List<_Token> _parsePinyinLine(String line) {
  return line
      .split(' ')
      .where((t) => t.isNotEmpty)
      .map((tok) {
        final i = tok.indexOf('/');
        if (i < 0) return _Token(tok, null);
        return _Token(tok.substring(0, i), tok.substring(i + 1));
      })
      .toList();
}

List<_Token> _plainTokens(String line) {
  return line.split('').map((c) => _Token(c, null)).toList();
}

/// 没有人工标注拼音的诗词，用拼音库按字实时生成注音（多音字取词库首选读音，
/// 常见多音字的准确率已经足够日常阅读使用，不追求100%精确）。
List<_Token> _autoPinyinTokens(String line) {
  return line.split('').map((ch) {
    final arr = PinyinHelper.convertCharToPinyinArray(ch);
    return _Token(ch, arr.isEmpty ? null : arr.first);
  }).toList();
}

/// 逐字比对词语解释列表，标出每个字符属于第几条解释（最长匹配优先，不重叠）。
List<int> _markGloss(List<String> chars, List<GlossEntry> gloss) {
  final marks = List<int>.filled(chars.length, 0);
  final order = List.generate(gloss.length, (i) => MapEntry(gloss[i].word, i + 1));
  order.sort((a, b) => b.key.length.compareTo(a.key.length));
  for (final entry in order) {
    final w = entry.key;
    final idx = entry.value;
    final wlen = w.length;
    for (var start = 0; start <= chars.length - wlen; start++) {
      var clash = false;
      for (var k = 0; k < wlen; k++) {
        if (marks[start + k] != 0) {
          clash = true;
          break;
        }
      }
      if (clash) continue;
      if (chars.sublist(start, start + wlen).join() == w) {
        for (var k2 = 0; k2 < wlen; k2++) {
          marks[start + k2] = idx;
        }
      }
    }
  }
  return marks;
}

class _Run {
  final List<_Token> tokens;
  final int glossIdx;
  _Run(this.tokens, this.glossIdx);
}

List<_Run> _groupRuns(List<_Token> tokens, List<int> marks) {
  final runs = <_Run>[];
  var i = 0;
  while (i < tokens.length) {
    final m = marks[i];
    if (m == 0) {
      runs.add(_Run([tokens[i]], 0));
      i++;
    } else {
      var j = i;
      while (j < tokens.length && marks[j] == m) {
        j++;
      }
      runs.add(_Run(tokens.sublist(i, j), m));
      i = j;
    }
  }
  return runs;
}

/// 原文渲染：词语解释角标高亮 + 点击跳转；拼音注音对全部诗词生效——
/// 有人工校对的几首用校对过的拼音，其余诗词由拼音库实时生成。
class VerseText extends StatefulWidget {
  final Poem poem;
  final bool showPinyin;
  final double fontSize;
  final TextAlign textAlign;
  final void Function(int glossIndex)? onGlossTap;

  const VerseText({
    super.key,
    required this.poem,
    this.showPinyin = true,
    this.fontSize = 16,
    this.textAlign = TextAlign.start,
    this.onGlossTap,
  });

  @override
  State<VerseText> createState() => _VerseTextState();
}

class _VerseTextState extends State<VerseText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _recognizerFor(int glossIdx) {
    final r = TapGestureRecognizer()..onTap = () => widget.onGlossTap?.call(glossIdx);
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final c = AppColors.of(context);
    final poem = widget.poem;
    final pyLines = pinyinLines[poem.id];
    final lines = poem.lines;
    final scale = Responsive.typeScale(context);
    final crossAlign =
        widget.textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: List.generate(lines.length, (i) {
        List<_Token> tokens;
        if (!widget.showPinyin) {
          tokens = _plainTokens(lines[i]);
        } else if (pyLines != null) {
          tokens = _parsePinyinLine(pyLines[i]); // 人工校对过的拼音，优先使用
        } else {
          tokens = _autoPinyinTokens(lines[i]); // 拼音库实时生成
        }
        final marks = _markGloss(tokens.map((t) => t.char).toList(), poem.gloss);
        return Padding(
          padding: EdgeInsets.only(bottom: 6 * scale),
          child: widget.showPinyin
              ? _buildPinyinLine(c, tokens, marks, scale)
              : _buildPlainLine(c, tokens, marks, scale),
        );
      }),
    );
  }

  Widget _buildPlainLine(AppColors c, List<_Token> tokens, List<int> marks, double scale) {
    final runs = _groupRuns(tokens, marks);
    final badgeSize = 10 * scale;
    final spans = <InlineSpan>[];
    for (final run in runs) {
      final text = run.tokens.map((t) => t.char).join();
      if (run.glossIdx == 0) {
        final isPunct = _punctuation.contains(text);
        spans.add(TextSpan(text: text, style: TextStyle(color: isPunct ? c.inkFaint : c.ink)));
      } else {
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            color: c.ink,
            decoration: TextDecoration.underline,
            decorationColor: c.gold,
            decorationStyle: TextDecorationStyle.dotted,
          ),
          recognizer: _recognizerFor(run.glossIdx),
        ));
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: GestureDetector(
            onTap: () => widget.onGlossTap?.call(run.glossIdx),
            child: Text('${run.glossIdx}',
                style: TextStyle(fontSize: badgeSize, color: c.sealDeep, fontWeight: FontWeight.w700)),
          ),
        ));
      }
    }
    return RichText(
      textAlign: widget.textAlign,
      text: TextSpan(
        style: TextStyle(fontFamily: 'serif', fontSize: widget.fontSize, height: 1.9, color: c.ink),
        children: spans,
      ),
    );
  }

  Widget _buildPinyinLine(AppColors c, List<_Token> tokens, List<int> marks, double scale) {
    final runs = _groupRuns(tokens, marks);
    final badgeSize = 10 * scale;
    final items = <Widget>[];
    for (final run in runs) {
      final group = Row(mainAxisSize: MainAxisSize.min, children: [
        for (final t in run.tokens) _rubyChar(c, t, scale, highlighted: run.glossIdx != 0),
      ]);
      if (run.glossIdx == 0) {
        items.add(group);
      } else {
        items.add(GestureDetector(
          onTap: () => widget.onGlossTap?.call(run.glossIdx),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.gold, width: 1)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              group,
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 1),
                child: Text('${run.glossIdx}',
                    style:
                        TextStyle(fontSize: badgeSize, color: c.sealDeep, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ));
      }
    }
    return Wrap(crossAxisAlignment: WrapCrossAlignment.end, children: items);
  }

  Widget _rubyChar(AppColors c, _Token t, double scale, {required bool highlighted}) {
    final isPunct = t.pinyin == null;
    final pinyinSize = 9.5 * scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 12 * scale,
            child: t.pinyin != null
                ? Text(t.pinyin!, style: TextStyle(fontSize: pinyinSize, color: c.inkSoft))
                : null,
          ),
          Text(
            t.char,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: widget.fontSize,
              color: isPunct && !highlighted ? c.inkFaint : c.ink,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
