import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class UploadZone extends StatefulWidget {
  final String? fileName;
  final VoidCallback onTap;
  final void Function(Uint8List bytes, String fileName) onFileDropped;

  const UploadZone({
    super.key,
    this.fileName,
    required this.onTap,
    required this.onFileDropped,
  });

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {
  bool _isHovered = false;
  bool _isDragging = false;

  Future<void> _handleDrop(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;
    final file = details.files.first;
    final bytes = await file.readAsBytes();
    widget.onFileDropped(bytes, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != null;
    final highlight = hasFile || _isHovered || _isDragging;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: _handleDrop,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: _animatedZone(
            hasFile: hasFile,
            child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            color: highlight ? AppTheme.primary : AppTheme.border,
            strokeWidth: 1.5,
            dashPattern: const [8, 4],
            child: AnimatedContainer(
              duration: 300.ms,
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isDragging
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : hasFile
                        ? AppTheme.primary.withValues(alpha: 0.04)
                        : _isHovered
                            ? AppTheme.primary.withValues(alpha: 0.03)
                            : AppTheme.surface,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDragging
                        ? Icons.file_download_outlined
                        : hasFile
                            ? Icons.description_outlined
                            : Icons.upload_file_outlined,
                    size: 40,
                    color: highlight ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isDragging
                        ? 'Drop to upload'
                        : hasFile
                            ? widget.fileName!
                            : 'Click to upload your document',
                    style: hasFile || _isDragging
                        ? AppTextStyles.body.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          )
                        : AppTextStyles.body.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    textAlign: TextAlign.center,
                  ),
                  if (!hasFile && !_isDragging) ...[
                    const SizedBox(height: 4),
                    Text(
                      'or drag and drop',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _animatedZone({required bool hasFile, required Widget child}) {
    if (hasFile) {
      return child.animate().scaleXY(
            begin: 1.0,
            end: 1.02,
            duration: 300.ms,
            curve: Curves.easeOut,
          );
    }
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.005, duration: 400.ms);
  }
}
