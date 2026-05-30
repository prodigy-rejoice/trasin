import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../core/theme.dart';
import '../../viewmodels/result_viewmodel.dart';
import '../../widgets/trasin_logo.dart';

class ResultView extends StackedView<ResultViewModel> {
  const ResultView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ResultViewModel viewModel,
    Widget? child,
  ) {
    final result = viewModel.result;

    if (result == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: TrasinLogo()),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.translate_rounded,
                              color: AppTheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Translated from ${result.sourceLanguage} → ${result.targetLanguage}',
                              style: AppTextStyles.label
                                  .copyWith(color: AppTheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.fileName,
                          style: AppTextStyles.caption,
                        ),
                        const Divider(
                          height: 28,
                          color: AppTheme.border,
                        ),
                        SelectableText(
                          result.translatedText,
                          style: AppTextStyles.body.copyWith(height: 1.75),
                        ),
                      ],
                    ),
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
                  ElevatedButton.icon(
                    onPressed:
                        viewModel.isBusy ? null : viewModel.downloadPdf,
                    style: AppButtonStyles.primary,
                    icon: viewModel.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Download PDF'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: viewModel.translateAnother,
                      child: Text(
                        'Translate another document',
                        style: AppTextStyles.body
                            .copyWith(color: AppTheme.primary),
                      ),
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
  ResultViewModel viewModelBuilder(BuildContext context) => ResultViewModel();

  @override
  void onViewModelReady(ResultViewModel viewModel) => viewModel.init();
}