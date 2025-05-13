import 'package:flutter/material.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/pages/profile_page.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.post});
  final Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.username),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
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
        ],
      ),
    );
  }
}
