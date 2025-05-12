import 'package:flutter/material.dart';
import 'package:wallgram/components/drawer_list_tile.dart';
import 'package:wallgram/pages/login_page.dart';
import 'package:wallgram/pages/settings_page.dart';
import 'package:wallgram/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final authService = AuthService();
  void logoutUser(BuildContext context) async {
    await authService.logoutUser();
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginPage.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Image.asset('assets/wall.png', width: 100),
              ),
              Divider(color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 10),
              DrawerListTile(
                icon: Icons.home,
                title: 'H O M E',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              DrawerListTile(
                icon: Icons.settings,
                title: 'S E T T I N G S',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              const Spacer(),
              DrawerListTile(
                icon: Icons.logout,
                title: 'L O G O U T',
                onTap:  () {
                  logoutUser(context);
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
