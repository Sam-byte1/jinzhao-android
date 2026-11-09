import 'package:flutter/widgets.dart';

/// 平板适配：字号缩放 + 阅读区限宽。
/// 断点参照 Material Design 的 medium(600dp)/expanded(840dp) 分档，
/// 对应手机、竖屏平板、横屏平板三档。
class Responsive {
  static double typeScale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 840) return 1.3;
    if (w >= 600) return 1.15;
    return 1.0;
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
  /// 按屏幕宽度缩放字号；[base] 是手机上的基准字号。
  double sp(double base) => base * Responsive.typeScale(this);
}
