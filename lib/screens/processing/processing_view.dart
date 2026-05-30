import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final textStyle =
        AppTextStyles.body.copyWith(color: AppTheme.textSecondary);
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
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reading and translating your document',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                _AnimatedEllipsis(style: textStyle),
              ],
            ),
            const SizedBox(height: 48),
            const TrasinLogo(fontSize: 18),
          ],
        )
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.15, end: 0, duration: 350.ms),
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

class _AnimatedEllipsis extends StatelessWidget {
  final TextStyle style;
  const _AnimatedEllipsis({required this.style});

  @override
  Widget build(BuildContext context) {
    final dot = Text('.', style: style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 400.ms),
        dot
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(delay: 150.ms, duration: 400.ms),
        dot
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }
}
