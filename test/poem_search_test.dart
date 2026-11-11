import 'package:flutter_test/flutter_test.dart';
import 'package:jinzhao/models/poem.dart';
import 'package:jinzhao/utils/poem_search.dart';

Poem _poem({
  required String id,
  required String title,
  String? cipai,
  required List<List<String>> stanzas,
}) {
  return Poem(
    seq: 1,
    id: id,
    title: title,
    category: cipai != null ? '词' : '诗',
    cipai: cipai,
    pre1949: true,
    collaborative: false,
    disputedAuthorship: false,
    stanzas: stanzas,
    gloss: const [],
    contentStatus: 'researched',
  );
}

void main() {
  final poems = [
    _poem(
      id: 'qyc-xue',
      title: '沁园春·雪',
      cipai: '沁园春',
      stanzas: [
        ['北国风光，千里冰封，万里雪飘。', '望长城内外，惟余莽莽；大河上下，顿失滔滔。'],
      ],
    ),
    _poem(
      id: 'p028',
      title: '沁园春·长沙',
      cipai: '沁园春',
      stanzas: [
        ['独立寒秋，湘江北去，橘子洲头。', '看万山红遍，层林尽染；漫江碧透，百舸争流。'],
      ],
    ),
  ];

  test('汉字子串命中原文（跳过标点）', () {
    final hits = searchPoems(poems, '红遍层林尽染');
    expect(hits.map((h) => h.poem.id), ['p028']);
    final hit = hits.first;
    expect(hit.line.substring(hit.highlightStart, hit.highlightEnd), '红遍，层林尽染');
  });

  test('标题命中', () {
    final hits = searchPoems(poems, '长沙');
    expect(hits.map((h) => h.poem.id), ['p028']);
  });

  test('词牌命中', () {
    final hits = searchPoems(poems, '沁园春');
    expect(hits.length, 2);
  });

  test('拼音全拼命中', () {
    final hits = searchPoems(poems, 'wanlixuepiao');
    expect(hits.map((h) => h.poem.id), ['qyc-xue']);
  });

  test('拼音首字母缩写命中', () {
    final hits = searchPoems(poems, 'cljr'); // 层林尽染
    expect(hits.map((h) => h.poem.id), ['p028']);
  });

  test('空查询返回空列表', () {
    expect(searchPoems(poems, ''), isEmpty);
    expect(searchPoems(poems, '   '), isEmpty);
  });

  test('查无结果返回空列表', () {
    expect(searchPoems(poems, '不存在的句子'), isEmpty);
  });
}
