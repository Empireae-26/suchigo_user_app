import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_app/screens/home_screen.dart';
import 'package:suchigo_app/screens/onboarding_screen.dart';
import 'package:suchigo_app/providers/profile_provider.dart';
import 'package:suchigo_app/services/secure_storage_service.dart';

class SplashScreenAuth extends StatefulWidget {
  const SplashScreenAuth({Key? key}) : super(key: key);

  @override
  State<SplashScreenAuth> createState() => _SplashScreenAuthState();
}

class _SplashScreenAuthState extends State<SplashScreenAuth> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a slight delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await SecureStorageService.getToken();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        Provider.of<ProfileProvider>(context, listen: false).refresh();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e, stack) {
      debugPrint("Auth status check failed: $e");
      debugPrint("$stack");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Fallback to icon if logo doesn't exist
              width: 200,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/icons/suchigologo.png', width: 150),
            ),
          ],
        ),
      ),
    );
  }
}
