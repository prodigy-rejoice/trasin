class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String? detectedSourceLanguage;
  final String targetLanguage;
  final String fileName;

  const TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    this.detectedSourceLanguage,
    required this.targetLanguage,
    required this.fileName,
  });
}
