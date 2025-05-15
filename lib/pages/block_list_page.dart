import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wallgram/services/database/database_provider.dart';

class BlockListPage extends StatefulWidget {
  const BlockListPage({super.key});
  static const String routeName = '/block-list';

  @override
  State<BlockListPage> createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  late DatabaseProvider listeningDatabaseProvider;
  late DatabaseProvider notListeningDatabaseProvider;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      listeningDatabaseProvider = Provider.of<DatabaseProvider>(
        context,
        listen: true,
      );
      notListeningDatabaseProvider = Provider.of<DatabaseProvider>(
        context,
        listen: false,
      );
      loadBlockedUsers();
      _isInitialized = true;
    }
  }

  void loadBlockedUsers() async {
    await listeningDatabaseProvider.loadBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    void _showUnBlockConfirmationBox(String userId) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: "Are you sure you want to unblock this user?",
        confirmBtnText: "Yes",
        showCancelBtn: true,
        confirmBtnColor: Theme.of(context).colorScheme.primary,
        onConfirmBtnTap: () async {
          await notListeningDatabaseProvider.unBlockUser(userId);
          Navigator.pop(context);
        },
      );
    }

    final blockedUsers = listeningDatabaseProvider.blockedUsers;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Blocked Users', style: TextStyle(fontSize: 24)),
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          blockedUsers.isEmpty
              ? const Center(child: Text("No blocked users"))
              : ListView.builder(
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = blockedUsers[index];
                  return Container(
                    margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text('@' + user.username),
                      trailing: GestureDetector(
                        onTap: () => _showUnBlockConfirmationBox(user.uid),
                        child: const Icon(Icons.block, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
