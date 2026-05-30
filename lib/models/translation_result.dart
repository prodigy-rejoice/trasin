class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String fileName;

  const TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.fileName,
  });
}
