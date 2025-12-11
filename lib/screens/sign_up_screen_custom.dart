import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zing_whitelabel_revamp/screens/login_screen_custom.dart';
import 'package:zing_whitelabel_revamp/StorageServiceV2.dart';
import '../api_client.dart';
import '../constants.dart';
import '../storage_service.dart';

class SignUpScreenCustom extends StatefulWidget {
  const SignUpScreenCustom({super.key});

  @override
  State<SignUpScreenCustom> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreenCustom> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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

  Color getPrimaryColor() {
    return primaryColor ?? const Color(0xFF88B98B);
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

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter name';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter email';
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter mobile number';
    final mobileRegex = RegExp(r'^\+?\d{7,15}$');
    if (!mobileRegex.hasMatch(value.trim())) return 'Enter a valid mobile number';
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
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'restaurant_id': Constants.restaurantId,
        'is_app': Constants.isApp,
        'fcm_token': await StorageService.getFCMToken(),
      };

      final response = await ApiClient().post('clientregister', payload);

      setState(() => _isLoading = false);

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Please login.")),
        );

        // Navigate to login screen (replace current)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreenCustom()),
        );
      } else {
        // Extract error message
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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  InputDecoration _buildDecoration({
    required String hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(),
      suffixIcon: suffix,
      prefixIcon: prefix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E9), // light beige
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      // Logo
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.transparent,
                          backgroundImage: const AssetImage("assets/images/rossanos.png"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        "Sign Up",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown[900],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Name field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: _buildDecoration(
                            hint: "User Name",
                            suffix: const Icon(Icons.check, color: Colors.grey),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.person_outline, color: Colors.grey),
                            ),
                          ),
                          validator: _validateName,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _buildDecoration(
                            hint: "Your Email",
                            suffix: const Icon(Icons.check, color: Colors.grey),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.email_outlined, color: Colors.grey),
                            ),
                          ),
                          validator: _validateEmail,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Mobile field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _buildDecoration(
                            hint: "Mobile Number",
                            suffix: const Icon(Icons.check, color: Colors.grey),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.phone_outlined, color: Colors.grey),
                            ),
                          ),
                          validator: _validateMobile,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: _buildDecoration(
                            hint: "Password",
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.lock_outline, color: Colors.grey),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          decoration: _buildDecoration(
                            hint: "Confirm Password",
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.lock_outline, color: Colors.grey),
                            ),
                          ),
                          validator: _validateConfirmPassword,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Sign Up Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getPrimaryColor(),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _register,
                          child: Text(
                            _isLoading ? "Registering..." : "Sign Up",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Sign In link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a Member? ",
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreenCustom()),
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.poppins(
                                color: getPrimaryColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text("Registering...", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
