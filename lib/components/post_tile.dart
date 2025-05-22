// ignore_for_file: deprecated_member_use, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wallgram/components/custom_bottom_sheet.dart';
import 'package:wallgram/components/expandable_text.dart';
import 'package:wallgram/helper/arabic_detector.dart';
import 'package:wallgram/helper/time_stamp_handler.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/provider/app_provider.dart';

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
  late final listeningDatabaseProvider = Provider.of<AppProvider>(
    context,
    listen: true,
  );
  late final notListeningDatabaseProvider = Provider.of<AppProvider>(
    context,
    listen: false,
  );
  String? _profileImageUrl;
  // ignore: unused_field
  bool _isLoadingImage = true;
  Future<void> _loadProfileImage() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.post.uid)
              .get();

      final data = userDoc.data();
      if (data != null && data['profileImage'] != null) {
        setState(() {
          _profileImageUrl = data['profileImage'];
        });
      }
    } catch (e) {
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  @override
  void initState() {
    _loadComments();
    _loadProfileImage();

    super.initState();
  }

  void _toggleLikePost() async {
    try {
      await notListeningDatabaseProvider.toggleLikes(widget.post.id);
    } catch (e) {}
  }

  void _openNewCommentBox() {
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return CustomBottomSheet(
          controller: _commentController,
          onPost: (comment) => _addComment(comment),
          title: 'New Comment',
          hintText: 'Add a comment...',
          buttonLabel: 'COMMENT',
        );
      },
    );
  }

  Future<void> _addComment(String comment) async {
    try {
      await notListeningDatabaseProvider.addComment(widget.post.id, comment);
    } catch (e) {}
  }

  Future<void> _loadComments() async {
    await notListeningDatabaseProvider.loadComments(widget.post.id);
  }

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
                    _reportPostConfirmationBox();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text('block @${widget.post.username}'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(
                      const Duration(milliseconds: 200),
                    ); // let the bottom sheet close
                    _blockUserConfirmationBox();
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

  void _reportPostConfirmationBox() {
    QuickAlert.show(
      onConfirmBtnTap: () async {
        await notListeningDatabaseProvider.reporUser(
          widget.post.id,
          widget.post.uid,
        );

        Navigator.pop(context);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Post reported successfully",
        );
      },
      context: context,
      type: QuickAlertType.warning,
      text: "Are you sure you want to report this post?",
      confirmBtnText: "Yes",
      showCancelBtn: true,
      confirmBtnColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _blockUserConfirmationBox() {
    QuickAlert.show(
      onConfirmBtnTap: () async {
        await notListeningDatabaseProvider.blockUser(widget.post.uid);

        Navigator.pop(context);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "User blocked successfully",
        );
      },
      context: context,
      type: QuickAlertType.warning,
      text: "Are you sure you want to block this user?",
      confirmBtnText: "Yes",
      showCancelBtn: true,
      confirmBtnColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    bool isPostLikedByCurrentUser = listeningDatabaseProvider
        .isPostLikedByCurrentUser(widget.post.id);
    int likesCount = listeningDatabaseProvider.getLikesCount(widget.post.id);
    int commentCount =
        listeningDatabaseProvider.getComments(widget.post.id).length;
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
        child: Directionality(
          textDirection:
              isArabic(widget.post.message)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
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
                      backgroundImage:
                          _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                      child:
                          _profileImageUrl == null
                              ? Icon(
                                Icons.person,
                                size: 18,
                                color: theme.primary,
                              )
                              : null,
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
                    icon: const Icon(Icons.more_horiz),
                    onPressed: _showOptions,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExpandableText(
                text: widget.post.message,
                textAlign:
                    isArabic(widget.post.message)
                        ? TextAlign.right
                        : TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 19,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child:
                            isPostLikedByCurrentUser
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : Icon(
                                  Icons.favorite_border,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          likesCount != 0 ? likesCount.toString() : '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _openNewCommentBox,
                        child: Icon(
                          Icons.comment,
                          color: Theme.of(context).colorScheme.primary,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          commentCount != 0 ? commentCount.toString() : '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    formatTimeStamp(widget.post.timestamp),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
