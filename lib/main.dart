import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/booking/book_service_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tyre/add_tyre_screen.dart';
import 'screens/tyre/tyre_detail_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TyreTrackApp());
}

class TyreTrackApp extends StatelessWidget {
  const TyreTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tyre Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_tyre': (context) => const AddTyreScreen(),
        '/tyre_detail': (context) => const TyreDetailScreen(),
        '/book_service': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final tyreId = args is String ? args : '';
          return BookServiceScreen(tyreId: tyreId);
        },
      },
    );
  }

}
