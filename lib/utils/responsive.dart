import 'package:flutter/widgets.dart';
import '../models/app_state.dart';

/// 平板适配：字号缩放 + 阅读区限宽。
/// 断点参照 Material Design 的 medium(600dp)/expanded(840dp) 分档，
/// 对应手机、竖屏平板、横屏平板三档。
///
/// 这里明确拆成两套缩放，不要混用：
/// - [typeScale] / `context.sp()`：只跟屏幕宽度有关，给导航栏、按钮、
///   列表标题这类"界面文案"用。不受用户的字体大小偏好影响——如果所有
///   UI 文案都跟着放大，按钮、标题会显得比例失调，反而不好看。
/// - [readingScale] / `context.rsp()`：在屏幕宽度的基础上再叠加用户在
///   "我的"页面自选的字体偏好（默认/中号/大号/超大），只给诗词原文、
///   词语解释、白话译文、创作背景这些"阅读正文"用。
class Responsive {
  static double _deviceBase(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 840) return 1.4;
    if (w >= 600) return 1.2;
    return 1.0;
  }

  static double typeScale(BuildContext context) => _deviceBase(context);

  static double readingScale(BuildContext context) {
    final base = _deviceBase(context);
    final pref = AppScope.of(context).resolveFontPreference(isTablet(context));
    switch (pref) {
      case FontPreference.normal:
        return base;
      case FontPreference.medium:
        return base + 0.15;
      case FontPreference.large:
        return base + 0.3;
      case FontPreference.extraLarge:
        return base + 0.45;
    }
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  /// 文字内容区的推荐最大宽度：屏幕越宽，诗词原文/译文一行拉得越长，
  /// 阅读体验反而变差，所以超过这个宽度后居中、不再继续撑满。
  static const double maxReadingWidth = 720;

  /// 列表/卡片类页面整体内容的最大宽度，比纯文字阅读区更宽一些。
  static const double maxContentWidth = 1000;

  /// 把 child 限制在 [maxWidth] 以内并居中；窄屏下 maxWidth 大于屏宽，
  /// 效果等同于铺满，不需要额外判断手机/平板。
  static Widget centered(Widget child, {double maxWidth = maxReadingWidth}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

extension ResponsiveFont on BuildContext {
  /// 界面文案字号：只随屏幕宽度变化，不受阅读字体偏好影响。
  double sp(double base) => base * Responsive.typeScale(this);

  /// 诗词阅读正文字号：屏幕宽度 + 用户自选的阅读字体偏好。
  double rsp(double base) => base * Responsive.readingScale(this);
}
