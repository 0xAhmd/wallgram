import 'package:flutter/material.dart';
import 'package:wallgram/components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
static const String routeName = '/home';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text('H O M E'),
      ),
    );
  }
}
