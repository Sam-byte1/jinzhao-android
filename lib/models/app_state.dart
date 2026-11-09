import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext, InheritedNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import 'poem.dart';

/// 诗词阅读正文的字体大小偏好——只影响原文/词语解释/白话译文/创作背景，
/// 不影响导航栏、按钮这些界面文案（见 Responsive.readingScale）。
enum FontPreference {
  normal('默认'),
  medium('中号'),
  large('大号'),
  extraLarge('超大');

  final String label;
  const FontPreference(this.label);
}

class FeelNote {
  final int id;
  final String date;
  final String text;
  FeelNote({required this.id, required this.date, required this.text});

  Map<String, dynamic> toJson() => {'id': id, 'date': date, 'text': text};
  factory FeelNote.fromJson(Map<String, dynamic> j) => FeelNote(
    id: j['id'] as int,
    date: j['date'] as String,
    text: j['text'] as String,
  );
}

class PoemProgress {
  /// 收藏——一次性动作，收藏后入口收起，取消收藏只能在"我的收藏"记录里做。
  bool favorite;
  String? favoriteDate;

  /// 学习打卡计数——每次读完点一次，累加、不封顶，呼应"常读常新"的理念。
  int studyCount;
  String? lastStudyDate;

  List<FeelNote> notes;

  PoemProgress({
    this.favorite = false,
    this.favoriteDate,
    this.studyCount = 0,
    this.lastStudyDate,
    List<FeelNote>? notes,
  }) : notes = notes ?? [];

  Map<String, dynamic> toJson() => {
    'favorite': favorite,
    'favoriteDate': favoriteDate,
    'studyCount': studyCount,
    'lastStudyDate': lastStudyDate,
    'notes': notes.map((n) => n.toJson()).toList(),
  };
  factory PoemProgress.fromJson(Map<String, dynamic> j) => PoemProgress(
    favorite: j['favorite'] as bool? ?? false,
    favoriteDate: j['favoriteDate'] as String?,
    studyCount: j['studyCount'] as int? ?? 0,
    lastStudyDate: j['lastStudyDate'] as String?,
    notes: (j['notes'] as List? ?? [])
        .map((n) => FeelNote.fromJson(n as Map<String, dynamic>))
        .toList(),
  );
}

Future<List<Poem>> loadPoemsFromAssets() async {
  final jsonStr = await rootBundle.loadString('assets/data/poems.json');
  final list = jsonDecode(jsonStr) as List;
  return list.map((e) => Poem.fromJson(e as Map<String, dynamic>)).toList();
}

/// 应用状态：学习进度（收藏/打卡计数）、打卡日历、感受记录。
/// 持久化到 SharedPreferences。
class AppState extends ChangeNotifier {
  static const _prefsKey = 'mzd-poem-app-v2';
  static const _fontPrefsKey = 'mzd-poem-app-font-pref';

  List<Poem> poems = [];
  Map<String, PoemProgress> progress = {};
  Map<String, String?> checkins = {}; // dateKey(yyyy-MM-dd) -> note
  bool loaded = false;
  /// null = 用户还没手动选过，交给 [resolveFontPreference] 按设备给一个
  /// 合理的默认值（平板默认"大号"，手机默认"默认"）。一旦用户点过任意
  /// 一个档位（哪怕点的就是当前默认档），就会变成明确值并持久化下来。
  FontPreference? fontPreference;

  SharedPreferences? _prefs;

  Future<void> init() async {
    poems = await loadPoemsFromAssets();
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getString(_prefsKey);
    if (saved != null) {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      final progJson = data['progress'] as Map<String, dynamic>? ?? {};
      progress = progJson.map(
        (k, v) => MapEntry(k, PoemProgress.fromJson(v as Map<String, dynamic>)),
      );
      final checkinJson = data['checkins'] as Map<String, dynamic>? ?? {};
      checkins = checkinJson.map((k, v) => MapEntry(k, v as String?));
    }
    final savedFontPref = _prefs!.getString(_fontPrefsKey);
    if (savedFontPref != null) {
      fontPreference = FontPreference.values.firstWhere(
        (f) => f.name == savedFontPref,
        orElse: () => FontPreference.normal,
      );
    }
    // 否则 fontPreference 保持 null，由 resolveFontPreference 按设备给默认值。
    for (final p in poems) {
      progress.putIfAbsent(p.id, () => PoemProgress());
    }
    loaded = true;
    notifyListeners();
  }

