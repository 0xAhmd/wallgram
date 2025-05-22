import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/comment_box.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/components/shimmers/comment_shimmer.dart';
import 'package:wallgram/helper/global_banner.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/pages/profile_page.dart';
import 'package:wallgram/services/provider/app_provider.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.post});
  final Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final listiningDatabaseProvider = Provider.of<AppProvider>(
    context,
    listen: true,
  );
  late final databaseProvider = Provider.of<AppProvider>(
    context,
    listen: false,
  );
  bool isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => isLoadingComments = true);
    await databaseProvider.loadComments(widget.post.id);
    if (mounted) setState(() => isLoadingComments = false);
  }

  @override
  Widget build(BuildContext context) {
    final allComments = listiningDatabaseProvider.getComments(widget.post.id);
    allComments.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      appBar: GlobalAppBarWrapper(
        appBar: AppBar(
          title: Text(widget.post.username),
          centerTitle: true,
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: ListView(
        children: [
          PostTile(
            post: widget.post,
            onUserTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.post.uid),
                ),
              );
            },
            onPostTap: () {},
          ),

          allComments.isEmpty
              ? Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              )
              : isLoadingComments
              ? const CommentShimmer()
              : allComments.isEmpty
              ? Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              )
              : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: allComments.length,
                itemBuilder: (context, index) {
                  final comment = allComments[index];
                  return CommentBox(
                    postId: widget.post.id,
                    comment: comment,
                    onUserTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: comment.uid),
                        ),
                      );
                    },
                  );
                },
              ),
        ],
      ),
    );
  }
}
