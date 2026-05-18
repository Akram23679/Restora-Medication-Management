import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'provider.dart';
import 'screens/onboarding.dart';
import 'screens/shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: const RestoraApp(),
    ),
  );
}

class RestoraApp extends StatelessWidget {
  const RestoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Restora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode:
          provider.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: provider.isLoading
          ? const _SplashScreen()
          : provider.isOnboarded
              ? const MainShell()
              : const OnboardingScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.opacity,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(height: 20),
            Text('Restora',
                style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 32,
                    color: c.textDark)),
            const SizedBox(height: 8),
            Text('YOUR DAILY RITUAL',
                style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11,
                    letterSpacing: 2,
                    color: c.textLight)),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(c.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}