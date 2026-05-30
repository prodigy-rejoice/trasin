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

  String? _rateLimitMessage;
  String? get rateLimitMessage => _rateLimitMessage;

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
      final rateLimitMessage = _buildRateLimitMessage(e);
      if (rateLimitMessage != null) {
        _log.w('Rate limit hit — staying on processing screen');
        _rateLimitMessage = rateLimitMessage;
        notifyListeners();
        return;
      }
      _repository.lastErrorMessage = _unreadableDocumentMessage;
      await _navigationService.replaceWith(Routes.uploadView);
    } finally {
      setBusy(false);
    }
  }

  Future<void> goToUpload() async {
    await _navigationService.replaceWith(Routes.uploadView);
  }

  String? _buildRateLimitMessage(Object error) {
    final raw = error.toString();
    final lowered = raw.toLowerCase();
    final isRateLimit = lowered.contains('quota') ||
        lowered.contains('rate-limit') ||
        lowered.contains('429');
    if (!isRateLimit) return null;

    final match = RegExp(r'retry in ([\d.]+)s', caseSensitive: false)
        .firstMatch(raw);
    final waitSeconds = match != null
        ? (double.tryParse(match.group(1)!)?.ceil() ?? 0) + 5
        : 60;
    return 'Our translation service is currently busy.\n'
        'Please try again in $waitSeconds seconds.';
  }
}
