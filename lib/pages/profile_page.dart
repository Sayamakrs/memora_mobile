import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/memora_shell.dart';
import '../widgets/soft_card.dart';

/// Tampilan Profile Identity (read-only).
///
/// CATATAN: Menyimpan perubahan profil (Display Name / Identity Aliases)
/// membutuhkan endpoint update di API mobile (mis. PATCH /api/mobile/me)
/// yang saat ini BELUM ada di backend. Selama backend belum menyediakannya,
/// halaman ini hanya menampilkan data, belum bisa mengedit.
class ProfilePage extends StatelessWidget {
  final AppUser user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M';

    return MemoraShell(
      title: 'Profile Identity',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---- Header ----
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x336366F1),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Identity',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ---- Display Name ----
          const _FieldLabel('Display Name'),
          const SizedBox(height: 8),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Text(
              user.name.isEmpty ? '-' : user.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Identity Aliases ----
          const _FieldLabel('Identity Aliases'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: user.aliases.isEmpty
                ? const Text(
                    'Belum ada alias.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.aliases
                        .map(
                          (alias) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alias,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 18),

          // ---- Catatan kenapa read-only ----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: Color(0xFFB45309)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pengeditan profil belum aktif karena API mobile belum '
                    'menyediakan endpoint update profil. Profil hanya bisa '
                    'diubah lewat versi web untuk saat ini.',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      height: 1.45,
                      fontSize: 13,
                    ),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
      ),
    );
  }
}
