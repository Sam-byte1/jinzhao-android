import 'package:flutter/material.dart';

/// 色彩 token：宣纸 + 水墨 + 朱砂印泥的配色体系，对应原型稿 prototype.html 的 CSS 变量。
class AppColors {
  final Color bg;
  final Color bgCard;
  final Color bgSunk;
  final Color ink;
  final Color inkSoft;
  final Color inkFaint;
  final Color seal;
  final Color sealDeep;
  final Color sealWash;
  final Color gold;
  final Color border;
  final Color mist;

  const AppColors({
    required this.bg,
    required this.bgCard,
    required this.bgSunk,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.seal,
    required this.sealDeep,
    required this.sealWash,
    required this.gold,
    required this.border,
    required this.mist,
  });

  static const light = AppColors(
    bg: Color(0xFFF2ECDC),
    bgCard: Color(0xFFEAE1CC),
    bgSunk: Color(0xFFE2D7BD),
    ink: Color(0xFF2B2520),
    inkSoft: Color(0xFF6B5F4F),
    inkFaint: Color(0xFF9A8E79),
    seal: Color(0xFFAC3B2A),
    sealDeep: Color(0xFF8A2E21),
    sealWash: Color(0x1EAC3B2A),
    gold: Color(0xFFA47C3E),
    border: Color(0xFFD8CBA9),
    mist: Color(0xFF9FB0B8),
  );

  static const dark = AppColors(
    bg: Color(0xFF1C1814),
    bgCard: Color(0xFF262019),
    bgSunk: Color(0xFF17130F),
    ink: Color(0xFFEDE3CF),
    inkSoft: Color(0xFFB3A68C),
    inkFaint: Color(0xFF776A54),
    seal: Color(0xFFD1604A),
    sealDeep: Color(0xFFE3795F),
    sealWash: Color(0x2ED1604A),
    gold: Color(0xFFC9A06A),
    border: Color(0xFF3A3226),
    mist: Color(0xFF4C5E66),
  );

  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}