  /// [isTablet] 由调用方传入（来自 Responsive.isTablet(context)），
  /// 这里不依赖 BuildContext，保持 AppState 本身跟 UI 层解耦。
  FontPreference resolveFontPreference(bool isTablet) =>
      fontPreference ?? (isTablet ? FontPreference.large : FontPreference.normal);

  Future<void> setFontPreference(FontPreference pref) async {
    if (fontPreference == pref) return;
    fontPreference = pref;
    await _prefs?.setString(_fontPrefsKey, pref.name);
    notifyListeners();
  }

  Future<void> _persist() async {
    final data = {
      'progress': progress.map((k, v) => MapEntry(k, v.toJson())),
      'checkins': checkins,
    };
    await _prefs?.setString(_prefsKey, jsonEncode(data));
  }

  PoemProgress progressFor(String id) =>
      progress.putIfAbsent(id, () => PoemProgress());

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _todayLabel() {
    final d = DateTime.now();
    return '${d.year}年${d.month}月${d.day}日';
  }

  /// 收藏——只能从未收藏变为已收藏，入口收起后只能在"我的收藏"里取消。
  Future<void> markFavorite(String poemId) async {
    final p = progressFor(poemId);
    if (p.favorite) return;
    p.favorite = true;
    p.favoriteDate = _todayLabel();
    await _persist();
    notifyListeners();
  }

  /// 在"我的收藏"记录里取消收藏。
  Future<void> unfavorite(String poemId) async {
    final p = progressFor(poemId);
    p.favorite = false;
    p.favoriteDate = null;
    await _persist();
    notifyListeners();
  }

  /// 学习打卡计数 +1，并顺手把当天记入打卡日历（如果今天还没打卡）。
  Future<void> recordStudy(String poemId) async {
    final p = progressFor(poemId);
    p.studyCount += 1;
    p.lastStudyDate = _todayLabel();
    checkins.putIfAbsent(_todayKey(), () => '');
    await _persist();
    notifyListeners();
  }

  Future<void> addNote(String poemId, String text) async {
    final p = progressFor(poemId);
    p.notes.add(
      FeelNote(
        id: DateTime.now().millisecondsSinceEpoch,
        date: _todayLabel(),
        text: text,
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> deleteNote(String poemId, int noteId) async {
    final p = progressFor(poemId);
    p.notes.removeWhere((n) => n.id == noteId);
    await _persist();
    notifyListeners();
  }

  /// 编辑已有感受记录；日期更新为编辑当天，视为"最后修改时间"。
  Future<void> updateNote(String poemId, int noteId, String text) async {
    final p = progressFor(poemId);
    final idx = p.notes.indexWhere((n) => n.id == noteId);
    if (idx == -1) return;
    p.notes[idx] = FeelNote(id: noteId, date: _todayLabel(), text: text);
    await _persist();
    notifyListeners();
  }

  Future<void> setCheckin(String dateKey, String? note) async {
    checkins[dateKey] = note ?? '';
    await _persist();
    notifyListeners();
  }

  Future<void> removeCheckin(String dateKey) async {
    checkins.remove(dateKey);
    await _persist();
    notifyListeners();
  }

  int get favoriteCount =>
      poems.where((p) => progressFor(p.id).favorite).length;
  int get studiedCount =>
      poems.where((p) => progressFor(p.id).studyCount > 0).length;
  int get researchedCount => poems.where((p) => p.isResearched).length;
  int get authoritativeCount => poems.where((p) => p.authoritative).length;

  List<MapEntry<Poem, FeelNote>> get allNotesWithPoem {
    final list = <MapEntry<Poem, FeelNote>>[];
    for (final p in poems) {
      for (final n in progressFor(p.id).notes) {
        list.add(MapEntry(p, n));
      }
    }
    return list;
  }
}

/// 让 AppState 在整个组件树里都能通过 context 直接拿到，
/// 不用层层传参——目前主要给 Responsive.typeScale 读取字体偏好用。
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope 没有包裹在组件树里');
    return scope!.notifier!;
  }
}
