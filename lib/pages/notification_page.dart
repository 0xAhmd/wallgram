import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/pages/post_page.dart';
import 'package:wallgram/services/database/database_provider.dart';

class notificationsPage extends StatelessWidget {
  const notificationsPage({super.key});
  static const String routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'N O T I F I C A T I O N S',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          Consumer<DatabaseProvider>(
            builder: (context, provider, _) {
              return IconButton(
                padding: const EdgeInsets.only(right: 18),
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark all as read',
                onPressed: () {
                  provider.markAllNotificationsAsRead();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, _) {
          final unreadNotifications =
              provider.notifications.where((n) => !n['read']).toList();

          return ListView.builder(
            itemCount: unreadNotifications.length,
            itemBuilder: (context, index) {
              final notification = unreadNotifications[index];

              return Dismissible(
                key: Key(notification['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  color: Colors.green,
                  child: const Icon(Icons.done_all_sharp, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.markNotificationAsRead(notification['id']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: ListTile(
                    leading: Icon(
                      notification['type'] == 'comment'
                          ? Icons.comment
                          : Icons.notifications,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(notification['message']),
                    subtitle: Text(
                      DateFormat('MMM dd, hh:mm a').format(
                        (notification['timestamp'] as Timestamp).toDate(),
                      ),
                    ),
                    onTap: () async {
                      try {
                        final notificationId = notification['id'];
                        provider.markNotificationAsRead(notificationId);

                        final postId = notification['postId'];
                        final postDoc =
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(postId)
                                .get();

                        if (postDoc.exists) {
                          final post = Post.fromDocument(postDoc);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostPage(post: post),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post no longer exists'),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error navigating to post: $e');
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
