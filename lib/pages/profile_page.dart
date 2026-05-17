import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SoftCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: user.aliases
                      .map(
                        (alias) => Chip(
                          label: Text(alias),
                          backgroundColor: const Color(0xFFEEF2FF),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}