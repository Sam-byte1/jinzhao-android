import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'checkin_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  final AppState state;
  const RootShell({super.key, required this.state});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final screens = [
      HomeScreen(state: widget.state),
      CheckinScreen(state: widget.state),
      ProfileScreen(state: widget.state),
    ];
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(child: IndexedStack(index: _tab, children: screens)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _navItem(c, 0, Icons.menu_book_outlined, '诗'),
                _navItem(c, 1, Icons.edit_calendar_outlined, '打卡'),
                _navItem(c, 2, Icons.person_outline, '我的'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(AppColors c, int index, IconData icon, String label) {
    final active = _tab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: active ? c.seal : c.inkFaint),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: active ? c.seal : c.inkFaint, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
