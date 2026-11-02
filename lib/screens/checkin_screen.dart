import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _dateLabel(DateTime d) => '${d.year}年${d.month}月${d.day}日';

class CheckinScreen extends StatefulWidget {
  final AppState state;
  const CheckinScreen({super.key, required this.state});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  DateTime _cursor = DateTime.now();
  late DateTime _selected;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _selectDay(DateTime d) {
    setState(() {
      _selected = d;
      _noteCtrl.text = widget.state.checkins[_dateKey(d)] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final checkins = widget.state.checkins;
        final selectedKey = _dateKey(_selected);
        final checkedToday = checkins.containsKey(selectedKey);
        if (_noteCtrl.text.isEmpty && checkedToday) {
          _noteCtrl.text = checkins[selectedKey] ?? '';
        }
        final monthCount = checkins.keys.where((k) {
          final parts = k.split('-');
          return int.parse(parts[0]) == _cursor.year && int.parse(parts[1]) == _cursor.month;
        }).length;

        final firstOfMonth = DateTime(_cursor.year, _cursor.month, 1);
        final daysInMonth = DateTime(_cursor.year, _cursor.month + 1, 0).day;
        final leadingBlanks = (firstOfMonth.weekday - 1) % 7; // 周一为首列

        final logs = checkins.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('学习足迹',
                      style: TextStyle(fontSize: 11.5, letterSpacing: 2, color: c.gold, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('打卡', style: TextStyle(fontFamily: 'serif', fontSize: 24, color: c.ink)),
                  const SizedBox(height: 2),
                  Text('不必每天打卡，记录就好', style: TextStyle(fontSize: 12.5, color: c.inkSoft)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: c.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, size: 18, color: c.inkSoft),
                            onPressed: () => setState(() => _cursor = DateTime(_cursor.year, _cursor.month - 1)),
                          ),
                          Text('${_cursor.year}年${_cursor.month}月',
                              style: TextStyle(fontFamily: 'serif', fontSize: 15, color: c.ink)),
                          IconButton(
                            icon: Icon(Icons.chevron_right, size: 18, color: c.inkSoft),
                            onPressed: () => setState(() => _cursor = DateTime(_cursor.year, _cursor.month + 1)),
                          ),
                        ]),
                        Text('本月已打卡 $monthCount 天', style: TextStyle(fontSize: 11, color: c.inkSoft)),
                      ],
                    ),
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        for (final w in ['一', '二', '三', '四', '五', '六', '日'])
                          Center(child: Text(w, style: TextStyle(fontSize: 10, color: c.inkFaint))),
                        for (var i = 0; i < leadingBlanks; i++) const SizedBox(),
                        for (var d = 1; d <= daysInMonth; d++) _dayCell(c, d, checkins, selectedKey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                decoration: BoxDecoration(
                    color: c.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_dateLabel(_selected), style: TextStyle(fontSize: 13, color: c.ink)),
                        GestureDetector(
                          onTap: () async {
                            if (checkedToday) {
                              await widget.state.removeCheckin(selectedKey);
                            } else {
                              await widget.state.setCheckin(selectedKey, _noteCtrl.text.trim());
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: checkedToday ? c.seal : c.bg,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: checkedToday ? c.seal : c.border),
                            ),
                            child: Text(checkedToday ? '已打卡' : '打卡',
                                style: TextStyle(
                                    fontSize: 11.5, color: checkedToday ? const Color(0xFFFBF5E6) : c.inkSoft)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 2,
                      style: TextStyle(color: c.ink, fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: '今天学了什么、有什么感触？（选填）',
                        hintStyle: TextStyle(color: c.inkFaint),
                        filled: true,
                        fillColor: c.bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => widget.state.setCheckin(selectedKey, _noteCtrl.text.trim()),
                        child: Text('保存', style: TextStyle(color: c.ink, fontSize: 11.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text('打卡记录', style: TextStyle(fontSize: 11.5, color: c.inkFaint, letterSpacing: 1)),
            ),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(child: Text('还没有打卡记录', style: TextStyle(color: c.inkFaint, fontSize: 12))),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    for (final k in logs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                              color: c.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 56,
                                child: Text('${k.split('-')[1]}/${k.split('-')[2]}',
                                    style: TextStyle(fontFamily: 'serif', fontSize: 13, color: c.sealDeep)),
                              ),
                              Expanded(
                                child: Text(
                                  (checkins[k]?.isNotEmpty ?? false) ? checkins[k]! : '（无备注）',
                                  style: TextStyle(fontSize: 12, color: c.inkSoft, height: 1.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _dayCell(AppColors c, int day, Map<String, String?> checkins, String selectedKey) {
    final d = DateTime(_cursor.year, _cursor.month, day);
    final key = _dateKey(d);
    final isToday = key == _dateKey(DateTime.now());
    final isSelected = key == selectedKey;
    final checked = checkins.containsKey(key);
    return GestureDetector(
      onTap: () => _selectDay(d),
      child: Container(
        decoration: BoxDecoration(
          color: checked ? c.sealWash : (isSelected ? c.bgSunk : Colors.transparent),
          borderRadius: BorderRadius.circular(9),
          border: isToday ? Border.all(color: c.gold) : null,
        ),
        alignment: Alignment.center,
        child: Text('$day',
            style: TextStyle(
                fontSize: 11.5,
                color: checked ? c.sealDeep : c.inkSoft,
                fontWeight: checked ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}
