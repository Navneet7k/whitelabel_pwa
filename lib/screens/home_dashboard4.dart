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


class HomeDashboard4 extends StatefulWidget {
  final VoidCallback? onGoToAccount,onGoToOrder;
  const HomeDashboard4({super.key, this.onGoToAccount,this.onGoToOrder});

  @override
  State<HomeDashboard4> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashboard4> {
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

              const SizedBox(height: 10),
              // 🎯 Loyalty Points Card with Gradient Background
            // 🎯 Loyalty Points Card EXACT Like Given Image
            if (points != null && userToken?.isNotEmpty == true)
          Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ---------------- RECTANGLE BEHIND CIRCLE ----------------
          Container(
            height: 70, // smaller than circle
            margin: const EdgeInsets.only(left: 60), // how much circle overlaps
            decoration: BoxDecoration(
              color: const Color(0xFF92E69C), // exact image rectangle color
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.only(left: 70, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text inside rectangle
                Expanded(
                  child: Text(
                    "Each Points For Each Orders",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Learn More button
                GestureDetector(
                  onTap: () async {
                    final token = await StorageService.getToken();
                    final url =
                        'https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token';
                    openWebView(url);
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      "Learn More",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          // ---------------- LEFT CIRCLE ----------------
          Positioned(
            left: 0,
            top: -15, // move a little up to match image look
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5EC76E), // exact circle green from image
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  "${points!['total_amount']}\nPoints",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 20),

              // // 🎯 Image Carousel with Order Now button
              // if (sliderImages.isNotEmpty && restaurant != null)
              //   Stack(
              //     alignment: Alignment.bottomCenter,
              //     children: [
              //       // Fade carousel area with horizontal padding
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 12.0), // 👈 horizontal margin
              //         child: SizedBox(
              //           height: 240,
              //           child: ClipRRect(
              //             borderRadius: BorderRadius.circular(12),
              //             child: StatefulBuilder(
              //               builder: (context, setLocalState) {
              //                 // Automatically switch every 4 seconds
              //                 WidgetsBinding.instance.addPostFrameCallback((_) {
              //                   Future.delayed(const Duration(seconds: 4), () {
              //                     if (!mounted) return;
              //                     setState(() {
              //                       _currentCarouselIndex =
              //                           (_currentCarouselIndex + 1) % sliderImages.length;
              //                     });
              //                   });
              //                 });
              //
              //                 final image = sliderImages[_currentCarouselIndex];
              //
              //                 return AnimatedSwitcher(
              //                   duration: const Duration(milliseconds: 900),
              //                   transitionBuilder: (child, animation) => FadeTransition(
              //                     opacity: animation,
              //                     child: child,
              //                   ),
              //                   child: Stack(
              //                     key: ValueKey(image['url']),
              //                     fit: StackFit.expand,
              //                     children: [
              //                       CachedNetworkImage(
              //                         imageUrl: image['url'],
              //                         fit: BoxFit.cover,
              //                         errorWidget: (context, url, error) =>
              //                         const Icon(Icons.error),
              //                       ),
              //                       Container(color: Colors.black.withOpacity(0.4)),
              //                       Positioned(
              //                         left: 16,
              //                         bottom: 40,
              //                         child: Column(
              //                           crossAxisAlignment: CrossAxisAlignment.start,
              //                           children: [
              //                             Text(
              //                               "Welcome to \n${restaurant?['name'] ?? 'Restaurant'}",
              //                               style: const TextStyle(
              //                                 color: Colors.white,
              //                                 fontSize: 28,
              //                                 fontWeight: FontWeight.bold,
              //                               ),
              //                             ),
              //                             const SizedBox(height: 12),
              //                             ElevatedButton(
              //                               onPressed: () async {
              //                                 final data =
              //                                 await StorageService.getRestaurantInfo();
              //                                 final token = await StorageService.getToken();
              //                                 final slug = data?['slug'];
              //                                 if (token != null &&
              //                                     token.isNotEmpty &&
              //                                     slug != null) {
              //                                   widget.onGoToOrder?.call();
              //                                 } else {
              //                                   widget.onGoToAccount?.call();
              //                                 }
              //                               },
              //                               style: ElevatedButton.styleFrom(
              //                                 backgroundColor: hexToColor(savedHexColor!),
              //                                 padding: const EdgeInsets.symmetric(
              //                                     horizontal: 20, vertical: 7),
              //                                 shape: RoundedRectangleBorder(
              //                                   borderRadius: BorderRadius.circular(8),
              //                                 ),
              //                                 elevation: 4,
              //                               ),
              //                               child: const Text(
              //                                 "Order Now",
              //                                 style: TextStyle(
              //                                   color: Colors.white,
              //                                   fontSize: 16,
              //                                   fontWeight: FontWeight.w600,
              //                                 ),
              //                               ),
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 );
              //               },
              //             ),
              //           ),
              //         ),
              //       ),
              //
              //       // Dots indicator
              //       Positioned(
              //         bottom: 10,
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: sliderImages.asMap().entries.map((entry) {
              //             return Container(
              //               width: 8.0,
              //               height: 8.0,
              //               margin: const EdgeInsets.symmetric(horizontal: 4.0),
              //               decoration: BoxDecoration(
              //                 shape: BoxShape.circle,
              //                 color: _currentCarouselIndex == entry.key
              //                     ? Colors.white
              //                     : Colors.white54,
              //               ),
              //             );
              //           }).toList(),
              //         ),
              //       ),
              //     ],
              //   ),
              //
              // const SizedBox(height: 20),

              // 4. Popular Dishes Horizontal Scroll (Image left, text right)
              // 4. Popular Dishes Section (Final Final Version)
              if (popularDishes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Popular Dishes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CarouselSlider.builder(
                      itemCount: popularDishes.length,
                      itemBuilder: (context, index, _) {
                        final dish = popularDishes[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 40),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // ⭐ CARD BACKGROUND
                              Container(
                                padding: const EdgeInsets.fromLTRB(12, 55, 12, 65), // TOP & BOTTOM increased
                                decoration: BoxDecoration(
                                  color: hexToColor("#75E679"),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // ⭐ Dish Name
                                    Text(
                                      dish['name'] ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // ⭐ DESCRIPTION — fully visible now
                                    // ⭐ DESCRIPTION — ellipsized & safe inside card
                                    Text(
                                      dish['description'] ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,                 // ⭐ stays inside
                                      overflow: TextOverflow.ellipsis,   // ⭐ prevents overlap
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ⭐ CIRCULAR IMAGE (Top Edge - Perfect Fit)
                              Positioned(
                                top: -35,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: (dish['image'] == null || dish['image'].toString().isEmpty)
                                          ? Image.asset(
                                        'assets/images/placeholder1.png',
                                        width: 76,
                                        height: 76,
                                        fit: BoxFit.cover,
                                      )
                                          : CachedNetworkImage(
                                        imageUrl: "${Constants.imageBaseUrl1}/${dish['image']}",
                                        width: 76,
                                        height: 76,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Image.asset(
                                          'assets/images/placeholder1.png',
                                          width: 76,
                                          height: 76,
                                          fit: BoxFit.cover,
                                        ),
                                        errorWidget: (_, __, ___) => Image.asset(
                                          'assets/images/placeholder1.png',
                                          width: 76,
                                          height: 76,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ⭐ BUTTON — smaller height & aligned bottom
                              Positioned(
                                bottom: -18,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final info = await StorageService.getRestaurantInfo();
                                      final token = await StorageService.getToken();
                                      final slug = info?['slug'];

                                      if (token != null && token.isNotEmpty && slug != null) {
                                        widget.onGoToOrder?.call();
                                      } else {
                                        widget.onGoToAccount?.call();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hexToColor("#0D7C11"),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 0, // reduced height
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: const Text(
                                      "Order Now",
                                      style: TextStyle(
                                        fontSize: 12.8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 265,        // ⭐ card height increased
                        autoPlay: false,
                        enlargeCenterPage: false,
                        viewportFraction: 0.52,
                        enableInfiniteScroll: true,
                      ),
                    ),
                  ],
                ),





              const SizedBox(height: 24),

              // 5. Featured Images Section
              if (featuredImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Gallery",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CarouselSlider.builder(
                      itemCount: featuredImages.length,
                      itemBuilder: (context, index, _) {
                        final item = featuredImages[index];
                        final imageUrl = item['url'] ?? '';

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          // use exact integer sizes for crisp borders
                          width: 104,
                          height: 104,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // white background behind image (prevents visual artifacts)
                                  color: Colors.white,
                                  // crisp border around circle
                                  border: Border.all(
                                    color: const Color(0xFF0D7C11),
                                    width: 3, // integer width for sharpness
                                  ),
                                  // the image is painted by the DecorationImage on the same container
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              );
                            },
                            // placeholder: show same circular shape with local asset
                            placeholder: (context, url) {
                              return Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFF0D7C11),
                                    width: 3,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/placeholder1.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            // error widget: same circular placeholder
                            errorWidget: (context, url, error) {
                              return Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFF0D7C11),
                                    width: 3,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/placeholder1.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },

                      options: CarouselOptions(
                        height: 130,
                        autoPlay: true,
                        enableInfiniteScroll: true,
                        enlargeCenterPage: false,
                        viewportFraction: 0.2,
                      ),
                    ),
                  ],
                ),


              const SizedBox(height: 24),

              // 6. Gallery Section (Staggered Grid)
              // 6. Gallery Section (Carousel with Overlay)
              if (galleryImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Text(
                    //     "Gallery",
                    //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    // const SizedBox(height: 12),

                    CarouselSlider.builder(
                      itemCount: galleryImages.length,
                      itemBuilder: (context, index, _) {
                        final img = galleryImages[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                /// Image
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: img['url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                /// Overlay (Beautiful subtle opacity)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.25),
                                        Colors.black.withOpacity(0.10),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 200,
                        autoPlay: true,
                        viewportFraction: 0.90,      // 👈 Only 1 image visible
                        enlargeCenterPage: true,
                        enlargeFactor: 0.12,         // Smooth zoom effect
                        autoPlayCurve: Curves.easeInOut,
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                      ),
                    ),
                  ],
                ),


              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}