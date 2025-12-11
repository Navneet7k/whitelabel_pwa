import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:zing_whitelabel_revamp/screens/profile_screen.dart';

import '../StorageServiceV2.dart';
import '../constants.dart';
import '../storage_service.dart';
import 'GenericWebViewScreen.dart';
import 'OrderWebViewScreen.dart';


class CustomHomeDashboard extends StatefulWidget {
  final VoidCallback? onGoToAccount,onGoToOrder;
  const CustomHomeDashboard({super.key, this.onGoToAccount,this.onGoToOrder});

  @override
  State<CustomHomeDashboard> createState() => _CustomHomeScreenState();
}

class _CustomHomeScreenState extends State<CustomHomeDashboard> {
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
      backgroundColor: const Color(0xFFFDF6E9),
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
                        return Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer SVG border (downloaded from Figma)
                              SvgPicture.asset(
                                "assets/images/circle_slider_bg.svg", // <-- your custom SVG path
                                width: 320, // adjust size as needed
                                height: 320,
                                fit: BoxFit.contain,
                                color: hexToColor(savedHexColor ?? "#000000"),
                              ),

                              // Circular image with white border
                              Container(
                                padding: const EdgeInsets.all(2), // thin white border
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: image['url'],
                                    width: 200,  // adjust size
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 320,
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

              if (restaurant != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400, // normal
                        fontSize: 28,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: "Welcome to \n"),
                        TextSpan(
                          text: restaurant?['name'] ?? 'Restaurant',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, // bold only for restaurant name
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),


              // 🎯 Loyalty Points Card with WebView behavior
              // if (points != null && userToken?.isNotEmpty == true)
              //   Container(
              //     margin: const EdgeInsets.symmetric(horizontal: 15),
              //     child: Card(
              //       color: hexToColor(savedHexColor!),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              //         child: Row(
              //           children: [
              //             Expanded(
              //               flex: 4,
              //               child: Text(
              //                 "${points!['total_amount']}Pts",
              //                 style: const TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 30,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //             Expanded(
              //               flex: 6,
              //               child: GestureDetector(
              //                 onTap: () async {
              //                   final token = await StorageService.getToken();
              //                   final url = 'https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token';
              //                   openWebView(url);
              //                 },
              //                 child: const Text(
              //                   'Earn Points for Each Order. Learn More',
              //                   style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 14,
              //                   ),
              //                   textAlign: TextAlign.start,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),

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
                          color: hexToColor(savedHexColor ?? "#000000"), // ✅ Card color
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),

                              // ✅ Circular Image with border
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFA26161), // ✅ Border color
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: (dish['image'] == null ||
                                      dish['image'].toString().isEmpty)
                                      ? Image.asset(
                                    'assets/images/placeholder1.png',
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  )
                                      : CachedNetworkImage(
                                    imageUrl:
                                    "${Constants.imageBaseUrl1}/${dish['image']}",
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Image.asset(
                                      'assets/images/placeholder1.png',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                                    errorWidget: (context, url, error) => Image.asset(
                                      'assets/images/placeholder1.png',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ✅ Dish Name
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: (dish['name'] != null &&
                                    dish['name'].toString().length > 25)
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
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // ✅ Description
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  dish['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),

                              const Spacer(),

                              // ✅ Plus Icon instead of button
                              IconButton(
                                onPressed: () async {
                                  final data = await StorageService.getRestaurantInfo();
                                  final token = await StorageService.getToken();
                                  final slug = data?['slug'];
                                  if (token != null && token.isNotEmpty) {
                                    widget.onGoToOrder?.call();
                                  } else {
                                    widget.onGoToAccount?.call();
                                  }
                                },
                                icon: const Icon(Icons.add, size: 28, color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    const Color(0xFFA26161), // same as circle border
                                  ),
                                  shape: MaterialStateProperty.all(const CircleBorder()),
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),


              const SizedBox(height: 24),

              // 6. Gallery Section (Staggered Grid)
              if (galleryImages.isNotEmpty)
                StatefulBuilder(
                  builder: (context, setState) {
                    final PageController _pageController = PageController(viewportFraction: 0.7);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Gallery",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black, // keep consistent color
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            height: 220, // adjust height as needed
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: galleryImages.length,
                              itemBuilder: (context, index) {
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    double value = 1.0;
                                    if (_pageController.position.haveDimensions) {
                                      value = (_pageController.page! - index).abs();
                                      value = (1 - (value * 0.3)).clamp(0.8, 1.0); // scale effect
                                    }

                                    return Center(
                                      child: Transform.scale(
                                        scale: value,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: galleryImages[index]['url'],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // 5. Featured Images Section
              if (featuredImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Featured Images",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // keep consistent color
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Carousel instead of horizontal list
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        CarouselSlider.builder(
                          itemCount: featuredImages.length,
                          itemBuilder: (context, index, _) {
                            final item = featuredImages[index];
                            return Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // SVG background border
                                  SvgPicture.asset(
                                    "assets/images/featured_image_bg.svg",
                                    width: 320,
                                    height: 320,
                                    fit: BoxFit.contain,
                                    color: hexToColor(savedHexColor ?? "#000000"),
                                  ),

                                  // Circular image with border
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFA26161), width: 3),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: item['url'],   // <-- original featuredImages data
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, size: 50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                            height: 320,
                            viewportFraction: 1.0,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            onPageChanged: (index, _) {
                              setState(() => _currentCarouselIndex = index);
                            },
                          ),
                        ),

                        // Dots indicator
                        Positioned(
                          bottom: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: featuredImages.asMap().entries.map((entry) {
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