class GlossEntry {
  final String word;
  final String def;
  GlossEntry({required this.word, required this.def});

  factory GlossEntry.fromJson(Map<String, dynamic> json) {
    return GlossEntry(word: json['w'] as String, def: json['d'] as String);
  }
}

class PoemImage {
  final String asset;
  final String? caption;
  PoemImage({required this.asset, this.caption});

  factory PoemImage.fromJson(Map<String, dynamic> json) {
    return PoemImage(asset: json['asset'] as String, caption: json['caption'] as String?);
  }
}

class PoemVariant {
  final String label;
  final List<List<String>> stanzas;
  PoemVariant({required this.label, required this.stanzas});

  factory PoemVariant.fromJson(Map<String, dynamic> json) {
    return PoemVariant(
      label: json['label'] as String,
      stanzas: (json['stanzas'] as List)
          .map((s) => (s as List).map((l) => l as String).toList())
          .toList(),
    );
  }
}

class Poem {
  final int seq;
  final String id;
  final String title;
  final String category;
  final String? cipai;
  final String? date;
  final bool pre1949;
  final String? subtitle;
  final String? preface;
  final String? groupTitle;
  final String? groupLabel;
  final bool collaborative;
  final String? coauthorNote;
  final bool disputedAuthorship;
  final String? disputedNote;
  final String? dataNote;
  final List<PoemVariant>? variants;
  final List<List<String>> stanzas;
  final List<GlossEntry> gloss;
  final String? vernacular;
  final String? background;
  final String contentStatus;
  final String? illuKey;
  final bool authoritative;
  final List<PoemImage> images;

  Poem({
    required this.seq,
    required this.id,
    required this.title,
    required this.category,
    this.cipai,
    this.date,
    required this.pre1949,
    this.subtitle,
    this.preface,
    this.groupTitle,
    this.groupLabel,
    required this.collaborative,
    this.coauthorNote,
    required this.disputedAuthorship,
    this.disputedNote,
    this.dataNote,
    this.variants,
    required this.stanzas,
    required this.gloss,
    this.vernacular,
    this.background,
    required this.contentStatus,
    this.illuKey,
    required this.authoritative,
    this.images = const [],
  });

  bool get isResearched => contentStatus == 'researched';

  /// 诗词原文按行展开（不分阕），供逐行渲染。
  List<String> get lines => stanzas.expand((s) => s).toList();

  /// 展示用的副标题，如"七律 · 1935年10月"或"词 · 沁园春 · 1936年2月"。
  String get meta {
    final kind = cipai != null ? '$category·$cipai' : category;
    return '$kind · ${date ?? '年代不详'}';
  }

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      seq: json['seq'] as int,
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      cipai: json['cipai'] as String?,
      date: json['date'] as String?,
      pre1949: json['pre1949'] as bool? ?? false,
      subtitle: json['subtitle'] as String?,
      preface: json['preface'] as String?,
      groupTitle: json['groupTitle'] as String?,
      groupLabel: json['groupLabel'] as String?,
      collaborative: json['collaborative'] as bool? ?? false,
      coauthorNote: json['coauthorNote'] as String?,
      disputedAuthorship: json['disputedAuthorship'] as bool? ?? false,
      disputedNote: json['disputedNote'] as String?,
      dataNote: json['dataNote'] as String?,
      variants: (json['variants'] as List?)
          ?.map((v) => PoemVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      stanzas: (json['stanzas'] as List)
          .map((s) => (s as List).map((l) => l as String).toList())
          .toList(),
      gloss: (json['gloss'] as List? ?? [])
          .map((g) => GlossEntry.fromJson(g as Map<String, dynamic>))
          .toList(),
      vernacular: json['vernacular'] as String?,
      background: json['background'] as String?,
      contentStatus: json['contentStatus'] as String? ?? 'pending',
      illuKey: json['illuKey'] as String?,
      authoritative: json['authoritative'] as bool? ?? false,
      images: (json['images'] as List? ?? [])
          .map((i) => PoemImage.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
