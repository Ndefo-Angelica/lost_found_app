import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/alerts_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/item_listing_screen.dart';
import 'screens/report_item_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/alerts_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
      ],
      child: MaterialApp(
        title: 'Lost & Found Cameroon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/items': (context) => const ItemListingScreen(),
          '/report': (context) => const ReportItemScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/alerts': (context) => const AlertsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name?.startsWith('/item/') ?? false) {
            final itemId = settings.name!.substring(6);
            return MaterialPageRoute(
              builder: (_) => ItemDetailScreen(itemId: itemId),
            );
          }
          return null;
        },
      ),
    );
  }
}