// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/models/comment.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/provider/app_provider.dart';

class CommentBox extends StatelessWidget {
  const CommentBox({
    super.key,
    required this.comment,
    required this.onUserTap,
    required this.postId,
  });
  final Comment comment;
  final String postId;

  final void Function()? onUserTap;
  void _showOptions(BuildContext context) {
    final auth = AuthService();
    String currentUid = auth.currentUser.uid;
    final bool isCommentOwner = currentUid == comment.uid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isCommentOwner)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<AppProvider>(
                      context,
                      listen: false,
                    ).deleteComment(postId, comment.id);
                  },
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('report'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,

        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '@${comment.username}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),

              GestureDetector(
                onTap: () {
                  _showOptions(context);
                },
                child: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
