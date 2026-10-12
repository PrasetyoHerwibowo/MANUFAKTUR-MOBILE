import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'core/theme/app_theme.dart';
import 'screens/user/auth/login_screen.dart';
import 'screens/user/user_main_layout.dart';
import 'screens/admin/admin_main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ManufakturApp(),
    ),
  );
}

class ManufakturApp extends StatelessWidget {
  const ManufakturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        Widget mainScreen;

        if (appState.appMode == AppMode.admin) {
          mainScreen = const AdminMainLayout();
        } else {
          mainScreen = appState.isLoggedIn
              ? const UserMainLayout()
              : const LoginScreen();
        }

        return MaterialApp(
          title: 'PT Manufactur Dynamic Indonesia',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          home: mainScreen,
        );
      },
    );
  }
}
