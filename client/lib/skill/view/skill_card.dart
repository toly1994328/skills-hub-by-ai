import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/skill_summary.dart';

class SkillCard extends StatefulWidget {
  final SkillSummary skill;
  final VoidCallback? onTap;

  const SkillCard({super.key, required this.skill, this.onTap});

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _pressed ? const Color(0xFFF5F5F5) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.skill.iconUrl.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.extension, color: Color(0xFF999999), size: 20),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: widget.skill.iconUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          width: 40,
          height: 40,
          color: const Color(0xFFF5F5F5),
        ),
        errorWidget: (_, _, _) => Container(
          width: 40,
          height: 40,
          color: const Color(0xFFF5F5F5),
          child: const Icon(Icons.extension, color: Color(0xFF999999), size: 20),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第一行：名称 + 右侧更新时间
        Row(
          children: [
            Expanded(
              child: Text(
                widget.skill.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181818),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(widget.skill.updatedAt),
              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
            ),
          ],
        ),
        // 第二行：描述（支持两行）
        if (widget.skill.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.skill.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // 第三行：版本号标签 + tags 横向排列
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'v${widget.skill.version}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFF6D00)),
                ),
              ),
              ...widget.skill.tagList.map((tag) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';
    // "2026-06-12 10:00:00" -> "06-12 10:00"
    if (time.length >= 16) {
      return time.substring(5, 16);
    }
    return time;
  }
}
