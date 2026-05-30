import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.logger.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../repositories/translation_repository.dart';

class ProcessingViewModel extends BaseViewModel {
  final _log = getLogger('ProcessingViewModel');
  final _repository = locator<TranslationRepository>();
  final _navigationService = locator<NavigationService>();

  static const _unreadableDocumentMessage =
      "We couldn't read this document. Please try a clearer image or a text-based PDF.";

  Future<void> startTranslation() async {
    _log.i('Processing translation request');
    setBusy(true);

    try {
      final result = await _repository.translate();
      if (result.translatedText.trim().length < 10) {
        _log.w('Translation too short — treating as unreadable');
        _repository.lastErrorMessage = _unreadableDocumentMessage;
        await _navigationService.replaceWith(Routes.uploadView);
        return;
      }
      _log.i('Translation complete — navigating to result');
      await _navigationService.replaceWith(Routes.resultView);
    } catch (e) {
      _log.e('Translation failed', error: e);
      _repository.lastErrorMessage = _unreadableDocumentMessage;
      await _navigationService.replaceWith(Routes.uploadView);
    } finally {
      setBusy(false);
    }
  }
}
