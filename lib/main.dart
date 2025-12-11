import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zing_whitelabel_revamp/screens/OrderWebViewScreen.dart';
import 'package:zing_whitelabel_revamp/screens/custom_home_dashboard.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard1.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard2.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard3.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard4.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard5.dart';
import 'package:zing_whitelabel_revamp/screens/home_dashboard6.dart';
import 'package:zing_whitelabel_revamp/screens/locations_screen.dart';

import 'StorageServiceV2.dart';
import 'api_client.dart';
import 'app_themes.dart';
import 'beautiful_loading_screen.dart';
import 'constants.dart';
import 'screens/account_screen.dart';
import 'screens/account_wrapper_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/settings_screen.dart';
import 'storage_service.dart';
import 'theme_notifier.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> setupLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
// -------------------------------------------------------
// 🔥 REQUIRED: Background FCM handler
// -------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message);
  print("📩 BG Message Received: ${message.notification?.title}");
}

void showNotification(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification == null) return;

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        // icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        icon: '@drawable/ic_stat_notifications',
      ),
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("🔴 Flutter framework error: ${details.exceptionAsString()}");
  };

  runZonedGuarded(() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.requestPermission();
    await setupLocalNotifications();
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // -------------------------------------------------------
    // 🚨 Foreground message handler
    // -------------------------------------------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📲 Foreground Message: ${message.notification?.title}");
      showNotification(message);

      // Optional: show in-app dialog/snackbar
      // But NOT adding UI changes to avoid breaking anything
    });

    // -------------------------------------------------------
    // 🚨 Notification tap handler (terminated + background)
    // -------------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("👉 Notification opened app");

      // final url = message.data['order_url'];
      // if (url != null) {
      //   navigatorKey.currentState?.push(
      //     MaterialPageRoute(builder: (_) => OrderWebViewScreen(url: url)),
      //   );
      // }
    });

    // -------------------------------------------------------
    // 🔥 Fetch Token
    // -------------------------------------------------------
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await StorageService.saveFCMToken(fcmToken);
        print("✅ FCM Token saved: $fcmToken");
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await StorageService.saveFCMToken(newToken);
        print("🔁 Refreshed FCM Token: $newToken");

        String? api_token = await StorageService.getToken();
        if (newToken != null && api_token != null) {
          await updateFcmToken(newToken, api_token);
        }
      });
    } catch (e) {
      print("❌ Error fetching FCM Token: $e");
    }

    // ----------------------------------------------------------------------
    //  ⭐ YOUR EXISTING THEME + CONFIG FETCH — NOT MODIFIED
    // ----------------------------------------------------------------------
    ThemeData selectedTheme = AppThemes.light;
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeIndex') ?? 0;

    final currentId = Constants.restaurantId.toString();
    try {
      final infoResponse = await ApiClient().get("config/$currentId");
      if (infoResponse != null &&
          infoResponse['restaurant'] != null &&
          infoResponse['app'] != null) {
        await StorageService.saveRestaurantInfo(infoResponse);
        print("✅ Restaurant & app info cached");

        final hexColor = infoResponse['app']?['theme_color'];
        final design_temp = infoResponse['app']?['theme_design'];
        final bg_color = infoResponse['app']?['bg_color'];
        Constants.bg_color = bg_color.toString();
        if (design_temp == "design6")
          Constants.design = "1";
        else if (design_temp == "design7")
          Constants.design = "2";
        else if (design_temp == "design2")
          Constants.design = "3";
        else if (design_temp == "design3")
          Constants.design = "8";
        else if (design_temp == "design4")
          Constants.design = "5";
        else if (design_temp == "design8")
          Constants.design = "6";
        else
          Constants.design = "1";

        Constants.design = "8";

        if (bg_color != null && bg_color.isNotEmpty) {
          await StorageServiceV2.saveBgColorHex(hexColor);
        }
        if (hexColor != null && hexColor.isNotEmpty) {
          await StorageServiceV2.saveThemeColorHex(hexColor);
          selectedTheme = AppThemes.fromHex(hexColor);
          print("🎨 Applied theme from API: $hexColor");
        } else {
          selectedTheme = AppThemes.all[themeIndex];
          print("🎨 Applied default theme index: $themeIndex");
        }
      } else {
        selectedTheme = AppThemes.all[themeIndex];
      }
    } catch (e) {
      print("❌ Failed to fetch theme from config: $e");
      selectedTheme = AppThemes.all[themeIndex];
    }

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(selectedTheme),
        child: const BootstrapApp(),
      ),
    );
  }, (error, stackTrace) {
    print('🔴 Uncaught Flutter error: $error');
    print('🪵 Stack trace:\n$stackTrace');
  });
}

