import 'package:flutter/material.dart';
import '../models/poem.dart';
import 'illustration.dart';

/// 诗词详情页顶部的大图横幅：如果这首诗配了手迹/历史照片等真实图片，
/// 就展示一个可左右滑动的轮播（附来源说明）；没有的话退回原来的通用水墨插画，
/// 行为和之前完全一样。
class PoemBanner extends StatefulWidget {
  final Poem poem;
  const PoemBanner({super.key, required this.poem});

  @override
  State<PoemBanner> createState() => _PoemBannerState();
}

class _PoemBannerState extends State<PoemBanner> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.poem.images;
    if (images.isEmpty) {
      return PoemIllustration(poem: widget.poem);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, i) => Image.asset(
            images[i].asset,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3000000)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (images[_page].caption != null)
                  Expanded(
                    child: Text(
                      images[_page].caption!,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xCCFFFFFF)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),
                if (images.length > 1) ...[
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(images.length, (i) {
                      final active = i == _page;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: active ? 12 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: active ? .95 : .5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
