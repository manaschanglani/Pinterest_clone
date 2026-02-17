import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_empty_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(tabController: _tabController),
            const SizedBox(height: 16),
            const ProfileSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ProfileEmptyState(
                    icon: Icons.push_pin_outlined,
                    title: 'Save what inspires you',
                    subtitle:
                    "Saving Pins is Pinterest's superpower. Browse Pins, save what you love, find them here to get inspired all over again.",
                    buttonText: 'Explore Pins',
                  ),
                  ProfileEmptyState(
                    icon: Icons.dashboard_outlined,
                    title: 'Organize your ideas',
                    subtitle:
                    'Pins and sparks of inspiration. Boards are where they live. Create boards to organize your Pins your way.',
                    buttonText: 'Create a board',
                  ),
                  ProfileEmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Make your first collage',
                    subtitle:
                    'Snip-and-paste the best parts of your favorite Pins to create something completely new.',
                    buttonText: 'Create collage',
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
