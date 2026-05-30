import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.logger.dart';
import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../repositories/translation_repository.dart';

class ProcessingViewModel extends BaseViewModel {
  final _log = getLogger('ProcessingViewModel');
  final _repository = locator<TranslationRepository>();
  final _navigationService = locator<NavigationService>();

  Future<void> startTranslation() async {
    _log.i('Processing translation request');
    setBusy(true);

    try {
      await _repository.translate();
      _log.i('Translation complete — navigating to result');
      await _navigationService.replaceWith(Routes.resultView);
    } catch (e) {
      _log.e('Translation failed', error: e);
      await Future.delayed(const Duration(seconds: 2));
      await _navigationService.replaceWith(Routes.uploadView);
    } finally {
      setBusy(false);
    }
  }
}
