import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/skill_files_cubit.dart';
import '../cubit/skill_files_state.dart';
import '../model/skill_file_item.dart';
import 'file_content_page.dart';

class SkillFilesView extends StatelessWidget {
  final int skillId;

  const SkillFilesView({super.key, required this.skillId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkillFilesCubit()..loadFiles(skillId),
      child: BlocBuilder<SkillFilesCubit, SkillFilesState>(
        builder: (BuildContext context, SkillFilesState state) {
          switch (state.status) {
            case SkillFilesStatus.initial:
            case SkillFilesStatus.loading:
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6D00), strokeWidth: 2),
              );
            case SkillFilesStatus.loaded:
              return _buildFileList(context, state.files);
            case SkillFilesStatus.error:
              return Center(
                child: Text(state.errorMsg, style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
              );
          }
        },
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<SkillFileItem> files) {
    if (files.isEmpty) {
      return const Center(child: Text('暂无文件', style: TextStyle(fontSize: 14, color: Color(0xFF999999))));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: files.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.only(left: 44),
        child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
      ),
      itemBuilder: (BuildContext context, int index) {
        final SkillFileItem file = files[index];
        return _buildFileItem(context, file);
      },
    );
  }

  Widget _buildFileItem(BuildContext context, SkillFileItem file) {
    // 计算缩进层级
    final int depth = file.filePath.split('/').length - 1;
    final double indent = depth * 16.0;

    return GestureDetector(
      onTap: file.isDir ? null : () => _openFile(context, file),
      child: Container(
        padding: EdgeInsets.only(left: 16 + indent, right: 16, top: 10, bottom: 10),
        child: Row(
          children: [
            Icon(
              file.isDir ? Icons.folder_outlined : _fileIcon(file.mimeType),
              size: 18,
              color: file.isDir ? const Color(0xFFFF6D00) : const Color(0xFF666666),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                file.fileName,
                style: TextStyle(
                  fontSize: 14,
                  color: file.isDir ? const Color(0xFF181818) : const Color(0xFF181818),
                  fontWeight: file.isDir ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (!file.isDir)
              Text(
                _formatSize(file.fileSize),
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
            if (!file.isDir)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right, size: 16, color: Color(0xFFC7C7CC)),
              ),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(String mimeType) {
    if (mimeType.contains('markdown')) return Icons.description_outlined;
    if (mimeType.contains('python')) return Icons.code;
    if (mimeType.contains('dart')) return Icons.code;
    if (mimeType.contains('rust')) return Icons.code;
    if (mimeType.contains('javascript') || mimeType.contains('typescript')) return Icons.code;
    if (mimeType.contains('json') || mimeType.contains('yaml')) return Icons.data_object;
    if (mimeType.contains('shell')) return Icons.terminal;
    return Icons.insert_drive_file_outlined;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  void _openFile(BuildContext context, SkillFileItem file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FileContentPage(skillId: skillId, filePath: file.filePath, fileName: file.fileName),
      ),
    );
  }
}
