import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:zing_whitelabel_revamp/screens/profile_screen.dart';
import '../StorageServiceV2.dart';
import '../constants.dart';
import '../storage_service.dart';
import 'GenericWebViewScreen.dart';

class HomeDashboard1 extends StatefulWidget {
  final VoidCallback? onGoToAccount, onGoToOrder;
  const HomeDashboard1({super.key, this.onGoToAccount, this.onGoToOrder});

  @override
  State<HomeDashboard1> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashboard1> {
  List<dynamic> sliderImages = [];
  Map<String, dynamic>? points;
  Map<String, dynamic>? restaurant;
  List<dynamic> popularDishes = [];
  List<dynamic> featuredImages = [];
  List<dynamic> galleryImages = [];
  int _currentCarouselIndex = 0;
  String? userToken, savedHexColor;
  String? _webViewUrl;

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

  Widget buildRestaurantLogo(Map<String, dynamic>? restaurant) {
    if (restaurant == null) {
      // Handle case when restaurant info is not yet loaded or missing
      return const Icon(
        Icons.restaurant,
        size: 80,
        color: Colors.grey,
      );
    }

    final logoList = restaurant['logo'] as List<dynamic>?;
    final logoPath = (logoList != null && logoList.isNotEmpty)
        ? logoList.first['path']
        : null;

    final imageUrl =
    (logoPath != null) ? '${Constants.imageBaseUrl}/$logoPath' : null;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: imageUrl != null
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.broken_image,
          size: 60,
          color: Colors.grey,
        ),
      )
          : const Icon(
        Icons.restaurant,
        size: 60,
        color: Colors.grey,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
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
      backgroundColor: hexToColor("#F9FAFA"),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 20),

              // ✅ Circular App Icon at the Top

              buildRestaurantLogo(restaurant),

              const SizedBox(height: 20),

              // ✅ Loyalty Points Section
              if (points != null && userToken?.isNotEmpty == true)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Image + Text
                          Row(
                            children: [
                              // 🖼️ Left-side image (loyalty icon or your logo)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/loyality.png', // add your loyalty image here
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 📋 Text beside the image
                              Expanded(
                                child: Text(
                                  'For each food order purchased through our restaurant app, you will receive points. These points can be redeemed during check out for a future order in our restaurant app! You have 0.00 Total Points towards a future purchase at our restaurant.',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Bottom Row: Points + View button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${points!['total_amount']} Points",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final token = await StorageService.getToken();
                                  final url =
                                      'https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token';
                                  openWebView(url);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hexToColor(savedHexColor ?? "#000000"),
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "View",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // ✅ Popular Dishes (Now Vertical Scroll)
              if (popularDishes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Popular Dishes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: popularDishes.map((dish) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: (dish['image'] == null ||
                                        dish['image'].toString().isEmpty)
                                        ? Image.asset(
                                      'assets/images/placeholder1.png',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                        : CachedNetworkImage(
                                      imageUrl:
                                      "${Constants.imageBaseUrl1}/${dish['image']}",
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                            'assets/images/placeholder1.png',
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            'assets/images/placeholder1.png',
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),

                                  // Content + Button
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // Name
                                        (dish['name'] != null &&
                                            dish['name']
                                                .toString()
                                                .length >
                                                25)
                                            ? SizedBox(
                                          height: 20,
                                          width: double.infinity,
                                          child: Marquee(
                                            text: dish['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            velocity: 30,
                                            blankSpace: 40,
                                            pauseAfterRound:
                                            Duration(seconds: 1),
                                            startPadding: 0,
                                          ),
                                        )
                                            : Text(
                                          dish['name'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 4),
                                        Text(
                                          dish['description'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),

                                        const SizedBox(height: 10),

                                        ElevatedButton(
                                          onPressed: () async {
                                            final token = await StorageService.getToken();
                                            if (token != null &&
                                                token.isNotEmpty) {
                                              widget.onGoToOrder?.call();
                                            } else {
                                              widget.onGoToAccount?.call();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            hexToColor(savedHexColor ?? "#000000"),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
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
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
