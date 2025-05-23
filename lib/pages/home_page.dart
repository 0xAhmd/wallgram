import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/custom_bottom_sheet.dart';
import 'package:wallgram/components/drawer.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/components/shimmers/shimmer_post_tile.dart';
import 'package:wallgram/helper/global_banner.dart';
import 'package:wallgram/helper/updater.dart';
import 'package:wallgram/models/post.dart';
import 'package:wallgram/pages/notification_page.dart';
import 'package:wallgram/pages/post_page.dart';
import 'package:wallgram/pages/profile_page.dart';
import 'package:wallgram/services/provider/app_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppProvider dataprovider;
  bool _isInitialized = false;
  bool _isRefreshing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      dataprovider = Provider.of<AppProvider>(context);
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
    final rootContext = context;

    showModalBottomSheet(
      context: rootContext,
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
            try {
              await dataprovider.postMessage(message);
              controller.clear();
              Navigator.of(context).pop();
            } catch (e) {
              final errorText = e.toString();

              if (errorText.contains('Please wait')) {
                final cooldownMessage = errorText.replaceFirst(
                  'Exception: ',
                  '',
                );
                ScaffoldMessenger.of(
                  rootContext,
                ).showSnackBar(SnackBar(content: Text(cooldownMessage)));
              }

              // All other errors: do nothing
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdater.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    late final listeningProvider = Provider.of<AppProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.edit),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: GlobalAppBarWrapper(
          appBar: AppBar(
            actions: [
              Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final unreadCount =
                      provider.notifications.where((n) => !n['read']).length;

                  return GestureDetector(
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          notificationsPage.routeName,
                        ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(FontAwesomeIcons.bell, size: 24),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 10,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
    child: _isRefreshing
        ? ListView.builder(
            itemCount: 6, // Display 6 shimmer tiles
            itemBuilder: (context, index) => const PostTileShimmer(),
          )
        : posts.isEmpty
            ? const Center(child: Text('No posts yet'))
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostTile(
                    key: ValueKey(post.id),
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
