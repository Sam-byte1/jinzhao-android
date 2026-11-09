import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

enum _ReadState { idle, playing, paused }

/// 朗读按钮：调用系统自带的语音引擎朗读诗词原文，不联网、不上传数据。
/// 点一下开始朗读，再点一下暂停，暂停后再点一下继续；朗读完自动回到初始状态。
class ReadAloudButton extends StatefulWidget {
  final String text;
  const ReadAloudButton({super.key, required this.text});

  @override
  State<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends State<ReadAloudButton> {
  final FlutterTts _tts = FlutterTts();
  _ReadState _state = _ReadState.idle;
  bool _ready = false;
  // 安卓的 TTS 引擎不支持真正的"暂停后从原位置继续"，这里用 onProgress
  // 记录朗读到的字符偏移量，暂停后点"继续"时从这个偏移量重新 speak() 剩余文字。
  int _resumeOffset = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.42); // 古诗词语速放慢一些，比日常说话更清楚
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _state = _ReadState.idle;
          _resumeOffset = 0;
        });
      }
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _state = _ReadState.idle);
    });
    _tts.setErrorHandler((msg) {
      if (mounted) setState(() => _state = _ReadState.idle);
    });
    _tts.setProgressHandler((text, start, end, word) {
      _resumeOffset = start;
    });
    if (mounted) setState(() => _ready = true);
  }

  @override
  void didUpdateWidget(covariant ReadAloudButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _tts.stop();
      _state = _ReadState.idle;
      _resumeOffset = 0;
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_ready) return;
    switch (_state) {
      case _ReadState.idle:
        _resumeOffset = 0;
        setState(() => _state = _ReadState.playing);
        await _tts.speak(widget.text);
        break;
      case _ReadState.playing:
        setState(() => _state = _ReadState.paused);
        await _tts.pause();
        break;
      case _ReadState.paused:
        setState(() => _state = _ReadState.playing);
        final remaining = widget.text.substring(_resumeOffset.clamp(0, widget.text.length));
        await _tts.speak(remaining.isEmpty ? widget.text : remaining);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final icon = switch (_state) {
      _ReadState.idle => Icons.volume_up_rounded,
      _ReadState.playing => Icons.pause_rounded,
      _ReadState.paused => Icons.play_arrow_rounded,
    };
    final size = context.sp(18);
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: EdgeInsets.all(context.sp(6)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _state == _ReadState.idle ? c.bgCard : c.sealWash,
          border: Border.all(color: _state == _ReadState.idle ? c.border : c.seal),
        ),
        child: Icon(icon, size: size, color: _state == _ReadState.idle ? c.inkSoft : c.sealDeep),
      ),
    );
  }
}
