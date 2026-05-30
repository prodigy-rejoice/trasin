import 'dart:typed_data';

class TranslationRequest {
  final Uint8List fileBytes;
  final String mimeType;
  final String sourceLanguage;
  final String targetLanguage;
  final String fileName;

  const TranslationRequest({
    required this.fileBytes,
    required this.mimeType,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.fileName,
  });
}