// Global navigation key so notification click can open screens
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> updateFcmToken(String fcmToken, String apiToken) async {
  final String url =
      "https://app.zingmyorder.com/api/client/update/fcm?api_token=$apiToken";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fcm_token": fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ FCM token updated successfully: ${response.body}");
    } else {
      print("❌ Failed to update FCM token. Status: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  } catch (e) {
    print("⚠️ Error updating FCM token: $e");
  }
}

// -------------------------------------------------------
// ⭐ YOUR EXISTING APP CODE (UNCHANGED)
// -------------------------------------------------------

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});
  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> with SingleTickerProviderStateMixin {
  bool _showMainApp = false;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  String _appTitle = 'Restaurant App';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.8, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward();
    _startAppLoad();
  }

  Future<void> _startAppLoad() async {
    await _preloadInitialData();

    final info = await StorageService.getRestaurantInfo();
    final name = info?['name'];
    if (name != null) {
      setState(() => _appTitle = name);
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _showMainApp = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,   // 🔥 Needed for notification-tap navigation
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeNotifier>(context).currentTheme,
      home: _showMainApp ? const MyApp() : _buildSplash(),
    );
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/images/rossanos.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.orange),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// ⭐ REMAINDER OF YOUR CODE (UNCHANGED)
// -------------------------------------------------------

class MyApp extends StatefulWidget {
  final int initialIndex;
  const MyApp({this.initialIndex = 0});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool isLoading = false;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _screens = [
      if (Constants.design == "1")
        HomeDashboard(onGoToAccount: () => setState(() => _selectedIndex = 3),
            onGoToOrder: () => setState(() => _selectedIndex = 2))
      else if (Constants.design == "2")
        CustomHomeDashboard(
            onGoToAccount: () => setState(() => _selectedIndex = 3),
            onGoToOrder: () => setState(() => _selectedIndex = 2))
      else if (Constants.design == "3")
          HomeDashboard1(
              onGoToAccount: () => setState(() => _selectedIndex = 3),
              onGoToOrder: () => setState(() => _selectedIndex = 2))
        else if (Constants.design == "4")
            HomeDashboard2(
                onGoToAccount: () => setState(() => _selectedIndex = 3),
                onGoToOrder: () => setState(() => _selectedIndex = 2))
          else if (Constants.design == "5")
              HomeDashboard3(
                  onGoToAccount: () => setState(() => _selectedIndex = 3),
                  onGoToOrder: () => setState(() => _selectedIndex = 2))
            else if (Constants.design == "6")
                HomeDashboard4(
                    onGoToAccount: () => setState(() => _selectedIndex = 3),
                    onGoToOrder: () => setState(() => _selectedIndex = 2))
              else if (Constants.design == "7")
                  HomeDashboard5(
                      onGoToAccount: () => setState(() => _selectedIndex = 3),
                      onGoToOrder: () => setState(() => _selectedIndex = 2))
                else if (Constants.design == "8")
                    HomeDashboard6(
                        onGoToAccount: () => setState(() => _selectedIndex = 3),
                        onGoToOrder: () => setState(() => _selectedIndex = 2)),

      MenuScreen(),
      CartScreen(),
      AccountWrapperScreen(),
      LocationsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Future<Map<String, dynamic>?> _colorsFuture = StorageService.getAppColors();
    return MainScaffold(
      selectedIndex: _selectedIndex,
      isLoading: isLoading,
      screens: _screens,
      onTabChanged: (index) => setState(() => _selectedIndex = index),
    );
  }
}

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) hex = "FF$hex";
  return Color(int.parse(hex, radix: 16));
}

