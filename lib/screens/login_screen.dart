// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:zing_whitelabel_revamp/screens/register_screen.dart';
//
// import '../api_client.dart';
// import '../constants.dart';
// import '../main.dart';
// import '../storage_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final emailController = TextEditingController();
//   final passController = TextEditingController();
//
//   bool _isLoading = false;
//
//   Future<void> _login() async {
//     final email = emailController.text.trim();
//     final password = passController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     final response = await ApiClient().post('clientlogin', {
//       'email': email,
//       'password': password,
//       'restaurant_id': Constants.restaurantId,
//       'is_app': Constants.isApp,
//       'flag': Constants.flag,
//     });
//
//     setState(() => _isLoading = false);
//
//     if (response != null && response['status'] == true) {
//       final token = response['token'];
//       final user = response['user'];
//
//       await StorageService.saveToken(token);
//       await StorageService.saveUser(user);
//
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login successful!')),
//       );
//
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => MyApp(initialIndex: 3)),
//             (route) => false,
//       );
//     } else {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response?['message'] ?? 'Login failed')),
//       );
//     }
//   }
//
//   Widget _buildLoginForm() {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: StorageService.getRestaurantInfo(),
//       builder: (context, snapshot) {
//         Widget logoWidget;
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           logoWidget = const SizedBox(
//             height: 80,
//             width: 80,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasData &&
//             snapshot.data?['logo'] is List &&
//             snapshot.data!['logo'].isNotEmpty) {
//           final logoPath = snapshot.data!['logo'][0]['path'];
//           final imageUrl = '${Constants.imageBaseUrl}/$logoPath';
//
//           logoWidget = ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: CachedNetworkImage(
//               imageUrl: imageUrl,
//               width: 100,
//               height: 100,
//               fit: BoxFit.contain,
//               placeholder: (context, url) => const CircularProgressIndicator(),
//               errorWidget: (context, url, error) =>
//               const Icon(Icons.broken_image, size: 80, color: Colors.grey),
//             ),
//           );
//         } else {
//           logoWidget = const Icon(Icons.restaurant, size: 80, color: Colors.deepOrange);
//         }
//
//         return SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 logoWidget,
//                 const SizedBox(height: 10),
//                 Text("Welcome Back!", style: Theme.of(context).textTheme.headlineLarge),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: emailController,
//                   decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 15),
//                 TextField(
//                   controller: passController,
//                   obscureText: true,
//                   decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
//                 ),
//                 const SizedBox(height: 15),
//                 // Align(
//                 //   alignment: Alignment.centerRight,
//                 //   child: TextButton(onPressed: () {}, child: const Text("Forgot Password?")),
//                 // ),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _login,
//                     child: const Text("Login"),
//                     style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text("Don't have an account?"),
//                 TextButton(
//                   child: const Text("Sign up here"),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => RegisterScreen(
//                           onLoginClicked: () => Navigator.pop(context),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Login")),
//       body: Stack(
//         children: [
//           _buildLoginForm(),
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 12),
//                     Text("Logging in...", style: TextStyle(color: Colors.white)),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zing_whitelabel_revamp/screens/register_screen.dart';

import '../StorageServiceV2.dart';
import '../api_client.dart';
import '../constants.dart';
import '../main.dart';
import '../storage_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  Color primaryColor = Colors.deepOrange; // default fallback

  @override
  void initState() {
    super.initState();
    _loadPrimaryColor();
  }

  Future<void> _loadPrimaryColor() async {
    final hex = await StorageServiceV2.getThemeColorHex();
    if (hex != null && hex.isNotEmpty) {
      setState(() {
        primaryColor = _hexToColor(hex);
      });
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add full opacity if not included
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiClient().post('clientlogin', {
      'email': email,
      'password': password,
      'restaurant_id': Constants.restaurantId,
      'is_app': Constants.isApp,
      'flag': Constants.flag,
      'fcm_token':await StorageService.getFCMToken()
    });

    setState(() => _isLoading = false);

    if (response != null && response['status'] == true) {
      final token = response['token'];
      final user = response['user'];

      await StorageService.saveToken(token);
      await StorageService.saveUser(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MyApp(initialIndex: 3)),
            (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?['message'] ?? 'Login failed')),
      );
    }
  }

  Widget _buildLoginForm() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: StorageService.getRestaurantInfo(),
      builder: (context, snapshot) {
        Widget logoWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          logoWidget = const SizedBox(
            height: 80,
            width: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData &&
            snapshot.data?['logo'] is List &&
            snapshot.data!['logo'].isNotEmpty) {
          final logoPath = snapshot.data!['logo'][0]['path'];
          final imageUrl = '${Constants.imageBaseUrl}/$logoPath';

          logoWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
          );
        } else {
          logoWidget =
          const Icon(Icons.restaurant, size: 80, color: Colors.deepOrange);
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                logoWidget,
                const SizedBox(height: 10),
                Text("Welcome Back!",
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 20),

                // 👉 Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 👉 Password Field with Eye Icon
                TextFormField(
                  controller: passController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Login"),
                  ),
                ),

                const SizedBox(height: 10),

                const Text("Don't have an account?"),
                TextButton(
                  child: const Text("Sign up here"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(
                          onLoginClicked: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildLoginForm(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text("Logging in...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
