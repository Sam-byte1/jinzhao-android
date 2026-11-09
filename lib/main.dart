import 'package:flutter/material.dart';
import 'models/app_state.dart';
import 'screens/root_shell.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const JinzhaoApp());
}

class JinzhaoApp extends StatefulWidget {
  const JinzhaoApp({super.key});

  @override
  State<JinzhaoApp> createState() => _JinzhaoAppState();
}

class _JinzhaoAppState extends State<JinzhaoApp> {
  final AppState _state = AppState();
  late Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _state.init();
  }

  ThemeData _buildTheme(AppColors c, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: c.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.seal,
        brightness: brightness,
        surface: c.bg,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: '今朝 · 毛泽东诗词',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(AppColors.light, Brightness.light),
        darkTheme: _buildTheme(AppColors.dark, Brightness.dark),
        themeMode: ThemeMode.system,
        home: FutureBuilder<void>(
          future: _ready,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('加载失败：${snapshot.error}')),
              );
            }
            return RootShell(state: _state);
          },
        ),
      ),
    );
  }
}
