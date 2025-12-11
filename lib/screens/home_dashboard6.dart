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


class HomeDashboard6 extends StatefulWidget {
  final VoidCallback? onGoToAccount,onGoToOrder;
  const HomeDashboard6({super.key, this.onGoToAccount,this.onGoToOrder});

  @override
  State<HomeDashboard6> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashboard6> {
  List<dynamic> sliderImages = [];
  Map<String, dynamic>? points;
  Map<String, dynamic>? restaurant,colorsMain;
  List<dynamic> popularDishes = [];
  List<dynamic> featuredImages = [];
  List<dynamic> galleryImages = [];
  List<dynamic> recentOrders = [];
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
    final recent = await StorageServiceV2.getRecentOrders();  // ⬅️ Fetch recent orders
    final colors = await StorageService.getAppColors();

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
        recentOrders = recent;
        colorsMain = colors;
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
      backgroundColor:  (colorsMain?['body-color'] != null)
          ? hexToColor(colorsMain!['body-color'])
          : Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // // 🖼️ Background Image Layer
            // Image.asset(
            //     'assets/images/pattern3.png', // 👈 your background image path
            //     fit: BoxFit.cover,
            //     width: double.infinity,
            //     height: double.infinity,
            //   ),
            //   Container(
            //     color: Colors.black.withOpacity(0.8), // 👈 tint overlay
            //   ),
            RefreshIndicator(
              onRefresh: _loadAllData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

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
                                        // Smooth gradient: top 80% = 0.4 opacity → bottom 20% = 0.8 opacity
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color.fromRGBO(0, 0, 0, 0.4), // top opacity
                                                    Color.fromRGBO(0, 0, 0, 0.8), // keep 0.4 for 80%
                                                    Color.fromRGBO(0, 0, 0, 0.8), // bottom opacity
                                                  ],
                                                  stops: [
                                                    0.0,
                                                    0.80, // top 80% = 0.4 opacity
                                                    1.0,  // bottom = 0.8 opacity
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          left: 16,
                                          bottom: 40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Welcome to \n${restaurant?['name'] ?? 'Restaurant'}",
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 28,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // ElevatedButton(
                                              //   onPressed: () async {
                                              //     final data =
                                              //     await StorageService.getRestaurantInfo();
                                              //     final token = await StorageService.getToken();
                                              //     final slug = data?['slug'];
                                              //     if (token != null &&
                                              //         token.isNotEmpty &&
                                              //         slug != null) {
                                              //       widget.onGoToOrder?.call();
                                              //     } else {
                                              //       widget.onGoToAccount?.call();
                                              //     }
                                              //   },
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor: hexToColor(savedHexColor!),
                                              //     padding: const EdgeInsets.symmetric(
                                              //         horizontal: 20, vertical: 7),
                                              //     shape: RoundedRectangleBorder(
                                              //       borderRadius: BorderRadius.circular(8),
                                              //     ),
                                              //     elevation: 4,
                                              //   ),
                                              //   child: const Text(
                                              //     "Order Now",
                                              //     style: TextStyle(
                                              //       color: Colors.white,
                                              //       fontSize: 16,
                                              //       fontWeight: FontWeight.w600,
                                              //     ),
                                              //   ),
                                              // ),
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

                  // const SizedBox(height: 10),

                  // 5. Featured Images Section
                  if (featuredImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                        //   child: Text(
                        //     "Featured Images",
                        //     style: TextStyle(
                        //       fontSize: 18,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.white, // 🔥 Make title text white
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 12),

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
                                        color: Colors.white,
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
                  Container(
                    height: 1,                  // thickness of the line
                    color: Colors.white.withOpacity(0.1),  // semi-transparent white
                    margin: const EdgeInsets.symmetric(horizontal: 20), // optional horizontal padding
                  ),
                  const SizedBox(height: 20),


                  // 🎯 Loyalty Points Card with WebView behavior (improved positioning)
                  if (points != null && userToken?.isNotEmpty == true)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const double circleDiameter = 140;
                          const double circleRadius = circleDiameter / 2;
                          final double rectHeight = circleDiameter * 0.75;

                          return SizedBox(
                            height: circleDiameter, // ensures stack has same height as circle
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                /// =============== WHITE RECTANGLE (LEFT SHIFTED) ===============
                                Positioned(
                                  left: circleRadius, // begins at circle center
                                  top: ((circleDiameter - rectHeight) / 2)-5, // vertical center alignment
                                  child: Card(
                                    color: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(60),
                                        bottomLeft: Radius.circular(60),
                                        topRight: Radius.circular(24),
                                        bottomRight: Radius.circular(24),
                                      ),
                                    ),
                                    child: SizedBox(
                                      height: rectHeight,
                                      width: constraints.maxWidth - circleRadius,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18),
                                        child: Row(
                                          children: [
                                            /// extra spacing equal to radius to avoid touching circle
                                            SizedBox(width: (circleRadius * 0.75)+20),

                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Grab Points For\nEach Order",
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),

                                                  GestureDetector(
                                                    onTap: () async {
                                                      final token = await StorageService.getToken();
                                                      final url =
                                                          'https://app.zingmyorder.com/client/app/points/${Constants.restaurantId}?token=$token';
                                                      openWebView(url);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 16, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: (colorsMain?['body-color'] != null)
                                                            ? hexToColor(colorsMain!['body-color'])
                                                            : Colors.black,
                                                        borderRadius: BorderRadius.circular(24),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: const [
                                                          Text(
                                                            "Learn More",
                                                            style: TextStyle(
                                                                fontFamily: 'Poppins',
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w400
                                                            ),
                                                          ),
                                                          SizedBox(width: 12),
                                                          // Icon(Icons.arrow_forward_ios_rounded,
                                                          //     size: 12, color: Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// ===================== CIRCLE =====================
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: circleDiameter,
                                    height: circleDiameter,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (colorsMain?['body-color'] != null)
                                          ? hexToColor(colorsMain!['body-color']).withOpacity(0.90)
                                          : Colors.black54.withOpacity(0.90),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.8),
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${points!['total_amount']}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 40,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            "Pts",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (points != null && userToken?.isNotEmpty == true)
                   const SizedBox(height: 24),
                  if (points != null && userToken?.isNotEmpty == true)
                   Container(
                    height: 1,                  // thickness of the line
                    color: Colors.white.withOpacity(0.1),  // semi-transparent white
                    margin: const EdgeInsets.symmetric(horizontal: 20), // optional horizontal padding
                  ),
                  if (points != null && userToken?.isNotEmpty == true)
                   const SizedBox(height: 20),

                  //recent orders
                  if (recentOrders.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Recent Orders",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        CarouselSlider.builder(
                          itemCount: recentOrders.length,
                          itemBuilder: (context, index, _) {
                            final order = recentOrders[index];

                            // Extract required fields
                            final detail = order['detail'] ?? [];
                            final firstDetail = detail.isNotEmpty ? detail[0] : null;

                            final menu = firstDetail?['menu'] ?? {};
                            final name = menu['name'] ?? "Item";
                            final itemCount = detail.length;

                            final images = menu['image'] ?? [];
                            final imageUrl = images.isNotEmpty ? images[0]['path'] ?? "" : "";

                            final imgU="${Constants.imageBaseUrl2}/$imageUrl";

                            // Date formatting
                            final rawDate = order['created_at'] ?? "";
                            String formattedDate = "";
                            try {
                              if (rawDate.isNotEmpty) {
                                final date = DateTime.parse(rawDate);
                                formattedDate =
                                "${date.day} ${_monthName(date.month)} ${date.year}";
                              }
                            } catch (_) {}

                            final amount = detail[0]['price']?.toString() ?? "";

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 165,
                                  child: Row(
                                    children: [
                                      /// IMAGE
                                      Container(
                                        margin: const EdgeInsets.all(12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: (imgU.isEmpty)
                                              ? Image.asset(
                                            'assets/images/placeholder1.png',
                                            width: 140,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          )
                                              : CachedNetworkImage(
                                            imageUrl: imgU,
                                            width: 140,
                                            height: 110,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/placeholder1.png',
                                            ),
                                            errorWidget: (context, url, error) =>
                                                Image.asset('assets/images/placeholder1.png'),
                                          ),
                                        ),
                                      ),

                                      /// TEXT CONTENT
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 20,
                                            top: 20,
                                            bottom: 20,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              /// NAME
                                              // Text(
                                              //   name,
                                              //   maxLines: 2,
                                              //   overflow: TextOverflow.ellipsis,
                                              //   style: const TextStyle(
                                              //     fontFamily: 'Poppins',
                                              //     fontSize: 14,
                                              //     color: Colors.black87,
                                              //     fontWeight: FontWeight.w500,
                                              //     height: 1.2,
                                              //   ),
                                              // ),

                                              /// DATE
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black54,
                                                  fontSize: 11,
                                                ),
                                              ),

                                              /// ITEM COUNT
                                              Text(
                                                "$itemCount item${itemCount > 1 ? 's' : ''}",
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),

                                              /// PRICE
                                              Text(
                                                "\$ $amount",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),

                                              /// ORDER NOW BUTTON
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final data = await StorageService.getRestaurantInfo();
                                                  final token = await StorageService.getToken();
                                                  final slug = data?['slug'];

                                                  if (token != null && token.isNotEmpty && slug != null) {
                                                    widget.onGoToOrder?.call();
                                                  } else {
                                                    widget.onGoToAccount?.call();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: (colorsMain?['body-color'] != null)
                                                      ? hexToColor(colorsMain!['body-color'])
                                                      : Colors.black,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16), // horizontal padding only
                                                  minimumSize: const Size(0, 28), // 🔥 control button height here
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // optional, removes extra touch padding
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Text(
                                                      "Order Again",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Icon(
                                                      Icons.shopping_cart,
                                                      size: 14, // slightly smaller to match reduced height
                                                      color: Colors.white,
                                                    ),
                                                  ],
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
                            height: 165,
                            autoPlay: false,
                            enlargeCenterPage: false,
                            viewportFraction: 0.85,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  Container(
                    height: 1,                  // thickness of the line
                    color: Colors.white.withOpacity(0.2),  // semi-transparent white
                    margin: const EdgeInsets.symmetric(horizontal: 20), // optional horizontal padding
                  ),
                  const SizedBox(height: 20),


                  // 4. Popular Dishes Horizontal Scroll (Image left, text right)
                  if (popularDishes.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Popular Dishes",
                            style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,),
                          ),
                        ),
                        const SizedBox(height: 12),

                        CarouselSlider.builder(
                          itemCount: popularDishes.length,
                          itemBuilder: (context, index, _) {
                            final dish = popularDishes[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 3),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 135,
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: (dish['image'] == null || dish['image'].toString().isEmpty)
                                              ? Image.asset(
                                            'assets/images/placeholder1.png',
                                            width: 140,
                                            height: 95,
                                            fit: BoxFit.cover,
                                          )
                                              : CachedNetworkImage(
                                            imageUrl: "${Constants.imageBaseUrl1}/${dish['image']}",
                                            width: 140,
                                            height: 95,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/placeholder1.png',
                                              width: 140,
                                              height: 95,
                                              fit: BoxFit.cover,
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              'assets/images/placeholder1.png',
                                              width: 140,
                                              height: 95,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                                  fontSize: 15,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dish['description'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final data = await StorageService.getRestaurantInfo();
                                                  final token = await StorageService.getToken();
                                                  final slug = data?['slug'];

                                                  if (token != null && token.isNotEmpty && slug != null) {
                                                    widget.onGoToOrder?.call();
                                                  } else {
                                                    widget.onGoToAccount?.call();
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: (colorsMain?['body-color'] != null)
                                                      ? hexToColor(colorsMain!['body-color'])
                                                      : Colors.black,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16), // horizontal padding only
                                                  minimumSize: const Size(0, 28), // 🔥 control button height here
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // optional, removes extra touch padding
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Text(
                                                      "Order Now",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Icon(
                                                      Icons.shopping_cart,
                                                      size: 14, // slightly smaller to match reduced height
                                                      color: Colors.white,
                                                    ),
                                                  ],
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
                            height: 150,
                            autoPlay: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 1.0, // 🔥 Only one item visible at a time
                          ),
                        ),
                      ],
                    ),



                  const SizedBox(height: 24),
                  Container(
                    height: 1,                  // thickness of the line
                    color: Colors.white.withOpacity(0.2),  // semi-transparent white
                    margin: const EdgeInsets.symmetric(horizontal: 20), // optional horizontal padding
                  ),
                  const SizedBox(height: 20),



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
                                          child:  Icon(
                                            Icons.phone_outlined,
                                            color: (colorsMain?['body-color'] != null)
                                                ? hexToColor(colorsMain!['body-color'])
                                                : Colors.black,
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
                                          child:  Icon(
                                            Icons.home_outlined,
                                            color: (colorsMain?['body-color'] != null)
                                                ? hexToColor(colorsMain!['body-color'])
                                                : Colors.black,
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
                                          backgroundColor: (colorsMain?['body-color'] != null)
                                              ? hexToColor(colorsMain!['body-color'])
                                              : Colors.black,
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


                  // 6. Gallery Section (Horizontal Card Slider — overlapped center)
                  if (galleryImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Gallery",
                            style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 280, // give some room for scaling & shadow
                          child: _GalleryCardSlider(images: galleryImages),
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

  String _monthName(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month];
  }
}

class _GalleryCardSlider extends StatefulWidget {
  final List images;
  const _GalleryCardSlider({super.key, required this.images});

  @override
  State<_GalleryCardSlider> createState() => _GalleryCardSliderState();
}

class _GalleryCardSliderState extends State<_GalleryCardSlider> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        final H = constraints.maxHeight;

        // Rectangular cards
        final cardWidth = W * 0.55;
        final cardHeight = H * 0.95;
        final overlapOffset = cardWidth * 0.45;
        final centerX = (W - cardWidth) / 2;

        // Sort by distance to make center card on top
        final orderedIndices = List.generate(widget.images.length, (i) => i)
          ..sort((a, b) {
            final distA = (a - _currentPage).abs();
            final distB = (b - _currentPage).abs();
            return distB.compareTo(distA); // farthest first
          });

        return Stack(
          children: [
            ...orderedIndices.map((index) {
              final distance = index - _currentPage;

              // Scale for side cards
              final scale = (1 - distance.abs() * 0.25).clamp(0.78, 1.0);

              // Horizontal position
              double x = centerX + distance * overlapOffset;

              // Optional: for previous side show 2 items with smaller offset
              if (distance < 0) {
                // make two previous items visible more clearly
                x = centerX + distance * overlapOffset * 0.9;
              }

              return Positioned(
                left: x,
                top: (H - cardHeight * scale) / 2,
                width: cardWidth * scale,
                height: cardHeight * scale,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index]['url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

            // Gesture PageView
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, __) => const SizedBox(),
              ),
            )
          ],
        );
      },
    );
  }
}







