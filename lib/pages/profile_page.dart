import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_user.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  Future<void> logout(BuildContext context) async {
    await AppDependencies.of(context).authService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MemoraShell(
      title: 'Profile',
      subtitle: 'Your personal memory space',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
        children: [
          MemoraContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MemoraPill(
                  label: 'PROFILE IDENTITY',
                  icon: Icons.person_rounded,
                  color: MemoraColors.primary,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your identity\ninside Memora.',
                  style: TextStyle(
                    fontSize: 38,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.7,
                    color: MemoraColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This profile is currently running in mock mode. Later, the data will be loaded from Laravel API.',
                  style: TextStyle(
                    color: MemoraColors.body,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 26),
                SoftCard(
                  radius: 36,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MemoraColors.primary,
                              MemoraColors.primary2,
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                        child: Row(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: MemoraColors.softPurple,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFFE0E7FF),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'M',
                                  style: const TextStyle(
                                    color: MemoraColors.primary,
                                    fontSize: 31,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: MemoraColors.text,
                                      fontSize: 24,
                                      height: 1.1,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.7,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: MemoraColors.muted,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SoftCard(
                  radius: 34,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.person_rounded,
                        label: 'Display Name',
                        value: user.name,
                      ),
                      const Divider(height: 28, color: Color(0xFFE5E7EB)),
                      _ProfileInfoRow(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(height: 28, color: Color(0xFFE5E7EB)),
                      _ProfileInfoRow(
                        icon: Icons.tag_rounded,
                        label: 'Aliases',
                        value:
                            user.aliases.isEmpty ? '-' : user.aliases.join(', '),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SoftCard(
                  radius: 34,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Mobile Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: MemoraColors.text,
                        ),
                      ),
                      SizedBox(height: 14),
                      _StatusPill(
                        icon: Icons.check_circle_rounded,
                        label: 'UI native Flutter ready',
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(height: 10),
                      _StatusPill(
                        icon: Icons.data_object_rounded,
                        label: 'Mock data active',
                        color: MemoraColors.primary,
                      ),
                      SizedBox(height: 10),
                      _StatusPill(
                        icon: Icons.cloud_sync_rounded,
                        label: 'Laravel API pending',
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: MemoraColors.softPurple,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: MemoraColors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: MemoraColors.muted,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: MemoraColors.text,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}