import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class UploadZone extends StatefulWidget {
  final String? fileName;
  final VoidCallback onTap;

  const UploadZone({super.key, this.fileName, required this.onTap});

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.fileName != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          color: hasFile
              ? AppTheme.primary
              : _isHovered
                  ? AppTheme.primary
                  : AppTheme.border,
          strokeWidth: 1.5,
          dashPattern: const [8, 4],
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: hasFile
                  ? AppTheme.primary.withValues(alpha: 0.04)
                  : _isHovered
                      ? AppTheme.primary.withValues(alpha: 0.03)
                      : AppTheme.surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFile
                      ? Icons.description_outlined
                      : Icons.upload_file_outlined,
                  size: 40,
                  color: hasFile ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile
                      ? widget.fileName!
                      : 'Click to upload your document',
                  style: hasFile
                      ? AppTextStyles.body.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        )
                      : AppTextStyles.body.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  textAlign: TextAlign.center,
                ),
                if (!hasFile) ...[
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
    );
  }
}
