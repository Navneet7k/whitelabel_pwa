import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marquee/marquee.dart';
import 'package:zing_whitelabel_revamp/screens/profile_screen.dart';

import '../StorageServiceV2.dart';
import '../constants.dart';
import '../storage_service.dart';
import 'GenericWebViewScreen.dart';
import 'OrderWebViewScreen.dart';


class HomeDashboard2 extends StatefulWidget {
  final VoidCallback? onGoToAccount,onGoToOrder;
  const HomeDashboard2({super.key, this.onGoToAccount,this.onGoToOrder});

  @override
  State<HomeDashboard2> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashboard2> {
  List<dynamic> sliderImages = [];
  Map<String, dynamic>? points;
  Map<String, dynamic>? restaurant;
  List<dynamic> popularDishes = [];
  List<dynamic> featuredImages = [];
  List<dynamic> galleryImages = [];
  int _currentCarouselIndex = 0;
  String? userToken, savedHexColor;
  String? _webViewUrl;
  bool _isLoggedIn=false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final sliders = await StorageServiceV2.getSliderImages();
    final pointsData = await StorageServiceV2.getPoints();
    final popular = await StorageServiceV2.getPopularDishes();
    final featured = await StorageServiceV2.getFeaturedImages();
    final gallery = await StorageServiceV2.getGalleryImages();
    final restaurantData = await StorageService.getRestaurantInfo();
    final token = await StorageService.getToken();
    final savedHex = await StorageServiceV2.getThemeColorHex();
    final isLoggedIn = await StorageService.isLoggedIn();

    if (mounted) {
      setState(() {
        sliderImages = sliders;
        points = pointsData;
        popularDishes = popular;
        featuredImages = featured;
        restaurant = restaurantData;
        galleryImages = gallery.take(10).toList();
        userToken = token;
        savedHexColor = savedHex;
        _isLoggedIn = isLoggedIn;
      });
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
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

  @override
  Widget build(BuildContext context) {
    // ✅ Show WebView screen when URL is set
    if (_webViewUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: hexToColor(savedHexColor ?? "#000000"),
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

    return Scaffold(
      backgroundColor:  Colors.black54,
      body: SafeArea(
        child: Stack(
          children: [
            // 🖼️ Background Image Layer
            Image.asset(
                'assets/images/pattern3.png', // 👈 your background image path
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                color: Colors.black.withOpacity(0.8), // 👈 tint overlay
              ),
            RefreshIndicator(
              onRefresh: _loadAllData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

                  const SizedBox(height: 10),
                  // 🎯 Loyalty Points Card with WebView behavior
                  if (points != null && userToken?.isNotEmpty == true)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  "${points!['total_amount']}Pts",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: GestureDetector(
                                  onTap: () async {
                                    final token = await StorageService.getToken();
                                    final url = 'https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token';
                                    openWebView(url);
                                  },
                                  child: const Text(
                                    'Earn Points for Each Order. Learn More',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 🎯 Image Carousel with Order Now button
                  if (sliderImages.isNotEmpty && restaurant != null)
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Fade carousel area with horizontal padding
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0), // 👈 horizontal margin
                          child: SizedBox(
                            height: 240,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: StatefulBuilder(
                                builder: (context, setLocalState) {
                                  // Automatically switch every 4 seconds
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Future.delayed(const Duration(seconds: 4), () {
                                      if (!mounted) return;
                                      setState(() {
                                        _currentCarouselIndex =
                                            (_currentCarouselIndex + 1) % sliderImages.length;
                                      });
                                    });
                                  });

                                  final image = sliderImages[_currentCarouselIndex];

                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 900),
                                    transitionBuilder: (child, animation) => FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                    child: Stack(
                                      key: ValueKey(image['url']),
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: image['url'],
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                        ),
                                        Container(color: Colors.black.withOpacity(0.4)),
                                        Positioned(
                                          left: 16,
                                          bottom: 40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Welcome to \n${restaurant?['name'] ?? 'Restaurant'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final data =
                                                  await StorageService.getRestaurantInfo();
                                                  final token = await StorageService.getToken();
                                                  final slug = data?['slug'];
                                                  if (token != null &&
                                                      token.isNotEmpty &&
                                                      slug != null) {
                                                    widget.onGoToOrder?.call();
                                                  } else {
                                                    widget.onGoToAccount?.call();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: hexToColor(savedHexColor!),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 7),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  elevation: 4,
                                                ),
                                                child: const Text(
                                                  "Order Now",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Dots indicator
                        Positioned(
                          bottom: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: sliderImages.asMap().entries.map((entry) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentCarouselIndex == entry.key
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // 4. Popular Dishes Horizontal Scroll (Image left, text right)
                  // 4. Popular Dishes Horizontal Scroll (Image left, text right)
                  if (popularDishes.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Popular Dishes",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CarouselSlider.builder(
                          itemCount: popularDishes.length,
                          itemBuilder: (context, index, _) {
                            final dish = popularDishes[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SizedBox(
                                  height: 170,
                                  child: Row(
                                    children: [
                                      // 🖼️ Left-side image (square + rounded all corners)
                                      Container(
                                        margin: const EdgeInsets.all(16), // 👈 image margin
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10), // 👈 all corners rounded
                                          child: (dish['image'] == null ||
                                              dish['image'].toString().isEmpty)
                                              ? Image.asset(
                                            'assets/images/placeholder1.png',
                                            width: 120,
                                            height: 120, // 👈 square image
                                            fit: BoxFit.cover,
                                          )
                                              : CachedNetworkImage(
                                            imageUrl:
                                            "${Constants.imageBaseUrl1}/${dish['image']}",
                                            width: 120,
                                            height: 120, // 👈 square image
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/placeholder1.png',
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              'assets/images/placeholder1.png',
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 📋 Right-side text + button
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                dish['name'] ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                dish['description'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 13, color: Colors.black87),
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final data =
                                                  await StorageService.getRestaurantInfo();
                                                  final token =
                                                  await StorageService.getToken();
                                                  final slug = data?['slug'];
                                                  if (token != null &&
                                                      token.isNotEmpty &&
                                                      slug != null) {
                                                    widget.onGoToOrder?.call();
                                                  } else {
                                                    widget.onGoToAccount?.call();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  hexToColor(savedHexColor ?? "#000000"),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 18, vertical: 6),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Order Now",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 160,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            viewportFraction: 0.95,
                            enableInfiniteScroll: true,
                          ),
                        ),
                      ],
                    ),


                  const SizedBox(height: 24),

                  // 🎯 NEW: Contact Us + Login Section
                  // 🎯 Contact Us Section (Overlapping Cards)
                  if (restaurant != null && !_isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Compact black header (in the normal flow)
                          Container(
                            width: double.infinity,
                            height: 80, // header height (adjust as needed)
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14),
                              // border: Border.all(color: Colors.white, width: 0.8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerLeft, // left aligned title
                            child: const Text(
                              "Contact Us",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Reserve space equal to overlap amount (so the white card will be pulled up visually)
                          const SizedBox(height: 20),

                          // White card translated upward to overlap header visually.
                          // Because it's still in the column flow, following widgets (gallery) start after this card.
                          Transform.translate(
                            offset: const Offset(0, -30), // negative = move up to overlap header by 20px
                            child: Card(
                              color: Colors.white,
                              elevation: 8,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Colors.white, width: 0.8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Phone row
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey.shade300, width: 1),
                                          ),
                                          child: const Icon(
                                            Icons.phone_outlined,
                                            color: Colors.black54,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            restaurant?['phone'] ?? "Not Available",
                                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Address row
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey.shade300, width: 1),
                                          ),
                                          child: const Icon(
                                            Icons.home_outlined,
                                            color: Colors.black54,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            restaurant?['address'] ?? "No address provided",
                                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Full width login button — should be fully visible and clickable
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          widget.onGoToAccount?.call();
                                        },
                                        icon: const Icon(Icons.lock, color: Colors.white, size: 18),
                                        label: const Text(
                                          "Log in",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // No extra giant spacer needed — the Transform keeps layout reserved space.
                          // If you want extra space between this card and the gallery, tweak the SizedBox above (or add another here).
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),


                  const SizedBox(height: 14),

                  // 5. Featured Images Section
                  // if (featuredImages.isNotEmpty)
                  //   Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //         child: Text(
                  //           "Featured Images",
                  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 12),
                  //       CarouselSlider.builder(
                  //         itemCount: featuredImages.length,
                  //         itemBuilder: (context, index, _) {
                  //           final item = featuredImages[index];
                  //           return Container(
                  //             margin: const EdgeInsets.symmetric(horizontal: 6),
                  //             child: ClipRRect(
                  //               borderRadius: BorderRadius.circular(10),
                  //               child: CachedNetworkImage(
                  //                 imageUrl: item['url'],
                  //                 width: 130,
                  //                 height: 110,
                  //                 fit: BoxFit.cover,
                  //               ),
                  //             ),
                  //           );
                  //         },
                  //         options: CarouselOptions(
                  //           height: 120,
                  //           autoPlay: true,
                  //           enableInfiniteScroll: true,
                  //           enlargeCenterPage: false,
                  //           viewportFraction: 0.3,
                  //         ),
                  //       ),
                  //     ],
                  //   ),


                  const SizedBox(height: 24),

                  // 6. Gallery Section (Staggered Grid)
                  if (galleryImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Gallery",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          itemCount: galleryImages.length,
                          shrinkWrap: true, // 👈 allows embedding inside Column
                          physics: const NeverScrollableScrollPhysics(), // 👈 disable nested scroll, main scroll will handle it
                          itemBuilder: (context, index) {
                            final img = galleryImages[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: img['url'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 180,
                                  placeholder: (context, url) => Container(
                                    height: 180,
                                    color: Colors.grey.shade200,
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 180,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image, size: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),


                  const SizedBox(height: 32),
                ],
              ),
            ),
            ]
        )
      ),
    );
  }
}