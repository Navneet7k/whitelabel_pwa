import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zing_whitelabel_revamp/constants.dart';
import '../StorageServiceV2.dart';
import '../storage_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int? _selectedCategoryId;
  String? _selectedCategoryName;
  Map<String, dynamic>? _selectedGroup;
  Color? _themeColor;
  Map<String, dynamic>? colorsMain;

  bool _isGroupMode = false;
  bool _showingGroupView = false;

  @override
  void initState() {
    super.initState();
    _loadThemeColor();
    _checkIsGroupMode();
  }

  Future<void> _checkIsGroupMode() async {
    final isGroup = await StorageService.getIsGroup();
    if (isGroup?.toLowerCase() == "yes") {
      setState(() {
        _isGroupMode = true;
        _showingGroupView = true;
      });
    }
  }

  Color hexToColor(String hex, {double opacity = 1.0}) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16)).withOpacity(opacity);
  }

  Future<void> _loadThemeColor() async {
    final hex = await StorageServiceV2.getThemeColorHex();
    final colors = await StorageService.getAppColors();
    setState(() {
      _themeColor = hex != null ? hexToColor(hex) : Colors.blue;
      colorsMain = colors;
    });
  }

  Future<List<dynamic>> _getCategories() => StorageService.getCategories();
  Future<List<dynamic>> _getGroups() => StorageService.getGroups();

  Future<List<dynamic>> _getMenuItemsByCategory(int categoryId) async {
    final allItems = await StorageService.getMenuItems();
    return allItems.where((item) => item['category_id'] == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_themeColor == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final backgroundColor = _themeColor!.withOpacity(0.05);

    return Scaffold(
      backgroundColor: getNewSchemeBgColor(),
      appBar: AppBar(
        backgroundColor: getNewSchemeBgColor(),
        title: Text(_selectedCategoryName ??
            (_selectedGroup != null ? _selectedGroup!['name'] : "Menu"),style: TextStyle(color: Constants.design == "4"?Colors.grey:Colors.black)),
        actions: _isGroupMode
            ? [
          IconButton(
            icon: Icon(_showingGroupView ? Icons.view_module : Icons.category),
            onPressed: () {
              setState(() {
                _selectedCategoryId = null;
                _selectedCategoryName = null;
                _selectedGroup = null;
                _showingGroupView = !_showingGroupView;
              });
            },
          ),
        ]
            : null,
        leading: (_selectedCategoryId != null || _selectedGroup != null)
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedCategoryId = null;
              _selectedCategoryName = null;
              _selectedGroup = null;
            });
          },
        )
            : null,
      ),
      body: Stack(
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
          if (Constants.design == "5")
            Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 colors: [
                   Color(0xFF75E6DA),
                   Color(0xFF229D90),
                 ],
               ),
             ), // 👈 tint overlay
            ),
          FutureBuilder<List<dynamic>>(
            future: _selectedCategoryId != null
                ? _getMenuItemsByCategory(_selectedCategoryId!)
                : _selectedGroup != null
                ? Future.value([]) // group detail handled separately
                : _showingGroupView
                ? _getGroups()
                : _getCategories(),
            builder: (context, snapshot) {
              if (_selectedGroup != null) {
                return _buildGroupDetail(_selectedGroup!);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text(_selectedCategoryId != null
                        ? "No menu items found"
                        : _showingGroupView
                        ? "No groups found"
                        : "No categories found"));
              }

              final data = snapshot.data!;
              if (_selectedCategoryId != null) {
                return _buildMenuItemList(data);
              } else if (_showingGroupView) {
                return _buildGroupGrid(data);
              } else {
                return _buildCategoryGrid(data);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Grid of groups
  Widget _buildGroupGrid(List<dynamic> groups) {
    return Padding(
      key: const ValueKey('groupGrid'),
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: groups.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          final imagePath = group['logo'] != null && group['logo'].isNotEmpty
              ? group['logo'][0]['path']
              : null;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedGroup = group;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: _themeColor!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: imagePath != null
                        ? ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: '${Constants.imageBaseUrl}/$imagePath',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    )
                        : const Icon(Icons.broken_image, size: 80),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      group['name'],
                      textAlign: TextAlign.center,
                      style:
                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Constants.design=="4"?Colors.grey:Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Group detail view: shows all categories as collapsible
  Widget _buildGroupDetail(Map<String, dynamic> group) {
    final categories = group['category'] as List<dynamic>? ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: ExpansionTile(
            title: Text(category['name'] ?? 'Category'),
            children: [
              FutureBuilder<List<dynamic>>(
                future: _getMenuItemsByCategory(category['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Error loading items"),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("No items"),
                    );
                  }
                  return Column(
                    children: items.map((item) {
                      final imageList = item['image'] as List<dynamic>?;
                      String? imageUrl;
                      if (imageList != null && imageList.isNotEmpty) {
                        imageUrl = '${Constants.imageBaseUrl}/${imageList[0]['path']}';
                      }
                      return ListTile(
                        leading: imageUrl != null
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.fastfood),
                        title: Text(item['name'] ?? ''),
                        subtitle: Text(item['description'] ?? ''),
                        trailing: Text(
                          "\$${item['price']}",
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category['id'];
                            _selectedCategoryName = category['name'];
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid(List<dynamic> categories) {
    return Padding(
      key: const ValueKey('categoryGrid'),
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];

          String? imagePath;
          final menus = category['menu'] as List<dynamic>;
          for (var menuItem in menus) {
            final images = menuItem['image'] as List<dynamic>;
            if (images.isNotEmpty) {
              imagePath = images[0]['path'];
              break;
            }
          }

          return CategoryCard(
            name: category['name'],
            id: category['id'].toString(),
            imagePath: imagePath,
            backgroundColor: _themeColor!.withOpacity(0.12),
            textColor: Constants.design == "4"?Colors.grey:Colors.black,
            onTap: () {
              setState(() {
                _selectedCategoryId = category['id'];
                _selectedCategoryName = category['name'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuItemList(List<dynamic> menuItems) {
    return ListView.separated(
      key: const ValueKey('menuItemList'),
      padding: const EdgeInsets.all(12),
      itemCount: menuItems.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final imageList = item['image'] as List<dynamic>?;
        String? imageUrl;

        if (imageList != null && imageList.isNotEmpty) {
          final path = imageList[0]['path'];
          imageUrl = '${Constants.imageBaseUrl}/$path';
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'],
                        style:  TextStyle(fontWeight: FontWeight.bold,color: Constants.design=="4"?Colors.white:Colors.black)),
                    const SizedBox(height: 4),
                    Text(item['description'] ?? '',style: TextStyle(color: Constants.design=="4"?Colors.white:Colors.black),),
                    const SizedBox(height: 4),
                    Text(
                      "\$${item['price']}",
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color? getNewSchemeBgColor() {
    if(Constants.design == "2")
      return const Color(0xFFFDF6E9);
    else if(Constants.design == "3")
      return hexToColor("#F9FAFA");
    else if(Constants.design == "4")
      return  Colors.black54;
    else if(Constants.design == "6")
      return  const Color(0xFF92E69C);
    else if(Constants.design == "8") {
      // return Colors.black54;
      return (colorsMain?['body-color'] != null)
          ? hexToColor(colorsMain!['body-color'])
          : Colors.black54;
    }
    else
      return _themeColor!.withOpacity(0.05);
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String id;
  final String? imagePath;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const CategoryCard({
    required this.name,
    required this.id,
    this.imagePath,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
