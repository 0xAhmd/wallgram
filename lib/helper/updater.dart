import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ForceUpdater {
  static const String _repoOwner = '0xAhmd';
  static const String _repoName = 'wallgram';

  static Future<void> checkForUpdates(BuildContext context) async {
   
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final response = await http
          .get(
            Uri.parse(
              'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        final latestVersion = release['tag_name'].replaceAll('v', '');
        final apkUrl = release['assets'][0]['browser_download_url'];

        if (_isNewerVersion(packageInfo.version, latestVersion)) {
          _showForceDialog(context, apkUrl);
        }
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    return latest.compareTo(current) > 0;
  }

  static void _showForceDialog(BuildContext context, String apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: false, // This prevents tapping outside to dismiss
      builder:
          (context) => AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'You must install the latest version to continue.',
            ),
            actions: [
              TextButton(
                child: const Text('EXIT APP'),
                onPressed: () => SystemNavigator.pop(),
              ),
              TextButton(
                child: const Text('UPDATE NOW'),
                onPressed: () => launchUrl(Uri.parse(apkUrl)),
              ),
            ],
          ),
    );
  }
}
