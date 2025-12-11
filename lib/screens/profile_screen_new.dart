// ----------------------------------------------------------
// RE-DESIGNED PROFILE SCREEN — EXACTLY LIKE THE PROVIDED UI
// ----------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../StorageServiceV2.dart';
import '../constants.dart';
import '../main.dart';
import '../storage_service.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) hex = "FF$hex";
  return Color(int.parse(hex, radix: 16));
}

class ProfileScreenNew extends StatefulWidget {
  const ProfileScreenNew({super.key});

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  String? _webViewUrl;
  late Color themeColor;
  Map<String, dynamic>? colorsMain;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void openWebView(String url) {
    setState(() => _webViewUrl = url);
  }

  void closeWebView() {
    setState(() => _webViewUrl = null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        StorageService.getUser(),
        StorageServiceV2.getThemeColorHex(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data![0] as Map<String, dynamic>?;
        final hex = snapshot.data![1] as String?;

        themeColor = (hex != null && hex.isNotEmpty)
            ? hexToColor(hex)
            : const Color(0xFF7BA586);      // green used in design

        if (_webViewUrl != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: closeWebView,
              ),
            ),
            body: GenericWebViewScreenWithLoader(url: _webViewUrl!),
          );
        }

        final name = user?['name'] ?? "";
        final email = user?['email'] ?? "";
        final phone = user?['phone'] ?? "";

        return Scaffold(
          backgroundColor: const Color(0xFFF7EEDB), // cream background
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  // --------------------------
                  // Large Circle Avatar
                  // --------------------------
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8C8B1), // peach circle
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.brown,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --------------------------------------------------
                  // 3x3 ICON GRID (with rounded peach tiles)
                  // --------------------------------------------------
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisSpacing: 10,     // smaller spacing
                    mainAxisSpacing: 6,      // smaller spacing
                    childAspectRatio: 1.05,   // 🔹 makes each tile smaller & more compact
                    crossAxisCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      buildMenuTile("My Orders", "assets/icons/ic_myorders.svg", () async {
                        final token = await StorageService.getToken();
                        final url = "${Constants.cartPageUrl}${Constants.restaurantId}?token=$token";
                        openWebView(url);
                      }),

                      buildMenuTile("Favourites", "assets/icons/ic_favorites.svg", () async {
                        final token = await StorageService.getToken();
                        final url =
                            "https://app.zingmyorder.com/client/app/favorites/${Constants.restaurantId}?token=$token";
                        openWebView(url);
                      }),

                      buildMenuTile("Points", "assets/icons/ic_points.svg", () async {
                        final token = await StorageService.getToken();
                        final url =
                            "https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token";
                        openWebView(url);
                      }),

                      buildMenuTile("Address", "assets/icons/ic_address.svg", () async {
                        final token = await StorageService.getToken();
                        final url =
                            "https://app.zingmyorder.com/client/app/address/${Constants.restaurantId}?token=$token";
                        openWebView(url);
                      }),

                      buildMenuTile("Edit Profile", "assets/icons/ic_edit_profile.svg", () async {
                        final token = await StorageService.getToken();
                        final url =
                            "https://app.zingmyorder.com/client/app/edit-profile/${Constants.restaurantId}?token=$token";
                        openWebView(url);
                      }),

                      buildMenuTile("Delete", "assets/icons/ic_delete.svg", () => showDeleteSheet(context)),

                      buildMenuTile("Location", "assets/icons/ic_address.svg", () async {
                        final token = await StorageService.getToken();
                        final url =
                            "https://app.zingmyorder.com/client/app/address/${Constants.restaurantId}?token=$token";
                        openWebView(url);
                      }),

                      // buildMenuTile("Edit Profile", () async {
                      //   final token = await StorageService.getToken();
                      //   final url =
                      //       "https://app.zingmyorder.com/client/app/edit-profile/${Constants.restaurantId}?token=$token";
                      //   openWebView(url);
                      // }),
                      //
                      // buildMenuTile("Delete", () => showDeleteSheet(context)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ----------------------------
                  // Logout + Order Now Button
                  // ----------------------------

                  Row(
                    children: [
                      // Logout icon button
                      InkWell(
                        onTap: () async {
                          await StorageService.clearAuth();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => MyApp(initialIndex: 3)),
                                (route) => false,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.logout),
                        ),
                      ),


                      const SizedBox(width: 20),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8FBA96),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            final token = await StorageService.getToken();
                            final url = '${Constants.cartPageUrl}${Constants.restaurantId}?token=$token';
                            openWebView(url);
                          },
                          child: const Text(
                            "Order Now",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------
  // UI Tile for each menu
  // --------------------------------------------------------
  Widget buildMenuTile(String title, String svgPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE8C8B1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                height: 36,
                width: 36,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }




  // --------------------------------------------------------
  // Delete Bottom Sheet (same logic, styled simpler)
  // --------------------------------------------------------
  void showDeleteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_forever, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to delete the account?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        Navigator.pop(context);
                        final token = await StorageService.getToken();
                        openWebView(
                          "https://app.zingmyorder.com/app/delete-user/${Constants.restaurantId}?token=$token",
                        );
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void loadData() async {
    final colors = await StorageService.getAppColors();
    if (mounted) setState(() => colorsMain = colors);
  }
}

// ------------------------------------------------------------------
// WebView Loader
// ------------------------------------------------------------------
class GenericWebViewScreenWithLoader extends StatefulWidget {
  final String url;
  const GenericWebViewScreenWithLoader({super.key, required this.url});

  @override
  State<GenericWebViewScreenWithLoader> createState() => _GenericWebViewScreenWithLoaderState();
}

class _GenericWebViewScreenWithLoaderState extends State<GenericWebViewScreenWithLoader> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
