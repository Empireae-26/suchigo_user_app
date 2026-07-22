import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:suchigo_app/firebase_options.dart';
import 'package:suchigo_app/services/notification_service.dart';
import 'package:suchigo_app/screens/AddOrder_Screen.dart';
import 'package:suchigo_app/screens/collector_screen.dart';
import 'package:suchigo_app/screens/home_screen.dart';
import 'package:suchigo_app/screens/login_screen.dart';
import 'package:suchigo_app/screens/register_screen.dart';
import 'package:suchigo_app/screens/signin_screen.dart';
import 'package:suchigo_app/screens/splash_screen_auth.dart';
import 'package:suchigo_app/services/api_client.dart';
import 'package:suchigo_app/providers/AddressProvider.dart';
import 'package:suchigo_app/providers/CollectorProvider.dart';
import 'package:suchigo_app/providers/address_details_provider.dart';
import 'package:suchigo_app/providers/bill_provider.dart';
import 'package:suchigo_app/providers/home_provider.dart';
import 'package:suchigo_app/providers/pickup_provider.dart';
import 'package:suchigo_app/providers/profile_provider.dart';
import 'package:suchigo_app/providers/register_provider.dart';
import 'package:suchigo_app/providers/location_provider.dart';
import 'package:suchigo_app/providers/login_provider.dart';
import 'package:suchigo_app/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermissions();
  } catch (e, stack) {
    debugPrint("Notification service initialization failed: $e");
    debugPrint("$stack");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint("$stack");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => PickupProvider()),
        ChangeNotifierProvider(create: (_) => CollectorProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => AddressDetailsProvider()),
      ],
      child: const SuchiGoApp(),
    ),
  );
}

class SuchiGoApp extends StatelessWidget {
  const SuchiGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SuchiGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreenAuth(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/collector': (context) => const CollectorScreen(),
        '/home': (context) => const HomeScreen(),
        // '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}
