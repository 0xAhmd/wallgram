import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/custom_user_list_tile.dart';
import 'package:wallgram/helper/global_banner.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/database/app_provider.dart';

class FollowListPage extends StatefulWidget {
  const FollowListPage({super.key, required this.uid});
  final String uid;
  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late final listeningProvider = Provider.of<AppProvider>(context);
  late final databaseProvider = Provider.of<AppProvider>(
    context,
    listen: false,
  );
  @override
  void initState() {
    super.initState();
    loadFollowerList();
    loadFollowingList();
  }

  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowingProfile(widget.uid);
  }

  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollowersProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final followers = listeningProvider.getListOfFollowerProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: GlobalAppBarWrapper(
          appBar: AppBar(
            foregroundColor: Theme.of(context).colorScheme.primary,
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: 'Followers'), Tab(text: 'Following')],
              indicatorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(followers, 'No followers..'),
            _buildUserList(following, 'No following..'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            final user = userList[index];
            return CustomUserListTile(user: user);
          },
        );
  }
}
