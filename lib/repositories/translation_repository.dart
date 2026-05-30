import '../app/app.logger.dart';
import '../app/app.locator.dart';
import '../models/translation_request.dart';
import '../models/translation_result.dart';
import '../services/gemini_service.dart';
import '../services/pdf_service.dart';

class TranslationRepository {
  final _log = getLogger('TranslationRepository');
  final _geminiService = locator<GeminiService>();
  final _pdfService = locator<PdfService>();

  TranslationRequest? _pendingRequest;
  TranslationResult? _currentResult;

  TranslationRequest? get pendingRequest => _pendingRequest;
  TranslationResult? get currentResult => _currentResult;

  void setPendingRequest(TranslationRequest request) {
    _log.i('Pending request set: ${request.fileName}');
    _pendingRequest = request;
    _currentResult = null;
  }

  Future<TranslationResult> translate() async {
    final request = _pendingRequest;
    if (request == null) throw StateError('No pending translation request');

    _log.i('Starting translation: ${request.fileName}');

    final translatedText = await _geminiService.translateDocument(request);

    _currentResult = TranslationResult(
      translatedText: translatedText,
      sourceLanguage: request.sourceLanguage,
      targetLanguage: request.targetLanguage,
      fileName: request.fileName,
    );

    _log.i('Translation stored for: ${request.fileName}');
    return _currentResult!;
  }

  Future<void> downloadCurrentResultAsPdf() async {
    final result = _currentResult;
    if (result == null) throw StateError('No translation result available');
    _log.i('Requesting PDF download for: ${result.fileName}');
    await _pdfService.generateAndDownload(result);
  }
}
