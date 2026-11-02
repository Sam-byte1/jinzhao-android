/// 把一段白话译文拆成一句一行的段落列表，读起来有节奏感。
/// 先按阕/段的分隔符切（兼容旧内容里残留的 HTML <br><br> 标记——原生 App 不会解析
/// HTML，留着不处理的话会把"<br><br>"这几个字符原样显示出来，这里顺手修掉），
/// 再按句末标点（。！？）切成一句一段。
List<String> splitIntoParagraphs(String text) {
  final stanzas = text.split(RegExp(r'<br\s*/?>\s*<br\s*/?>|\n{2,}'));
  final result = <String>[];
  for (final stanza in stanzas) {
    final cleaned = stanza.replaceAll(RegExp(r'<br\s*/?>'), '');
    final buffer = StringBuffer();
    for (final ch in cleaned.split('')) {
      buffer.write(ch);
      if (ch == '。' || ch == '！' || ch == '？') {
        final sentence = buffer.toString().trim();
        if (sentence.isNotEmpty) result.add(sentence);
        buffer.clear();
      }
    }
    final rest = buffer.toString().trim();
    if (rest.isNotEmpty) result.add(rest);
  }
  return result;
}
