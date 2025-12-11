import 'package:flutter/material.dart';
import 'package:zing_whitelabel_revamp/screens/login_screen_custom.dart';
import '../constants.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Map design -> screen
    final designScreens = {
      "1": LoginScreen(),
      "2": LoginScreenCustom(),
      "3": LoginScreen(),
      "4": LoginScreen(),
    };

    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: const Text("Login / Register"),
        onPressed: () {
          final nextScreen =
              designScreens[Constants.design] ?? LoginScreen(); // fallback

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
          );
        },
      ),
    );
  }
}
