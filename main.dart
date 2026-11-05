import 'package:flutter/material.dart';

import 'screens/app_state.dart';
import 'screens/new_welcome_page.dart';
import 'theme/theme.dart';

void main() {
  runApp(const VossiesVibeApp());
}

class VossiesVibeApp extends StatefulWidget {
  const VossiesVibeApp({super.key});

  @override
  State<VossiesVibeApp> createState() => _VossiesVibeAppState();
}

class _VossiesVibeAppState extends State<VossiesVibeApp> {
  late final Future<AppState> _stateFuture = AppState.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Could not load app data: ${snapshot.error}',
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final state = snapshot.data!;
        return AppScope(
          state: state,
          child: AnimatedBuilder(
            animation: state,
            builder: (context, _) => MaterialApp(
              title: 'Vossie Vibe',
              debugShowCheckedModeBanner: false,
              theme: buildTheme(Brightness.light, accents[state.accentIndex]),
              darkTheme: buildTheme(
                Brightness.dark,
                accents[state.accentIndex],
              ),
              themeMode: state.themeMode,
              home: const NewWelcomePage(),
            ),
          ),
        );
      },
    );
  }
}
