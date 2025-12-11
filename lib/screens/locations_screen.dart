import 'package:flutter/material.dart';
import '../constants.dart';
import '../storage_service.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<dynamic> locations = [];
  Map<String, dynamic>? colorsMain;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locs = await StorageService.getLocations();
    final colors = await StorageService.getAppColors();
    setState(() {
      locations = locs;
      colorsMain = colors;
    });
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
  }

  Color? getNewSchemeBgColor() {
    if(Constants.design == "2")
      return const Color(0xFFFDF6E9);
    else if(Constants.design == "3")
      return hexToColor("#F9FAFA");
    else if(Constants.design == "4")
      return  Colors.black54;
    else if(Constants.design == "8") {
      return (colorsMain?['body-color'] != null)
          ? hexToColor(colorsMain!['body-color'])
          : Colors.black54;
    }
    else
      return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getNewSchemeBgColor(),
      appBar: AppBar(
        backgroundColor: getNewSchemeBgColor(), // You can use theme color
        title:  Text("Locations",style: TextStyle(color:Constants.design=="4"?Colors.white:Colors.black54),),
        centerTitle: true,
        elevation: 0,
      ),
      body: locations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          if (Constants.design == "4")
            Positioned.fill(
              child: Image.asset(
                'assets/images/pattern3.png',
                fit: BoxFit.cover,
              ),
            ),
          if (Constants.design == "4")
          Container(
            color: Colors.black.withOpacity(0.8), // 👈 tint overlay
          ),

          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    // First card: Text
                    Container(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            loc['text'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Second card: Address, phone, email + button
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                            // leave space for button
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        loc['address'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        loc['phone'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.mail_outline, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        loc['email'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Order Now button
                        Positioned(
                          bottom: -20, // half overflow
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Open WebView or order logic
                                final url = loc['url'] ?? '';
                                if (url.isNotEmpty) {
                                  // Implement navigation to order
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hexToColor("#82a1c9"), // theme color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Order Now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
          ),
    );
  }
}
