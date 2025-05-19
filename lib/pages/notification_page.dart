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
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];

              return Container(
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
                    color:
                        notification['read']
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                  ),

                  title: Text(notification['message']),
                  subtitle: Text(
                    DateFormat(
                      'MMM dd, hh:mm a',
                    ).format((notification['timestamp'] as Timestamp).toDate()),
                  ),
                  onTap: () async {
                    try {
                      // Get notification ID
                      final notificationId = notification['id'];

                      // Mark as read
                      provider.markNotificationAsRead(notificationId);

                      // Get post ID from notification
                      final postId = notification['postId'];

                      // Fetch post from Firestore
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
              );
            },
          );
        },
      ),
    );
  }
}
