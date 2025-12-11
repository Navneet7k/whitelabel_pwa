import 'package:flutter/material.dart';

import '../app_themes.dart';
import '../storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color? dynamicColor;

  @override
  void initState() {
    super.initState();
    _loadDynamicThemeColor();
  }

  Future<void> _loadDynamicThemeColor() async {
    final appInfo = await StorageService.getAppInfo();
    final hex = appInfo?['theme_color'];

    if (hex != null && hex.isNotEmpty) {
      final color = AppThemes.hexToColor(hex);
      setState(() {
        dynamicColor = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeTiles = <Widget>[
      if (dynamicColor != null)
        ThemeOptionTile(index: 0, name: "Dynamic", color: dynamicColor!),
      ThemeOptionTile(index: 1, name: "Purple", color: Colors.deepPurple),
      ThemeOptionTile(index: 2, name: "Green", color: Colors.green),
      ThemeOptionTile(index: 3, name: "Orange", color: Colors.deepOrange),
      ThemeOptionTile(index: 4, name: "Grey", color: Colors.grey),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const ListTile(title: Text("Choose App Theme")),
          ...themeTiles,
        ],
      ),
    );
  }
}

class ThemeOptionTile extends StatelessWidget {
  final int index;
  final String name;
  final Color color;

  const ThemeOptionTile({
    required this.index,
    required this.name,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color),
      title: Text('$name Theme'),
      onTap: () => Navigator.pop(context, index),
    );
  }
}
