import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'all_reports_screen.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'staff_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;

    // Staff get a dashboard instead of the student home screen
    final List<Widget> screens = [
      isStaff
          ? const StaffDashboardScreen()
          : HomeScreen(onSeeAllReports: () => _onTabSelected(2)),
      const AllReportsScreen(showBackButton: false),
      const MyReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Report an issue',
        onPressed: () => Navigator.pushNamed(context, Routes.reportIncident),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 68,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _NavItem(
              icon: isStaff ? Icons.dashboard_outlined : Icons.home_outlined,
              activeIcon: isStaff ? Icons.dashboard : Icons.home,
              label: isStaff ? 'Dashboard' : 'Home',
              selected: _currentIndex == 0,
              onTap: () => _onTabSelected(0),
            ),
            _NavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Browse',
              selected: _currentIndex == 1,
              onTap: () => _onTabSelected(1),
            ),
            const SizedBox(width: 64), // space for the floating button
            _NavItem(
              icon: Icons.description_outlined,
              activeIcon: Icons.description,
              label: 'My Reports',
              selected: _currentIndex == 2,
              onTap: () => _onTabSelected(2),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              selected: _currentIndex == 3,
              onTap: () => _onTabSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textGrey;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
