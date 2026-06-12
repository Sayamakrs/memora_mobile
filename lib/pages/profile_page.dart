// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/app_user.dart';
import '../widgets/memora_shell.dart';
import 'package:memora_mobile/main.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _aliasController;
  late List<String> _aliases;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _aliasController = TextEditingController();
    _aliases = List<String>.from(widget.user.aliases);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _addAlias() {
    final val = _aliasController.text.trim();
    if (val.isNotEmpty && !_aliases.contains(val)) {
      setState(() {
        _aliases.add(val);
        _aliasController.clear();
      });
    }
  }

  void _removeAlias(int index) {
    setState(() {
      _aliases.removeAt(index);
    });
  }

  Future<void> _submitProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final service = AppDependencies.of(context).userService;

      final updatedUser = await service.updateProfile(
        name: _nameController.text.trim(),
        aliases: _aliases,
      );

      if (mounted && updatedUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M';

    return MemoraShell(
      title: 'Edit Profile',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200.withOpacity(0.6),
                  spreadRadius: 2,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Gradient Bar
                  Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo, Colors.purple, Colors.pink],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      // Menggunakan stretch agar semua form memenuhi lebar kotak
                      // dan tidak memicu layout error dari constraint infinity
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Header Identity
                        Row(
                          children: [
                            // Hapus atau beri komentar pada bagian tombol Kamera
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      // URL ini akan tetap bersifat read-only bagi user
                                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.user.name)}&background=EEF2FF&color=4F46E5',
                                      height: 84,
                                      width: 84,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // HAPUS ATAU HIDE BAGIAN INI AGAR TIDAK BISA DIKLIK
                                /*
    const Positioned(
      bottom: -4,
      right: -4,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFF0F172A),
        child: Icon(LucideIcons.camera, size: 14, color: Colors.white),
      ),
    )
    */
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Profile Identity',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    widget.user.email,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child:
                              Divider(color: Color(0xF8F9FAFF), thickness: 2),
                        ),

                        // Input: Display Name
                        _buildLabel(
                            LucideIcons.user, 'Display Name', Colors.indigo),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A)),
                          decoration:
                              _buildInputDecoration('Enter your name...'),
                        ),

                        const SizedBox(height: 32),

                        // Section: Identity Aliases
                        _buildLabel(
                            LucideIcons.tag, 'Identity Aliases', Colors.purple),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x20F1F5F9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.green.shade200,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _aliases.isEmpty
                              ? Text(
                                  'Add aliases to help Memora identify you in different contexts...',
                                  style: TextStyle(
                                    color: Colors.green.shade400,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _aliases.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    String alias = entry.value;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.green.shade200,
                                                width: 3),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.02),
                                              blurRadius: 4,
                                            )
                                          ]),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            alias,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF334155)),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _removeAlias(idx),
                                            child: Icon(LucideIcons.x,
                                                size: 14,
                                                color: Colors.green.shade300),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 12),

                        // Input: Tambah Alias
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _aliasController,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                decoration: _buildInputDecoration(
                                    "Type an alias (e.g. 'Fae')..."),
                                onSubmitted: (_) => _addAlias(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _addAlias,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                              ),
                              child: const Icon(LucideIcons.plus, size: 24),
                            )
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Action Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _submitProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade600,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.indigo.shade300,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              shadowColor:
                                  Colors.indigo.shade800.withOpacity(0.4),
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 3))
                                : const Icon(LucideIcons.save, size: 20),
                            label: Text(
                              _isSaving ? 'SAVING...' : 'SAVE CHANGES',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle:
          TextStyle(color: Colors.green.shade400, fontWeight: FontWeight.bold),
      fillColor: const Color(0x10F1F5F9),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.green.shade100, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }
}
