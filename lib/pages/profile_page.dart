import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/my_bio_box.dart';
import 'package:wallgram/components/my_input_dialog_box.dart';
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
    print('User loaded: ${user!.bio}'); // Debugging statement
    setState(() {
      isloading = false;
    });
  }

  void _showEditBioBox() {
    showDialog(
      context: context,
      builder:
          (context) => MyInputDialogBox(
            onPressed: updateBio,
            hintText: 'Enter your bio',
            onPressedText: "Update",
            controller: _bioController,
          ),
    );
  }

  Future<void> updateBio() async {
    await DatabaseProvider().updateBio(widget.uid, _bioController.text);
    await loadUser();
    setState(() {
      isloading = false;
    });
    print('Bio updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          style: TextStyle(fontSize: 25),
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
              isloading ? '' : '@${user!.name}',
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Icon(
                Icons.person,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 25),
          GestureDetector(
            onTap: _showEditBioBox,
            child: MyBioBox(text: isloading ? 'Empty Bio' : user!.bio),
          ),
        ],
      ),
    );
  }
}
