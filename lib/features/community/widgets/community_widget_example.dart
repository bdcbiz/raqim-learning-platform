import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'community_widget.dart';
import '../providers/community_provider.dart';

/// Example usage of the CommunityWidget
/// This demonstrates how to use the refactored CommunityWidget inside your own screens
class MyProjectMainScreen extends StatelessWidget {
  const MyProjectMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My AI Project"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Add your settings navigation here
            },
          ),
        ],
      ),
      // The CommunityWidget is used directly in the body
      body: ChangeNotifierProvider(
        create: (_) => CommunityProvider()..loadPosts(),
        child: const CommunityWidget(),
      ),
    );
  }
}

/// Another example showing the CommunityWidget in a tab view
class TabViewExample extends StatelessWidget {
  const TabViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
              Tab(text: 'Community', icon: Icon(Icons.people)),
              Tab(text: 'Profile', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Dashboard tab
            const Center(child: Text('Dashboard Content')),
            // Community tab - using our refactored widget
            ChangeNotifierProvider(
              create: (_) => CommunityProvider()..loadPosts(),
              child: const CommunityWidget(),
            ),
            // Profile tab
            const Center(child: Text('Profile Content')),
          ],
        ),
      ),
    );
  }
}

/// Example showing the CommunityWidget in a custom layout
class CustomLayoutExample extends StatelessWidget {
  const CustomLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Layout'),
      ),
      body: Row(
        children: [
          // Left sidebar
          Container(
            width: 250,
            color: Colors.grey[100],
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Community'),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          // Main content area with CommunityWidget
          Expanded(
            child: ChangeNotifierProvider(
              create: (_) => CommunityProvider()..loadPosts(),
              child: const CommunityWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example showing the CommunityWidget in a dialog
class DialogExample extends StatelessWidget {
  const DialogExample({super.key});

  void _showCommunityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Community Feed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              // Using CommunityWidget inside a dialog
              Expanded(
                child: ChangeNotifierProvider(
                  create: (_) => CommunityProvider()..loadPosts(),
                  child: const CommunityWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialog Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showCommunityDialog(context),
          child: const Text('Open Community Dialog'),
        ),
      ),
    );
  }
}