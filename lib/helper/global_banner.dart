import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/services/provider/internet_provider.dart';

class GlobalAppBarWrapper extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget appBar;

  const GlobalAppBarWrapper({super.key, required this.appBar});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<InternetProvider>().isConnected;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: isConnected
          ? appBar
          : PreferredSize(
              key: const ValueKey('offline-banner'),
              preferredSize: preferredSize,
              child: Container(
                color: Colors.red.shade700,
                alignment: Alignment.center,
                child: const SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
