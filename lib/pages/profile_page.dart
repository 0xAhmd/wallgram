import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/custom_bottom_sheet.dart';
import 'package:wallgram/components/custom_follow_button.dart';
import 'package:wallgram/components/my_bio_box.dart';
import 'package:wallgram/components/post_tile.dart';
import 'package:wallgram/components/profile_stats.dart';
import 'package:wallgram/components/shimmers/profile_page_shimmer.dart';
import 'package:wallgram/helper/global_banner.dart';
import 'package:wallgram/helper/image_picker.dart';
import 'package:wallgram/helper/navigator.dart';
import 'package:wallgram/models/user_profile_model.dart';
import 'package:wallgram/pages/follow_list_page.dart';
import 'package:wallgram/services/auth/auth_service.dart';
import 'package:wallgram/services/database/supabase_storage_service.dart';
import 'package:wallgram/services/provider/app_provider.dart';

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
  bool isFollowing = false;
  bool isTogglingFollow = false;
  String? _profileImageUrl; // <-- Track image URL

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService().currentUser.uid;
    loadUser();
  }

  Future<void> _refreshData() async {
    setState(() => isloading = true);
    try {
      await loadUser(); // Reuse your existing loadUser function
    } finally {
      if (mounted) setState(() => isloading = false);
    }
  }

  Future<void> loadUser() async {
    try {
      final databaseProvider = Provider.of<AppProvider>(context, listen: false);
      user = await databaseProvider.userProfile(widget.uid);
      await databaseProvider.loadUserFollowers(widget.uid);
      await databaseProvider.loadUserFollowing(widget.uid);
      isFollowing = await databaseProvider.isFollowing(widget.uid);

      // If user is null (not found in database), create a basic profile
      if (user == null && widget.uid == currentUserId) {
        final currentUser = AuthService().currentUser;
        await databaseProvider.createUserProfile(
          uid: currentUser.uid,
          name: currentUser.displayName ?? 'New User',
          email: currentUser.email ?? '',
          username:
              currentUser.email?.split('@').first ??
              'user_${currentUser.uid.substring(0, 6)}',
        );
        user = await databaseProvider.userProfile(widget.uid);
      }
      _profileImageUrl = user?.profileImage;
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
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
              await AppProvider().updateBio(widget.uid, newBio);
              await loadUser(); // Reload user data
              setState(() {
                isloading = false;
              });
            } else {}
          },
        );
      },
    );
  }

  void updateBio() async {
    if (_bioController.text.isNotEmpty) {
      await AppProvider().updateBio(widget.uid, _bioController.text);
      await loadUser(); // Reload the user data to reflect the changes
      setState(() {
        isloading = false;
      });
    } else {}
  }

  Future<void> _toggleFollow() async {
    if (!mounted) return; // Early exit if widget is disposed

    final databaseProvider = Provider.of<AppProvider>(context, listen: false);

    // Update UI optimistically
    setState(() {
      isTogglingFollow = true;
      isFollowing = !isFollowing;
    });

    try {
      if (isFollowing) {
        await databaseProvider.followUser(widget.uid);
      } else {
        await databaseProvider.unfollowUser(widget.uid);
      }

      // Refresh data if still mounted
      if (mounted) {
        await _refreshData();
      }
    } catch (e) {
      // Only rollback if still mounted
      if (mounted) {
        setState(() {
          isFollowing = !isFollowing;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status')),
        );
      }
    } finally {
      // Only update loading state if still mounted
      if (mounted) {
        setState(() {
          isTogglingFollow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPosts = Provider.of<AppProvider>(context).userPosts(widget.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: GlobalAppBarWrapper(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => goHomePage(context),
            icon: const Icon(Icons.arrow_back),
          ),
          centerTitle: true,
          title: Text(
            style: const TextStyle(fontSize: 25),
            isloading ? 'Loading...' : user?.name ?? 'Profile',
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body:
          isloading
              ? const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ProfilePageShimmer(),
                ),
              )
              : RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                onRefresh: _refreshData,
                child: ListView(
                  children: [
                    Center(
                      child: Text(
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        isloading
                            ? 'Loading...'
                            : '@${user?.username ?? 'user'}',
                      ),
                    ),
                    const SizedBox(height: 25),

                    GestureDetector(
                      onLongPress: () {
                        if (_profileImageUrl != null) {
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.5),
                            builder: (context) {
                              return Stack(
                                children: [
                                  // Background blur effect
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Hero(
                                        tag: 'profile-image',
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: _profileImageUrl!,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.8,
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.8,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      onTap: () async {
                        final currentUserId =
                            FirebaseAuth.instance.currentUser!.uid;

                        if (widget.uid != currentUserId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Niqqa you can’t change someone else’s profile photo.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                          return;
                        }

                        final pickedFile = await ImageHelper.pickImage();
                        if (pickedFile != null) {
                          final imageUrl =
                              await SupabaseStorageService.uploadImageAndSaveToFirestore(
                                file: pickedFile,
                                uid: widget.uid,
                              );

                          if (imageUrl != null) {
                            setState(() {
                              _profileImageUrl = imageUrl;
                            });
                          }
                        }
                      },

                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child:
                              _profileImageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
                                      imageUrl: _profileImageUrl!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) =>
                                              const CircularProgressIndicator(),
                                      errorWidget:
                                          (context, url, error) => Icon(
                                            Icons.person,
                                            size: 100,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                    ),
                                  )
                                  : Icon(
                                    Icons.person,
                                    size: 100,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // stats
                    Consumer<AppProvider>(
                      builder: (context, databaseProvider, child) {
                        return ProfileStats(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        FollowListPage(uid: widget.uid),
                              ),
                            );
                          },
                          postCount: userPosts.length,
                          followerCount: databaseProvider.getFollowerCount(
                            widget.uid,
                          ),
                          followingCount: databaseProvider.getFollowingCount(
                            widget.uid,
                          ),
                        );
                      },
                    ),
                    // Follow button
                    const SizedBox(height: 8),
                    if (user != null && user!.uid != currentUserId)
                      CustomFollowButton(
                        isFollowing: isFollowing,
                        isLoading: isTogglingFollow,
                        onPressed: isTogglingFollow ? null : _toggleFollow,
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
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
              ),
    );
  }
}
