import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/drawer.dart';
import 'package:wallgram/components/my_input_dialog_box.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

TextEditingController _postController = TextEditingController();

class _HomePageState extends State<HomePage> {
  late DatabaseProvider dataprovider;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      dataprovider = Provider.of<DatabaseProvider>(context);
      dataprovider.loadAllPosts();
      _isInitialized = true;
    }
  }

  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder:
          (context) => MyInputDialogBox(
            controller: _postController,
            hintText: 'Drop a post',
            onPressedText: 'POST',
            onPressed: () async {
              await dataprovider.postMessage(_postController.text);
              _postController.clear();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<DatabaseProvider>().allPosts;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.edit),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text('H O M E'),
      ),
      body: _buildPostsList(posts),
    );
  }

  Widget _buildPostsList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(child: Text('No posts yet'))
        : ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostTile(post: post);
          },
        );
  }
}
