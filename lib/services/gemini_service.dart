import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';
import '../app/app.logger.dart';
import '../models/translation_request.dart';

typedef GeminiTranslation = ({
  String translatedText,
  String detectedSourceLanguage,
});

class GeminiService {
  final _log = getLogger('GeminiService');

  GenerativeModel? _model;

  Future<void> init() async {
    final systemPrompt =
        await rootBundle.loadString('assets/system_prompt.md');
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'detectedSourceLanguage': Schema.string(
              description:
                  'The language detected in the uploaded document (e.g. "French", "Spanish", "Yoruba").',
            ),
            'translatedText': Schema.string(
              description: 'The translated document content only.',
            ),
          },
        ),
      ),
    );
  }

  Future<GeminiTranslation> translateDocument(TranslationRequest request) async {
    _log.i('Translating: ${request.fileName} → ${request.targetLanguage}');

    final userMessage =
        'Source language: ${request.sourceLanguage}\nTarget language: ${request.targetLanguage}';

    final response = await _model!.generateContent([
      Content.multi([
        InlineDataPart(request.mimeType, request.fileBytes),
        TextPart(userMessage),
      ]),
    ]);

    final raw = response.text;
    if (raw == null || raw.trim().isEmpty) {
      throw Exception('No translation received from Gemini');
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final translatedText = (decoded['translatedText'] as String?)?.trim() ?? '';
    final detectedSourceLanguage =
        (decoded['detectedSourceLanguage'] as String?)?.trim() ?? '';

    if (translatedText.isEmpty) {
      throw Exception('No translation received from Gemini');
    }

    _log.i(
        'Translation complete for: ${request.fileName} (detected: $detectedSourceLanguage)');
    return (
      translatedText: translatedText,
      detectedSourceLanguage: detectedSourceLanguage,
    );
  }
}
