import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../viewmodels/upload_viewmodel.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/trasin_logo.dart';
import '../../widgets/upload_zone.dart';

class UploadView extends StackedView<UploadViewModel> {
  const UploadView({super.key});

  @override
  Widget builder(
    BuildContext context,
    UploadViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: TrasinLogo()),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Translate any document, instantly.',
                      style: AppTextStyles.tagline,
                    ),
                  ),
                  const SizedBox(height: 40),
                  UploadZone(
                    fileName: viewModel.selectedFileName,
                    onTap: viewModel.pickFile,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: LanguageSelector(
                          label: 'From',
                          value: viewModel.sourceLanguage,
                          options: kSupportedLanguages,
                          onChanged: (v) =>
                              viewModel.setSourceLanguage(v ?? 'Auto-detect'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LanguageSelector(
                          label: 'To',
                          value: viewModel.targetLanguage,
                          options: kSupportedLanguages
                              .where((l) => l != 'Auto-detect')
                              .toList(),
                          onChanged: (v) =>
                              viewModel.setTargetLanguage(v ?? 'English'),
                        ),
                      ),
                    ],
                  ),
                  if (viewModel.hasError) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: AppTheme.error),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            viewModel.modelError.toString(),
                            style: AppTextStyles.caption
                                .copyWith(color: AppTheme.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: viewModel.isBusy || !viewModel.hasFile
                        ? null
                        : viewModel.startTranslation,
                    style: AppButtonStyles.primary,
                    child: viewModel.isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Translate'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Supports PDF, JPG, PNG · Max 10MB',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  UploadViewModel viewModelBuilder(BuildContext context) => UploadViewModel();
}
