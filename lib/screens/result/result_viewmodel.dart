import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.logger.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../models/translation_result.dart';
import '../../repositories/translation_repository.dart';

class ResultViewModel extends BaseViewModel {
  final _log = getLogger('ResultViewModel');
  final _repository = locator<TranslationRepository>();
  final _navigationService = locator<NavigationService>();

  TranslationResult? get result => _repository.currentResult;

  void init() {
    _log.i('Loading translation result');
    if (_repository.currentResult == null) {
      _log.w('No result found — redirecting to upload');
      _navigationService.replaceWith(Routes.uploadView);
    }
  }

  Future<void> downloadPdf() async {
    _log.i('Downloading PDF');
    setBusy(true);
    try {
      await _repository.downloadCurrentResultAsPdf();
    } catch (e) {
      _log.e('PDF download failed', error: e);
      setError('We couldn\'t generate the PDF. Please try again.');
    } finally {
      setBusy(false);
    }
  }

  void translateAnother() {
    _log.i('Navigating back to upload');
    _navigationService.clearStackAndShow(Routes.uploadView);
  }
}
