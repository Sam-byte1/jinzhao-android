import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'poem.dart';

class FeelNote {
  final int id;
  final String date;
  final String text;
  FeelNote({required this.id, required this.date, required this.text});

  Map<String, dynamic> toJson() => {'id': id, 'date': date, 'text': text};
  factory FeelNote.fromJson(Map<String, dynamic> j) =>
      FeelNote(id: j['id'] as int, date: j['date'] as String, text: j['text'] as String);
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

  List<Poem> poems = [];
  Map<String, PoemProgress> progress = {};
  Map<String, String?> checkins = {}; // dateKey(yyyy-MM-dd) -> note
  bool loaded = false;

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
    } else {
      _seedDemoState();
    }
    for (final p in poems) {
      progress.putIfAbsent(p.id, () => PoemProgress());
    }
    loaded = true;
    notifyListeners();
  }

  void _seedDemoState() {
    final now = DateTime.now();
    String daysAgoKey(int n) {
      final d = now.subtract(Duration(days: n));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    String daysAgoLabel(int n) {
      final d = now.subtract(Duration(days: n));
      return '${d.year}年${d.month}月${d.day}日';
    }

    progress['qyc-xue'] = PoemProgress(
      favorite: true,
      favoriteDate: daysAgoLabel(6),
      studyCount: 2,
      lastStudyDate: daysAgoLabel(1),
      notes: [FeelNote(id: 1, date: daysAgoLabel(6), text: '第一次完整读完，被"数风流人物，还看今朝"击中了。')],
    );
    progress['qlcz'] = PoemProgress(studyCount: 1, lastStudyDate: daysAgoLabel(3));
    checkins[daysAgoKey(6)] = '读完《沁园春·雪》，查了背景资料。';
    checkins[daysAgoKey(3)] = '重读《七律·长征》。';
    checkins[daysAgoKey(1)] = '';
  }

  Future<void> _persist() async {
    final data = {
      'progress': progress.map((k, v) => MapEntry(k, v.toJson())),
      'checkins': checkins,
    };
    await _prefs?.setString(_prefsKey, jsonEncode(data));
  }

  PoemProgress progressFor(String id) => progress.putIfAbsent(id, () => PoemProgress());

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
    p.notes.add(FeelNote(id: DateTime.now().millisecondsSinceEpoch, date: _todayLabel(), text: text));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteNote(String poemId, int noteId) async {
    final p = progressFor(poemId);
    p.notes.removeWhere((n) => n.id == noteId);
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

  int get favoriteCount => poems.where((p) => progressFor(p.id).favorite).length;
  int get studiedCount => poems.where((p) => progressFor(p.id).studyCount > 0).length;
  int get researchedCount => poems.where((p) => p.isResearched).length;

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
