import 'package:flutter/material.dart';
import 'package:simda_mobile/providers/auth_provider.dart';
import 'package:simda_mobile/screens/dashboard_screen.dart';
import 'package:simda_mobile/screens/auth/login_screen.dart';
import 'package:simda_mobile/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SimdaApp());
}

class SimdaApp extends StatelessWidget {
  const SimdaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Simda Barang',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
        },
      ),
    );
  }
}
