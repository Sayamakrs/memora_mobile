import 'package:flutter/material.dart';

import '../models/entry.dart';
import 'memora_shell.dart';
import 'soft_card.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback onTap;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.isSyncedToGraph
                  ? MemoraColors.primary
                  : const Color(0xFFCBD5E1),
              boxShadow: [
                BoxShadow(
                  color: (entry.isSyncedToGraph
                          ? MemoraColors.primary
                          : const Color(0xFFCBD5E1))
                      .withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: MemoraColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  entry.excerpt.isEmpty ? entry.content : entry.excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MemoraColors.body,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MemoraPill(
                      label: entry.isSyncedToGraph
                          ? 'Synced'
                          : 'Draft',
                      icon: entry.isSyncedToGraph
                          ? Icons.account_tree_rounded
                          : Icons.edit_note_rounded,
                      color: entry.isSyncedToGraph
                          ? MemoraColors.primary
                          : const Color(0xFF64748B),
                    ),
                    ...entry.emotions.take(2).map(
                          (emotion) => MemoraPill(
                            label: '#$emotion',
                            color: MemoraColors.primary,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 30,
          ),
        ],
      ),
    );
  }
}