class MainScaffold extends StatelessWidget {
  final int selectedIndex;
  final bool isLoading;
  final List<Widget> screens;
  final ValueChanged<int> onTabChanged;

  const MainScaffold({
    super.key,
    required this.selectedIndex,
    required this.isLoading,
    required this.screens,
    required this.onTabChanged,
  });

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Color getBackgroundColor() {
    final design = Constants.design;
    return {
      "1": Colors.white,
      "2": const Color(0xFFFDF6E9),
      "3": const Color(0xFFEAF7FD),
      "4": const Color(0xFF90EE90),
    }[design] ?? Colors.white;
  }

  Widget _buildBottomNavBar(
      BuildContext context,
      Color unselectedColor,
      Color selectedColor,
      ) {
    final theme = Theme.of(context);

    return (Constants.design != "8")
        ? Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: selectedColor.withOpacity(0.20),

        onDestinationSelected: (index) async {
          if (index == 2) {
            final token = await StorageService.getToken();
            if (token == null || token.isEmpty) {
              onTabChanged(3);
              return;
            }
          }
          onTabChanged(index);
        },

        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/ic_home.svg',
              height: 24,
              width: 24,
              color: unselectedColor,
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/ic_home.svg',
              height: 24,
              width: 24,
              color: selectedColor,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/icons/ic_menu.svg',
                height: 24, width: 24, color: unselectedColor),
            selectedIcon: SvgPicture.asset('assets/icons/ic_menu.svg',
                height: 24, width: 24, color: selectedColor),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/icons/ic_order.svg',
                height: 24, width: 24, color: unselectedColor),
            selectedIcon: SvgPicture.asset('assets/icons/ic_order.svg',
                height: 24, width: 24, color: selectedColor),
            label: 'Order',
          ),
          NavigationDestination(
            icon: SvgPicture.asset('assets/icons/ic_account.svg',
                height: 24, width: 24, color: unselectedColor),
            selectedIcon: SvgPicture.asset('assets/icons/ic_account.svg',
                height: 24, width: 24, color: selectedColor),
            label: 'Account',
          ),

          if (Constants.design == "3" || Constants.design == "4")
            NavigationDestination(
              icon: Icon(
                Icons.location_on_outlined,
                color: unselectedColor,
                size: 24,
              ),
              selectedIcon: Icon(
                Icons.location_on,
                color: selectedColor,
                size: 24,
              ),
              label: 'Locations',
            ),
        ],
      ),
    )

    // ---------------- DESIGN 8 ----------------
        : Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Material(
          elevation: 4,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: selectedColor.withOpacity(0.2),

            onDestinationSelected: (index) async {
              if (index == 2) {
                final token = await StorageService.getToken();
                if (token == null || token.isEmpty) {
                  onTabChanged(3);
                  return;
                }
              }
              onTabChanged(index);
            },

            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home,
                    color: unselectedColor, size: 28),
                selectedIcon: Icon(Icons.home,
                    color: selectedColor, size: 28),
                label: 'Home',
              ),
              NavigationDestination(
                icon:  SvgPicture.asset(
                  'assets/icons/ic_menus.svg',
                  height: 24,
                  width: 24,
                  color: unselectedColor,
                ),
                selectedIcon: SvgPicture.asset(
                  'assets/icons/ic_menus.svg',
                  height: 24,
                  width: 24,
                  color: selectedColor,
                ),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                            'assets/icons/ic_food.svg',
                            height: 24,
                            width: 24,
                            color: unselectedColor,
                          ),
                selectedIcon: SvgPicture.asset(
                  'assets/icons/ic_food.svg',
                  height: 24,
                  width: 24,
                  color: selectedColor,
                ),
                label: 'Order',
              ),
              NavigationDestination(
                icon: Icon(Icons.person,
                    color: unselectedColor, size: 28),
                selectedIcon: Icon(Icons.person,
                    color: selectedColor, size: 28),
                label: 'Account',
              ),
              if (Constants.design == "3" ||
                  Constants.design == "4" ||
                  Constants.design == "8")
                NavigationDestination(
                  icon: Icon(Icons.location_on_outlined,
                      color: unselectedColor, size: 28),
                  selectedIcon: Icon(Icons.location_on,
                      color: selectedColor, size: 28),
                  label: 'Locations',
                ),
            ],
          ),
        ),
      ),
    );
  }


  // Color getBackgroundColor() {
  //   final savedHex = Constants.bg_color.toString(); // stored earlier at app launch
  //   if (savedHex != null && savedHex.isNotEmpty) {
  //     return _hexToColor(savedHex);
  //   }
  //
  //   final design = Constants.design;
  //   return {
  //     "1": Colors.white,
  //     "2": const Color(0xFFFDF6E9),
  //     "3": const Color(0xFFEAF7FD),
  //     "4": const Color(0xFF90EE90),
  //   }[design] ?? Colors.white;
  // }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.currentTheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Constants.design == "2"? const Color(0xFFFDF6E9):Colors.white,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _getCombinedData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Restaurant App');
            }

            final data = snapshot.data!;
            final restaurantData = data['restaurant'] as Map<String, dynamic>?;
            final pointsData = data['points'];

            final name = restaurantData?['name'] ?? 'Restaurant App';
            final logoList = restaurantData?['logo'] as List?;
            final logoPath = (logoList != null && logoList.isNotEmpty)
                ? logoList[0]['path']
                : null; // fallback condition
            final imageUrl = logoPath != null
                ? '${Constants.imageBaseUrl}/$logoPath'
                : null;

            return  Row(
              children: [
                if (imageUrl != null && Constants.design!="3")
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.storefront, color: Colors.white),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),

                // Push "1500 Pts" to the right
                Visibility(
                  visible: Constants.design=="2",
                  child: Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${pointsData['points']} Pts",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, // Poppins 600
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

            );
          },
        ),
        actions: [
        ],
      ),
      body: isLoading
          ? const BeautifulLoadingScreen()
          : screens[selectedIndex],
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.only(bottom: 12),
      //   child: NavigationBar(
      //     selectedIndex: selectedIndex,
      //     backgroundColor: Colors.white, // 🔹 Set white background
      //     elevation: 0, // 🔹 Remove shadow if any
      //     indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
      //     onDestinationSelected: (index) async {
      //       if (index == 2) {
      //         final token = await StorageService.getToken();
      //         if (token == null || token.isEmpty) {
      //           onTabChanged(3);
      //           return;
      //         }
      //       }
      //       onTabChanged(index);
      //     },
      //     destinations: [
      //       NavigationDestination(
      //         icon: SvgPicture.asset(
      //           'assets/icons/ic_home.svg',
      //           height: 24,
      //           width: 24,
      //           color: Colors.black,
      //         ),
      //         label: 'Home',
      //       ),
      //       NavigationDestination(
      //         icon: SvgPicture.asset(
      //           'assets/icons/ic_menu.svg',
      //           height: 24,
      //           width: 24,
      //           color: Colors.black,
      //         ),
      //         label: 'Menu',
      //       ),
      //       NavigationDestination(
      //         icon: SvgPicture.asset(
      //           'assets/icons/ic_order.svg',
      //           height: 24,
      //           width: 24,
      //           color: Colors.black,
      //         ),
      //         label: 'Order',
      //       ),
      //       NavigationDestination(
      //         icon: SvgPicture.asset(
      //           'assets/icons/ic_account.svg',
      //           height: 24,
      //           width: 24,
      //           color: Colors.black,
      //         ),
      //         label: 'Account',
      //       ),
      //       if(Constants.design=="3"||Constants.design=="4")
      //         NavigationDestination(
      //           icon: Icon(
      //             Icons.location_on_outlined, // built-in Flutter icon
      //             color: Colors.black,
      //             size: 24,
      //           ),
      //           label: 'Locations',
      //         ),
      //
      //     ],
      //   ),
      // ),

      // bottomNavigationBar: _buildCustomNavBar(),

      bottomNavigationBar: FutureBuilder<Map<String, dynamic>?>(
        future: StorageService.getAppColors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final colors = snapshot.data!;
          final unselectedColor = hexToColor(colors['body-color']);
          final selectedColor = hexToColor(colors['secondary-color']);

          return _buildBottomNavBar(
            context,
            unselectedColor,
            selectedColor,
          );
        },
      ),

      floatingActionButton: (selectedIndex == 3 || selectedIndex == 0)
          ? null
          : FutureBuilder<String?>(
        future: StorageServiceV2.getThemeColorHex(),
        builder: (context, snapshot) {
          final hex = snapshot.data;
          final buttonColor = (hex != null && hex.isNotEmpty)
              ? hexToColor(hex)
              : Colors.orange; // fallback

          return FloatingActionButton.extended(
            onPressed: () async {
              final data = await StorageService.getRestaurantInfo();
              final token = await StorageService.getToken();
              final slug = data?['slug'];
              if (token != null && token.isNotEmpty) {
                if (slug != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderWebViewScreen(slug: slug),
                    ),
                  );
                  if (result == 'goToAccount') {
                    onTabChanged(3);
                  }
                } else {
                  print("❌ Slug not found in cache");
                }
              } else {
                onTabChanged(3);
              }
            },
            backgroundColor: buttonColor,
            label: const Text("Order Now"),
            icon: const Icon(Icons.shopping_bag),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCustomNavBar() {
    return ColoredBox(
      color: Colors.transparent,   // ← forces full transparency
      child: SizedBox(
        height: 65,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // ========= WHITE BACKGROUND BAR =========
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navIcon(0, Icons.list_alt),
                    _navIcon(1, Icons.shopping_bag_outlined),

                    const SizedBox(width: 70),

                    _navIcon(3, Icons.person),
                    _navIcon(4, Icons.location_on_outlined),
                  ],
                ),
              ),
            ),

            // ========= FLOATING CENTER BUTTON =========
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => onTabChanged(2),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _navIcon(int index, IconData icon) {
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Icon(
        icon,
        size: 28,
        color: Colors.black,
      ),
    );
  }

  Future<Map<String, dynamic>> _getCombinedData() async {
    final restaurant = await StorageService.getRestaurantInfo();
    final points = await StorageServiceV2.getPoints();

    return {
      'restaurant': restaurant,
      'points': points,
    };
  }
}

Future<void> _preloadInitialData() async {
  try {
    final currentId = Constants.restaurantId.toString();

    final menuItems = await StorageService.getMenuItems();
    final cachedRestaurant = await StorageService.getRestaurant();
    final cachedRestaurantId = cachedRestaurant?['id']?.toString();

    // if (menuItems.isEmpty || cachedRestaurantId != currentId) {
      final restaurantResponse = await ApiClient().get("menu/$currentId");
      if (restaurantResponse != null) {
        await StorageService.saveRestaurantData(restaurantResponse);
        print("✅ Menu data fetched and cached");
      }
    // } else {
    //   print("✅ Skipped menu API – already cached");
    // }

    final homeResponse = await ApiClient().get("home/$currentId");

    if (homeResponse != null) {
      await StorageServiceV2.saveHomeData(homeResponse);
      print("✅ Home data fetched and cached");
    }
  } catch (e) {
    print("❌ Error during preload: $e");
  }
}
