import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wallgram/services/auth/auth_service.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});
  static const String routeName = '/account-settings';

  @override
  Widget build(BuildContext context) {
    void _showDeleteConfirmationBox() {
      QuickAlert.show(
        onConfirmBtnTap: () async {
          AuthService().deleteUserAccount();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        context: context,
        type: QuickAlertType.error,
        title: "Warning, this action is irreversible",
        text: "Are you sure you want to Permanently delete your account?",
        confirmBtnText: "Yes",
        showCancelBtn: true,
        confirmBtnColor: Colors.red,
        cancelBtnText: "Cancel",

        cancelBtnTextStyle: const TextStyle(color: Colors.black),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Account Settings', style: TextStyle(fontSize: 25)),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showDeleteConfirmationBox(),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: const Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 21, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
