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


class HomeDashboard extends StatefulWidget {
  final VoidCallback? onGoToAccount,onGoToOrder;
  const HomeDashboard({super.key, this.onGoToAccount,this.onGoToOrder});

  @override
  State<HomeDashboard> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashboard> {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [

              // 🎯 Image Carousel with Order Now button
              if (sliderImages.isNotEmpty && restaurant != null)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CarouselSlider.builder(
                      itemCount: sliderImages.length,
                      itemBuilder: (context, index, _) {
                        final image = sliderImages[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: image['url'],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Icon(Icons.error),
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
                                      final data = await StorageService.getRestaurantInfo();
                                      final token = await StorageService.getToken();
                                      final slug = data?['slug'];
                                      if (token != null && token.isNotEmpty && slug != null) {
                                        // final url = "${Constants.webBaseUrl1}/${slug}?token=$token";
                                        // openWebView(url);
                                        widget.onGoToOrder?.call();
                                      } else {
                                        widget.onGoToAccount?.call();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hexToColor(savedHexColor!),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
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
                        );
                      },
                      options: CarouselOptions(
                        height: 240,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        onPageChanged: (index, _) {
                          setState(() => _currentCarouselIndex = index);
                        },
                      ),
                    ),
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
                    )
                  ],
                ),

              const SizedBox(height: 20),

              // 🎯 Loyalty Points Card with WebView behavior
              if (points != null && userToken?.isNotEmpty == true)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    color: hexToColor(savedHexColor!),
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
                                color: Colors.white,
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
                                  color: Colors.white,
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

              // 4. Popular Dishes Horizontal Scroll
              if (popularDishes.isNotEmpty)
                SizedBox(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: popularDishes.length,
                    itemBuilder: (context, index) {
                      final dish = popularDishes[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: (dish['image'] == null || dish['image'].toString().isEmpty)
                                    ? Image.asset(
                                  'assets/images/placeholder1.png',
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                                    : CachedNetworkImage(
                                  imageUrl: "${Constants.imageBaseUrl1}/${dish['image']}",
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/images/placeholder1.png',
                                    height: 170,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) => Image.asset(
                                    'assets/images/placeholder1.png',
                                    height: 170,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // Content + Button
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // shrink to fit content
                                    children: [
                                      // Name
                                      (dish['name'] != null && dish['name'].toString().length > 25)
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
                                          pauseAfterRound: Duration(seconds: 1),
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

                                      const SizedBox(height: 1), // Reduced vertical spacing

                                      // Description
                                      Text(
                                        dish['description'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11),
                                      ),

                                      const SizedBox(height: 6), // Slight spacing before button

                                      // Button with wrapped width
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final data = await StorageService.getRestaurantInfo();
                                            final token = await StorageService.getToken();
                                            final slug = data?['slug'];
                                            if (token != null && token.isNotEmpty) {
                                              // if (slug != null) {
                                              //   final data = await StorageService.getRestaurantInfo();
                                              //   final token = await StorageService.getToken();
                                              //   final slug = data?['slug'];
                                              //   if (slug != null) {
                                              //     final url = "${Constants.webBaseUrl1}/${slug}?token=$token";
                                              //     openWebView(url);
                                              //   }
                                              // } else {
                                              //   print("❌ Slug not found in cache");
                                              // }
                                              widget.onGoToOrder?.call();
                                            }else {
                                              widget.onGoToAccount?.call();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: hexToColor(savedHexColor!),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )

              ,


              const SizedBox(height: 24),

              // 5. Featured Images Section
              if (featuredImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:  [
                          Text("Featured Images",
                              style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          // Text("View All",
                          //     style: TextStyle(
                          //         fontSize: 14,
                          //         color: Theme.of(context).colorScheme.primary,
                          //         fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: featuredImages.length,
                        itemBuilder: (context, index) {
                          final item = featuredImages[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl:item['url'],
                                width: 120,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),

              const SizedBox(height: 24),

              // 6. Gallery Section (Staggered Grid)
              if (galleryImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:  [
                          Text("Gallery",
                              style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          // Text("View All",
                          //     style: TextStyle(
                          //         fontSize: 14,
                          //         color: Theme.of(context).colorScheme.primary,
                          //         fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MasonryGridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        shrinkWrap: true,
                        itemCount: galleryImages.length,
                        itemBuilder: (context, index) {
                          final img = galleryImages[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:img['url'],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}