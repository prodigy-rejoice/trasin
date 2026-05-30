import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';
import '../app/app.logger.dart';
import '../models/translation_request.dart';

class GeminiService {
  final _log = getLogger('GeminiService');

  GenerativeModel? _model;

  Future<void> init() async {
      final systemPrompt = await rootBundle.loadString('assets/system_prompt.md');
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(systemPrompt),
    );
  }

  Future<String> translateDocument(TranslationRequest request) async {
    _log.i('Translating: ${request.fileName} → ${request.targetLanguage}');

    final userMessage = 'Source language: ${request.sourceLanguage}\nTarget language: ${request.targetLanguage}';

    final response = await _model!.generateContent([
      Content.multi([
        InlineDataPart(request.mimeType, Uint8List.fromList(request.fileBytes)),
        TextPart(userMessage),
      ]),
    ]);

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('No translation received from Gemini');
    }

    _log.i('Translation complete for: ${request.fileName}');
    return text;
  }
}