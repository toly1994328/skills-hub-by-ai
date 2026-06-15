import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/skill_publish_cubit.dart';
import '../cubit/skill_publish_state.dart';

class SkillPublishPage extends StatelessWidget {
  const SkillPublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkillPublishCubit(),
      child: const _PublishView(),
    );
  }
}

class _PublishView extends StatefulWidget {
  const _PublishView();

  @override
  State<_PublishView> createState() => _PublishViewState();
}

class _PublishViewState extends State<_PublishView> {
  String _fileName = '';
  int _fileSize = 0;
  List<int> _zipBytes = [];

  Future<void> _pickZip() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null && result.files.single.path != null) {
      final File file = File(result.files.single.path!);
      final List<int> bytes = await file.readAsBytes();
      setState(() {
        _fileName = result.files.single.name;
        _fileSize = bytes.length;
        _zipBytes = bytes;
      });
    }
  }

  void _upload() {
    context.read<SkillPublishCubit>().upload(
      _zipBytes.isNotEmpty ? _zipBytes : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SkillPublishCubit, SkillPublishState>(
      listener: (BuildContext context, SkillPublishState state) {
        if (state.status == SkillPublishStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == SkillPublishStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMsg), backgroundColor: const Color(0xFFFA5151)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDEDED),
        appBar: AppBar(
          title: const Text('上传技能', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF181818))),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, size: 22, color: Color(0xFF181818)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            const Spacer(),
            _buildUploadArea(),
            const SizedBox(height: 24),
            _buildUploadButton(),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GestureDetector(
        onTap: _pickZip,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _fileName.isEmpty ? const Color(0xFFE5E5E5) : const Color(0xFFFF6D00),
              width: _fileName.isEmpty ? 1.5 : 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _fileName.isEmpty ? Icons.cloud_upload_outlined : Icons.folder_zip_outlined,
                size: 48,
                color: _fileName.isEmpty ? const Color(0xFFBBBBBB) : const Color(0xFFFF6D00),
              ),
              const SizedBox(height: 16),
              Text(
                _fileName.isEmpty ? '选择技能压缩包（.zip）' : _fileName,
                style: TextStyle(
                  fontSize: 15,
                  color: _fileName.isEmpty ? const Color(0xFF999999) : const Color(0xFF181818),
                  fontWeight: _fileName.isEmpty ? FontWeight.normal : FontWeight.w600,
                ),
              ),
              if (_fileSize > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${(_fileSize / 1024).toStringAsFixed(1)} KB  ·  点击重新选择',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
              if (_fileName.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  '压缩包需包含 SKILL.md 文件',
                  style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return BlocBuilder<SkillPublishCubit, SkillPublishState>(
      builder: (BuildContext context, SkillPublishState state) {
        final bool isLoading = state.status == SkillPublishStatus.submitting;
        final bool hasFile = _zipBytes.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GestureDetector(
            onTap: (isLoading || !hasFile) ? null : _upload,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: hasFile
                    ? (isLoading ? const Color(0xFFFF6D00).withValues(alpha: 0.5) : const Color(0xFFFF6D00))
                    : const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('上传', style: TextStyle(fontSize: 16, color: hasFile ? Colors.white : const Color(0xFF999999), fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        );
      },
    );
  }
}
