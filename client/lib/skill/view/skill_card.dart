import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/skill_summary.dart';

class SkillCard extends StatelessWidget {
  final SkillSummary skill;
  final VoidCallback? onTap;

  const SkillCard({super.key, required this.skill, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (skill.iconUrl.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.extension, color: Colors.grey),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: skill.iconUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[200],
          child: const Icon(Icons.extension, color: Colors.grey),
        ),
        errorWidget: (_, _, _) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                skill.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'v${skill.version}',
                style: TextStyle(fontSize: 11, color: Colors.blue[700]),
              ),
            ),
          ],
        ),
        if (skill.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            skill.description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            if (skill.author.isNotEmpty) ...[
              Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 2),
              Text(
                skill.author,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: skill.tagList.take(3).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
