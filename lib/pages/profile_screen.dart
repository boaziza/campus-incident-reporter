import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/user_avatar.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to report issues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    final myCount = context.watch<IncidentProvider>().myIncidents.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: UserAvatar(initials: user?.initials ?? '?', radius: 44)),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user?.name ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 24),
          _Tile(
            icon: Icons.badge_outlined,
            title: 'Role',
            value: (user?.isStaff ?? false) ? 'Campus Staff' : 'Student',
          ),
          _Tile(
            icon: Icons.description_outlined,
            title: 'Reports submitted',
            value: '$myCount',
          ),
          if (user?.createdAt != null)
            _Tile(
              icon: Icons.event_outlined,
              title: 'Member since',
              value: DateFormatter.full(user!.createdAt!).split(' at ').first,
            ),
          const _Tile(
            icon: Icons.verified_user_outlined,
            title: 'Email verified',
            value: 'Yes',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please only report real campus issues. False or abusive reports can be rejected by staff.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
