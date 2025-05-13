import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/sensor_data_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default: System Theme

  @override
  void initState() {
    super.initState();
    _themeMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flood Monitoring System',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(toggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  AuthWrapper({required this.toggleTheme, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return SensorDataScreen(toggleTheme: toggleTheme, themeMode: themeMode);
        }
        return LoginScreen(toggleTheme: toggleTheme, themeMode: themeMode);
      },
    );
  }
}
