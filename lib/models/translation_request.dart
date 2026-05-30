class TranslationRequest {
  final List<int> fileBytes;
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
