import 'package:flutter/material.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text(
          '我的',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFF5F5F5),
                  child: Icon(Icons.person, size: 32, color: Color(0xFF999999)),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '未登录',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '登录后可管理已发布的技能',
                      style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildMenuItem(Icons.upload_outlined, '我发布的'),
                _divider(),
                _buildMenuItem(Icons.star_outline, '我收藏的'),
                _divider(),
                _buildMenuItem(Icons.settings_outlined, '设置'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF181818)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF181818))),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 48),
      child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE5E5E5)),
    );
  }
}
