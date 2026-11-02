const _chineseDigits = ['', '一', '两', '三', '四', '五', '六', '七', '八', '九', '十'];

/// 把 1~10 转成中文数字，超过10用阿拉伯数字（打卡次数不会频繁超过两位数，没必要穷举）。
String chineseCount(int n) {
  if (n >= 1 && n <= 10) return _chineseDigits[n];
  return '$n';
}
