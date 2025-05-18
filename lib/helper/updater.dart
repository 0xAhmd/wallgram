import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdater {
  static const String _repoOwner = '0xAhmd';
  static const String _repoName = 'wallgram';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        final latestVersion = release['tag_name'].replaceAll('v', '');
        final apkUrl = release['html_url']; // Or use browser_download_url

        if (_isNewerVersion(packageInfo.version, latestVersion)) {
          _showUpdateDialog(context, apkUrl); // Non-blocking dialog
        }
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    return latest.compareTo(current) > 0;
  }

  static void _showUpdateDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('New Version Available'),
        content: const Text('A new version is available. Would you like to update?'),
        actions: [
          TextButton(
            child: const Text('Later'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () {
              launchUrl(Uri.parse(url));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}