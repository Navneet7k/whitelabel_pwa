import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../storage_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> promoImages = [];
  List<Map<String, String>> recentOrders = [];
  bool isLoading = true;
  String loyaltyPoints = "0"; // ✅ Added this
  String? _token;
  bool _isTokenLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final sliders = await StorageService.getSliderImages();
    final featured = await StorageService.getFeaturedFood();
    final loyality_points = await StorageService.getUserPoints(); // This returns an int
    final token = await StorageService.getToken();

    setState(() {
      promoImages = sliders.map<String>((item) => item['url'] as String).toList();
      recentOrders = featured.map<Map<String, String>>((item) {
        return {
          'image': item['url'] ?? '',
          'name': item['caption'] ?? 'No name',
        };
      }).toList();
      loyaltyPoints = loyality_points ?? '0'; // ✅ Update state
      isLoading = false;

      if (token != null) {
        _token = token;
        _isTokenLoaded = true;
      } else{
        _token = null;
        _isTokenLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_token != null) ...[
            // Loyalty Points Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                leading: Icon(Icons.stars, color: Theme.of(context).colorScheme.onSecondaryContainer),
                title: const Text('Loyalty Points', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  '$loyaltyPoints', // ✅ Use the dynamic value here
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ],

            // Promo Carousel
            Text('Gallery', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            CarouselSlider(
              items: promoImages.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
              ),
            ),
            const SizedBox(height: 24),

            // Recently Ordered Slideshow
            Text(_token == null?'Popular Orders':'Recently Ordered', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentOrders.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: order['image']!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.fastfood),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(6.0),
                        //   child: Text(
                        //     order['name']!,
                        //     style: Theme.of(context).textTheme.bodyMedium,
                        //     textAlign: TextAlign.center,
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}