// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
//
// import '../api_client.dart';
// import '../constants.dart';
// import '../storage_service.dart';
//
// class RegisterScreen extends StatefulWidget {
//   final VoidCallback onLoginClicked;
//
//   const RegisterScreen({super.key, required this.onLoginClicked});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _mobileController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _tryRegister() {
//     if (_formKey.currentState?.validate() ?? false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Registering...')),
//       );
//     }
//   }
//
//   String? _validateName(String? value) {
//     if (value == null || value.isEmpty) return 'Please enter name';
//     return null;
//   }
//
//   // String? _validateEmail(String? value) {
//   //   if (value == null || value.isEmpty) return 'Please enter email';
//   //   final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}\$');
//   //   if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
//   //   return null;
//   // }
//   //
//   // String? _validateMobile(String? value) {
//   //   if (value == null || value.isEmpty) return 'Please enter mobile number';
//   //   final mobileRegex = RegExp(r'^\+?\d{7,15}\$');
//   //   if (!mobileRegex.hasMatch(value)) return 'Enter a valid mobile number';
//   //   return null;
//   // }
//
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) return 'Please enter email';
//     final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
//     return null;
//   }
//
//   String? _validateMobile(String? value) {
//     if (value == null || value.isEmpty) return 'Please enter mobile number';
//     final mobileRegex = RegExp(r'^\+?\d{7,15}$');
//     if (!mobileRegex.hasMatch(value)) return 'Enter a valid mobile number';
//     return null;
//   }
//
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return 'Please enter password';
//     if (value.length < 6) return 'Password must be at least 6 characters';
//     return null;
//   }
//
//   String? _validateConfirmPassword(String? value) {
//     if (value == null || value.isEmpty) return 'Please confirm password';
//     if (value != _passwordController.text) return 'Passwords do not match';
//     return null;
//   }
//
//   Future<void> _register() async {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final mobile = _mobileController.text.trim();
//     final password = _passwordController.text;
//     final confirmPassword = _confirmPasswordController.text;
//
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     // ✅ Get the FCM token from storage
//     final fcmToken = await StorageService.getFCMToken();
//
//     final response = await ApiClient().post('clientregister', {
//       'name': name,
//       'email': email,
//       'mobile': mobile,
//       'password': password,
//       'password_confirmation': confirmPassword,
//       'restaurant_id': Constants.restaurantId,
//       'is_app': Constants.isApp,
//       'fcm_token': fcmToken
//     });
//
//     setState(() => _isLoading = false);
//
//     if (response != null && response['status'] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Registration successful! Please login.")),
//       );
//       widget.onLoginClicked(); // Navigate back to login
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response?['message'] ?? 'Registration failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   FutureBuilder<Map<String, dynamic>?>(
//                     future: StorageService.getRestaurantInfo(),
//                     builder: (context, snapshot) {
//                       Widget logoWidget;
//
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         logoWidget = const SizedBox(
//                           height: 72,
//                           width: 72,
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       } else if (snapshot.hasData &&
//                           snapshot.data?['logo'] is List &&
//                           snapshot.data!['logo'].isNotEmpty) {
//                         final logoPath = snapshot.data!['logo'][0]['path'];
//                         final imageUrl = '${Constants.imageBaseUrl}/$logoPath';
//
//                         logoWidget = ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: CachedNetworkImage(
//                             imageUrl: imageUrl,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.contain,
//                             placeholder: (context, url) =>
//                             const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) =>
//                             const Icon(Icons.broken_image,
//                                 size: 72, color: Colors.grey),
//                           ),
//                         );
//                       } else {
//                         logoWidget = Icon(Icons.restaurant_menu,
//                             size: 72, color: theme.colorScheme.primary);
//                       }
//
//                       final restaurantName =
//                           snapshot.data?['name'] ?? 'Foodie';
//
//                       return Column(
//                         children: [
//                           logoWidget,
//                           const SizedBox(height: 8),
//                           Text(
//                             'Welcome to $restaurantName',
//                             style: theme.textTheme.headlineSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                         ],
//                       );
//                     },
//                   ),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Name',
//                       prefixIcon: Icon(Icons.person_outline),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: _validateName,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email_outlined),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: _validateEmail,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _mobileController,
//                     keyboardType: TextInputType.phone,
//                     decoration: const InputDecoration(
//                       labelText: 'Mobile Number',
//                       prefixIcon: Icon(Icons.phone_outlined),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: _validateMobile,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: Icon(Icons.lock_outline),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: _validatePassword,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Confirm Password',
//                       prefixIcon: Icon(Icons.lock_outline),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: _validateConfirmPassword,
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _register,
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 14),
//                         child: Text('Register', style: TextStyle(fontSize: 16)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text('Already have an account?'),
//                       TextButton(
//                         onPressed: widget.onLoginClicked,
//                         child: const Text('Login here'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 12),
//                     Text("Registering...", style: TextStyle(color: Colors.white)),
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
import 'package:zing_whitelabel_revamp/StorageServiceV2.dart';

import '../api_client.dart';
import '../constants.dart';
import '../storage_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginClicked;

  const RegisterScreen({super.key, required this.onLoginClicked});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Color? primaryColor;

  @override
  void initState() {
    super.initState();
    _loadPrimaryColor();
  }

  Future<void> _loadPrimaryColor() async {
    final hex = await StorageServiceV2.getThemeColorHex();
    if (hex != null) {
      setState(() {
        primaryColor = Color(int.parse(hex.replaceFirst('#', '0xff')));
      });
    }
  }

  Color getColor(BuildContext context) {
    return primaryColor ?? Theme.of(context).colorScheme.primary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter name';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Please enter mobile number';
    final mobileRegex = RegExp(r'^\+?\d{7,15}$');
    if (!mobileRegex.hasMatch(value)) return 'Enter a valid mobile number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ApiClient().post('clientregister', {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'restaurant_id': Constants.restaurantId,
      'is_app': Constants.isApp,
      'fcm_token': await StorageService.getFCMToken(),
    });

    setState(() => _isLoading = false);

    if (response != null && response['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login.")),
      );
      widget.onLoginClicked();
    } else {
      // Try to get specific error message
      final errors = response?['errors'] as Map<String, dynamic>?;

      String errorMessage = response?['message'] ?? 'Registration failed';

      if (errors != null && errors.isNotEmpty) {
        final firstErrorList = errors.values.first;
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          errorMessage = firstErrorList.first.toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Widget _buildPrefixIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: getColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: StorageService.getRestaurantInfo(),
                    builder: (context, snapshot) {
                      Widget logoWidget;

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        logoWidget = const SizedBox(
                          height: 72,
                          width: 72,
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
                            const Icon(Icons.broken_image, size: 72, color: Colors.grey),
                          ),
                        );
                      } else {
                        logoWidget = Icon(Icons.restaurant_menu, size: 72, color: getColor(context));
                      }

                      final restaurantName = snapshot.data?['name'] ?? 'Foodie';

                      return Column(
                        children: [
                          logoWidget,
                          const SizedBox(height: 8),
                          Text(
                            'Welcome to $restaurantName',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      prefixIcon: _buildPrefixIcon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: _buildPrefixIcon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Mobile
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      prefixIcon: _buildPrefixIcon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: _validateMobile,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: _buildPrefixIcon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: _buildPrefixIcon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: getColor(context),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Register"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: widget.onLoginClicked,
                        child: const Text('Login here'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text("Registering...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

