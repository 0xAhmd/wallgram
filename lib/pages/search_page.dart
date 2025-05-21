import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallgram/components/custom_user_list_tile.dart';
import 'package:wallgram/services/database/app_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const String routeName = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<AppProvider>(context, listen: false);
    final listeningDatabaseProvider = Provider.of<AppProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users',
            hintStyle: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              databaseProvider.searchUsers(value.trim());
            } else {
              databaseProvider.searchUsers('');
            }
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          _searchController.text.isEmpty
              ? const Center(
                child: Text(
                  'SEARCH FOR USERS...',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : listeningDatabaseProvider.searchResult.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                itemCount: listeningDatabaseProvider.searchResult.length,
                itemBuilder: (context, index) {
                  final user = listeningDatabaseProvider.searchResult[index];
                  return CustomUserListTile(user: user);
                },
              ),
    );
  }
}
