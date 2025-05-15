import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/custom_bottom_sheet.dart';
import 'package:wallgram/components/my_bio_box.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/database_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.uid});
  final String uid;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _bioController = TextEditingController();

  UserProfile? user;
  late String currentUserId;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService().currentUser.uid;
    loadUser();
  }

  Future<void> loadUser() async {
    final databaseProvider = Provider.of<DatabaseProvider>(
      context,
      listen: false,
    );

    user = await databaseProvider.userProfile(widget.uid);
    setState(() {
      isloading = false;
    });
  }

  void _showEditBioBox() {
    showModalBottomSheet(
      
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        _bioController.text = user?.bio ?? '';
        return CustomBottomSheet(
          title: "Edit Bio",
          buttonLabel: "UPDATE",
          hintText: "Update your bio",
          controller: _bioController,
          onPost: (newBio) async {
            if (newBio.isNotEmpty) {
              await DatabaseProvider().updateBio(widget.uid, newBio);
              await loadUser(); // Reload user data
              setState(() {
                isloading = false;
              });
            } else {
            }
          },
        );
      },
    );
  }

  void updateBio() async {
    if (_bioController.text.isNotEmpty) {
      await DatabaseProvider().updateBio(widget.uid, _bioController.text);
      await loadUser(); // Reload the user data to reflect the changes
      setState(() {
        isloading = false;
      });
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPosts = Provider.of<DatabaseProvider>(
      context,
    ).userPosts(widget.uid);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          style: const TextStyle(fontSize: 25),
          isloading ? '' : user!.name,
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              isloading ? '' : '@${user!.username}',
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Icon(
                Icons.person,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              // Image.asset('assets/profile.png', width: 110),
            ),
          ),

          const SizedBox(height: 25),
          currentUserId == widget.uid
              ? GestureDetector(
                onTap: _showEditBioBox,
                child: MyBioBox(
                  text:
                      isloading
                          ? 'Loading...'
                          : user!.bio.isEmpty
                          ? 'No Bio Set'
                          : user!.bio,
                ),
              )
              : MyBioBox(
                text:
                    isloading
                        ? 'Loading...'
                        : user!.bio.isEmpty
                        ? 'No Bio Set'
                        : user!.bio,
              ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 25),
            child: Text(
              'Posts',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          userPosts.isEmpty
              ? const Center(child: Text('No posts yet'))
              : ListView.builder(
                itemCount: userPosts.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return PostTile(
                    post: userPosts[index],
                    onUserTap: () {},
                    onPostTap: () {},
                  );
                },
              ),
        ],
      ),
    );
  }
}
