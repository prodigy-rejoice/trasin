import 'package:file_picker/file_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.logger.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../core/constants.dart';
import '../../models/translation_request.dart';
import '../../repositories/translation_repository.dart';

class UploadViewModel extends BaseViewModel {
  final _log = getLogger('UploadViewModel');
  final _repository = locator<TranslationRepository>();
  final _navigationService = locator<NavigationService>();

  List<int>? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedMimeType;
  String _sourceLanguage = 'Auto-detect';
  String _targetLanguage = 'English';

  String? get selectedFileName => _selectedFileName;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  bool get hasFile => _selectedFileBytes != null;

  void setSourceLanguage(String language) {
    _sourceLanguage = language;
    notifyListeners();
  }

  void setTargetLanguage(String language) {
    _targetLanguage = language;
    notifyListeners();
  }

  Future<void> pickFile() async {
    _log.i('Opening file picker');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: kAllowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    if (file.bytes == null) {
      setError('We couldn\'t read this file. Please try again.');
      return;
    }

    if (file.size > kMaxFileSizeBytes) {
      setError('This file is too large. Please use a file under 10MB.');
      return;
    }

    clearErrors();
    _selectedFileBytes = file.bytes!.toList();
    _selectedFileName = file.name;
    _selectedMimeType = _mimeTypeFromExtension(file.extension ?? '');
    _log.i('File selected: ${file.name} (${file.size} bytes)');
    notifyListeners();
  }

  Future<void> startTranslation() async {
    if (_selectedFileBytes == null) {
      setError('Please select a document first.');
      return;
    }

    if (_targetLanguage == 'Auto-detect') {
      setError('Please select a target language.');
      return;
    }

    _log.i('Starting translation: $_selectedFileName');

    final request = TranslationRequest(
      fileBytes: _selectedFileBytes!,
      mimeType: _selectedMimeType!,
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
      fileName: _selectedFileName!,
    );

    _repository.setPendingRequest(request);
    await _navigationService.navigateTo(Routes.processingView);
  }

  String _mimeTypeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
