import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/settings_list_tile.dart';
import 'package:wallgram/helper/global_banner.dart';
import 'package:wallgram/pages/account_settings_page.dart';
import 'package:wallgram/pages/block_list_page.dart';
import 'package:wallgram/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Mode'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Mode'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  themeProvider.setThemeMode(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: GlobalAppBarWrapper(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('S E T T I N G S', style: TextStyle(fontSize: 26)),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Column(
        children: [
          GestureDetector(
            onTap: () => _showThemeSelector(context),
            child: MySettingsListTile(
              title: 'App Theme',
              action: Row(
                children: [
                  Text(
                    themeProvider.themeMode.toString().split('.')[1],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
          ),
          // Keep other list tiles
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, BlockListPage.routeName);
            },
            child: const MySettingsListTile(
              title: "Block List",
              action: Icon(Icons.arrow_circle_right_outlined),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AccountSettingsPage.routeName);
            },
            child: const MySettingsListTile(
              title: "Account Settings",
              action: Icon(Icons.arrow_circle_right_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
