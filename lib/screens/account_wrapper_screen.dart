import 'package:flutter/material.dart';
import 'package:zing_whitelabel_revamp/constants.dart';
import 'package:zing_whitelabel_revamp/screens/profile_screen_new.dart';
import '../storage_service.dart'; // Adjust import path
import 'profile_screen.dart';
import 'account_screen.dart';

class AccountWrapperScreen extends StatefulWidget {
  const AccountWrapperScreen({super.key});

  @override
  State<AccountWrapperScreen> createState() => _AccountWrapperScreenState();
}

class _AccountWrapperScreenState extends State<AccountWrapperScreen> {
  late Future<bool> _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = StorageService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        if (snapshot.data == true) {
          if(Constants.design=="2")
            return ProfileScreenNew();
          else
            return ProfileScreen();
        } else {
          return AccountScreen(); // shows login/signup options
        }
      },
    );
  }
}


