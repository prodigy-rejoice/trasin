import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../core/theme.dart';
import 'processing_viewmodel.dart';
import '../../widgets/trasin_logo.dart';

class ProcessingView extends StackedView<ProcessingViewModel> {
  const ProcessingView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ProcessingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Reading and translating your document…',
              style: AppTextStyles.body.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const TrasinLogo(fontSize: 18),
          ],
        ),
      ),
    );
  }

  @override
  ProcessingViewModel viewModelBuilder(BuildContext context) =>
      ProcessingViewModel();

  @override
  void onViewModelReady(ProcessingViewModel viewModel) =>
      viewModel.startTranslation();
}
