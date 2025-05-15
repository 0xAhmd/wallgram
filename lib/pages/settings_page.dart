import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/settings_list_tile.dart';
import 'package:wallgram/pages/account_settings_page.dart';
import 'package:wallgram/pages/block_list_page.dart';
import 'package:wallgram/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('S E T T I N G S', style: TextStyle(fontSize: 26)),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Column(
        children: [
          MySettingsListTile(
            title: 'Dark Mode',
            action: CupertinoSwitch(
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
            ),
          ),

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
