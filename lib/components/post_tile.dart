// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/database_provider.dart';

class PostTile extends StatefulWidget {
  const PostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final listeningDatabaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: true,
  );
  late final notListeningDatabaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  void _showOptions() {
    final auth = AuthService();
    String currentUid = auth.currentUser.uid;
    final bool isPostOwner = currentUid == widget.post.uid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isPostOwner)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () async {
                    Navigator.pop(context);
                    await notListeningDatabaseProvider.deletePostFromFirebase(
                      widget.post.id,
                    );
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
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text('block @${widget.post.username}'),
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
    final theme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,

          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primary.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withOpacity(0.5),
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
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primary.withOpacity(0.2),
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
                    widget.post.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '@${widget.post.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),

                IconButton(
                  icon: const Icon(Icons.
                  more_horiz),
                  onPressed: _showOptions,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 19,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
