import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/poem.dart';

const _illuKeys = ['snow', 'march', 'plum', 'ink'];

/// 诗词插画：复用一组通用水墨风插画模板，而非每首诗单独画一张（见 data/README.md）。
String illuAssetFor(Poem poem) {
  final key = (poem.illuKey != null && _illuKeys.contains(poem.illuKey))
      ? poem.illuKey!
      : _illuKeys[poem.seq % _illuKeys.length];
  return 'assets/illustrations/$key.svg';
}

class PoemIllustration extends StatelessWidget {
  final Poem poem;
  final BorderRadius? borderRadius;
  const PoemIllustration({super.key, required this.poem, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      illuAssetFor(poem),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
    if (borderRadius == null) return svg;
    return ClipRRect(borderRadius: borderRadius!, child: svg);
  }
}
