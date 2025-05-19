import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/custom_bottom_sheet.dart';
import 'package:wallgram/components/drawer.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/helper/updater.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/pages/notification_page.dart';
import 'package:wallgram/pages/post_page.dart';
import 'package:wallgram/pages/profile_page.dart';
import 'package:wallgram/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseProvider dataprovider;
  bool _isInitialized = false;
  bool _isRefreshing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      dataprovider = Provider.of<DatabaseProvider>(context);
      _loadInitialData();
      _isInitialized = true;
    }
  }

  Future<void> _loadInitialData() async {
    await dataprovider.loadAllPosts();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await dataprovider.loadAllPosts();
      await dataprovider.loadFollowingPosts();
    } catch (e) {
      debugPrint('Refresh failed: $e');
      // You could show a snackbar with the error here if you want
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _openPostMessageBox() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return CustomBottomSheet(
          controller: controller,
          title: 'New Post',
          hintText: 'Drop a post',
          buttonLabel: 'POST',
          onPost: (message) async {
            await dataprovider.postMessage(message);
            controller.clear();
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdater.checkForUpdate(context); // Single added line
    });
  }

  @override
  Widget build(BuildContext context) {
    late final listeningProvider = Provider.of<DatabaseProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.edit),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          actions: [
            Consumer<DatabaseProvider>(
              builder: (context, provider, _) {
                final unreadCount =
                    provider.notifications.where((n) => !n['read']).length;

                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: IconButton(
                    padding: const EdgeInsets.only(right: 18),
                    icon: const Icon(Icons.notifications),
                    onPressed:
                        () => Navigator.pushNamed(
                          context,
                          notificationsPage.routeName,
                        ),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
            tabs: const [Tab(text: 'For you'), Tab(text: 'Following')],
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: const Text('H O M E'),
        ),

        body: TabBarView(
          children: [
            _buildPostsList(listeningProvider.allPosts),
            _buildPostsList(listeningProvider.followingPosts),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(List<Post> posts) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child:
          _isRefreshing
              ? const Center(child: CircularProgressIndicator())
              : posts.isEmpty
              ? const Center(child: Text('No posts yet'))
              : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostTile(
                    onPostTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostPage(post: post),
                        ),
                      );
                    },
                    post: post,
                    onUserTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: post.uid),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
