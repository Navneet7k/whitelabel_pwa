import 'package:flutter/material.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _webViewUrl;
  late Color themeColor;
  Map<String, dynamic>? colorsMain;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void openWebView(String url) {
    setState(() {
      _webViewUrl = url;
    });
  }

  void closeWebView() {
    setState(() {
      _webViewUrl = null;
    });
  }

  Color getTopSectionColor() {
    final design = Constants.design;
    return {
      "1": themeColor,
      "2": const Color(0xFFFDF6E9),
      "3": const Color(0xFFEAF7FD),
      "4": Colors.black54,
      "8": (colorsMain?['body-color'] != null)
          ? hexToColor(colorsMain!['body-color'])
          : Colors.black54,
    }[design] ?? Colors.white;
  }

  Color getBottomSectionColor() {
    final design = Constants.design;
    return {
      "1": Colors.white,
      "2": const Color(0xFFFDF6E9),
      "3": const Color(0xFFEAF7FD),
      "4": Colors.black54,
      "8": (colorsMain?['body-color'] != null)
          ? hexToColor(colorsMain!['body-color']).withOpacity(0.8)
          : Colors.black54,
    }[design] ?? Colors.white;
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
            : Theme.of(context).colorScheme.primary;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("User not found")),
          );
        }

        // ✅ Show WebView with loader instead of profile when URL is set
        if (_webViewUrl != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: closeWebView,
              ),
              title: const Text(""),
              elevation: 0,
            ),
            body: GenericWebViewScreenWithLoader(url: _webViewUrl!),
          );
        }

        final name = user['name'] ?? '';
        final email = user['email'] ?? '';
        final phone = user['phone'] ?? '';

        return Scaffold(
          backgroundColor: getBottomSectionColor(),//bottom part color
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: getTopSectionColor(),//top part color
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/placeholder1.png',
                            fit: BoxFit.contain,   // ensures full image is visible
                            width: 90,
                            height: 90,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style:  TextStyle(
                          color: Constants.design=="4"?Colors.white:Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style:  TextStyle(
                          color: Constants.design=="4"?Colors.white:Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildIconButton(context, Icons.shopping_bag, "My Orders", () async {
                                final token = await StorageService.getToken();
                                final address =
                                    '${Constants.cartPageUrl}${Constants.restaurantId}?token=$token';
                                openWebView(address);
                              }),
                              _buildIconButton(context, Icons.favorite_border, "Favorites", () async {
                                final token = await StorageService.getToken();
                                final address =
                                    'https://app.zingmyorder.com/client/app/favorites/${Constants.restaurantId}?token=$token';
                                openWebView(address);
                              }),
                              _buildIconButton(context, Icons.card_giftcard, "Points", () async {
                                final token = await StorageService.getToken();
                                final address =
                                    'https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token';
                                openWebView(address);
                              }),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: Constants.design=="design6" || Constants.design=="design7",
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(email),
                          ),
                          if (phone.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Phone'),
                              subtitle: Text(phone),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if(Constants.design=="design3")
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16), // horizontal margin
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // background color
                      borderRadius: BorderRadius.circular(12), // rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3), // shadow effect
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildProfileOption(context, Icons.location_on_outlined, "Address", () async {
                            final token = await StorageService.getToken();
                            final url =
                                'https://app.zingmyorder.com/client/app/address/${Constants.restaurantId}?token=$token';
                            openWebView(url);
                          }),
                          _buildProfileOption(context, Icons.edit_outlined, "Edit Profile", () async {
                            final token = await StorageService.getToken();
                            final url =
                                'https://app.zingmyorder.com/client/app/edit-profile/${Constants.restaurantId}?token=$token';
                            openWebView(url);
                          }),
                          _buildProfileOption(
                            context,
                            Icons.logout,
                            "Sign Out",
                                () async {
                              await StorageService.clearAuth();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => MyApp(initialIndex: 3)),
                                    (route) => false,
                              );
                            },
                            color: Colors.red,
                          ),
                          _buildProfileOption(
                            context,
                            Icons.delete_forever,
                            "Delete Account",
                                () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.delete_forever, color: Colors.red, size: 48),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Are you sure you want to delete the account?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Close bottom sheet
                                                },
                                                child: const Text("No"),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context); // Close bottom sheet
                                                  final token = await StorageService.getToken();
                                                  final deleteUrl =
                                                      'https://app.zingmyorder.com/app/delete-user/${Constants.restaurantId}?token=$token';
                                                  openWebView(deleteUrl); // Show WebView inline
                                                },
                                                child: const Text("Yes", style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildProfileOption(context, Icons.location_on_outlined, "Address", () async {
                        final token = await StorageService.getToken();
                        final url =
                            'https://app.zingmyorder.com/client/app/address/${Constants.restaurantId}?token=$token';
                        openWebView(url);
                      }),
                      _buildProfileOption(context, Icons.edit_outlined, "Edit Profile", () async {
                        final token = await StorageService.getToken();
                        final url =
                            'https://app.zingmyorder.com/client/app/edit-profile/${Constants.restaurantId}?token=$token';
                        openWebView(url);
                      }),
                      _buildProfileOption(
                        context,
                        Icons.logout,
                        "Sign Out",
                            () async {
                          await StorageService.clearAuth();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => MyApp(initialIndex: 3)),
                                (route) => false,
                          );
                        },
                        color: Colors.red,
                      ),
                      _buildProfileOption(
                        context,
                        Icons.delete_forever,
                        "Delete Account",
                            () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_forever, color: Colors.red, size: 48),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Are you sure you want to delete the account?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Close bottom sheet
                                            },
                                            child: const Text("No"),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context); // Close bottom sheet
                                              final token = await StorageService.getToken();
                                              final deleteUrl =
                                                  'https://app.zingmyorder.com/app/delete-user/${Constants.restaurantId}?token=$token';
                                              openWebView(deleteUrl); // Show WebView inline
                                            },
                                            child: const Text("Yes", style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: themeColor),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        Color? color,
      }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void loadData() async {
    final colors = await StorageService.getAppColors();
    if (mounted) {
      setState(() {
        colorsMain=colors;
      });
    }
  }
}

// ✅ Beautiful WebView with loading indicator
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
