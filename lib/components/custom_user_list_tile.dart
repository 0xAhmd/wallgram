import 'package:flutter/material.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/pages/profile_page.dart';

class CustomUserListTile extends StatelessWidget {
  const CustomUserListTile({super.key, required this.user});
  final UserProfile user;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: ListTile(
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        subtitleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
        ),
        subtitle: Text('@' + user.username),

        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: user.uid),
              ),
            ),

        trailing: Icon(
          Icons.arrow_right_alt,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
