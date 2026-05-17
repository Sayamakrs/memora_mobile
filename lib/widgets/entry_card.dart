import 'package:flutter/material.dart';

import '../models/entry.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF6366F1)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                entry.isSyncedToGraph
                    ? Icons.account_tree_rounded
                    : Icons.cloud_off_rounded,
                size: 18,
                color: entry.isSyncedToGraph
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.excerpt.isEmpty ? entry.content : entry.excerpt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          if (entry.emotions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: entry.emotions
                  .map(
                    (emotion) => Chip(
                      label: Text('#$emotion'),
                      backgroundColor: const Color(0xFFEEF2FF),
                      labelStyle: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}