import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app/app.logger.dart';
import '../models/translation_result.dart';

class PdfService {
  final _log = getLogger('PdfService');

  Future<void> generateAndDownload(TranslationResult result) async {
    _log.i('Generating PDF for: ${result.fileName}');

    final regularData = await rootBundle
        .load('assets/fonts/Noto_Sans/NotoSans-Regular.ttf');
    final boldData = await rootBundle
        .load('assets/fonts/Noto_Sans/NotoSans-Bold.ttf');
    final symbolsData = await rootBundle.load(
        'assets/fonts/Noto_Sans_Symbols_2/NotoSansSymbols2-Regular.ttf');
    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);
    final symbols = pw.Font.ttf(symbolsData);

    final theme = pw.ThemeData.withFont(
      base: regular,
      bold: bold,
      fontFallback: [symbols],
    );

    final isRtl = _isRtlLanguage(result.targetLanguage);
    final textDirection =
        isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    final pdf = pw.Document(theme: theme);

    final subtitleText = _sanitizeForPdf(_buildSubtitle(result));
    final paragraphs = _splitIntoParagraphs(result.translatedText);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(60),
        textDirection: textDirection,
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              subtitleText,
              style: pw.TextStyle(
                font: regular,
                fontSize: 9,
                color: PdfColors.grey500,
              ),
              textDirection: textDirection,
            ),
            pw.SizedBox(height: 28),
          ];
          for (var i = 0; i < paragraphs.length; i++) {
            final paragraph = paragraphs[i];
            final isTitle = _isTitleLine(paragraph, isFirstLine: i == 0);
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 14),
                child: pw.Text(
                  paragraph,
                  style: pw.TextStyle(
                    font: isTitle ? bold : regular,
                    fontWeight: isTitle
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                    fontSize: 12,
                    lineSpacing: 4,
                  ),
                  textDirection: textDirection,
                ),
              ),
            );
          }
          return widgets;
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'trasin_translation.pdf');
    _log.i('PDF download triggered');
  }

  bool _isRtlLanguage(String language) => language == 'Arabic';

  String _buildSubtitle(TranslationResult result) {
    final source = result.sourceLanguage;
    final detected = result.detectedSourceLanguage;
    final sourceText = source == 'Auto-detect' && detected != null
        ? 'Auto-detect ($detected)'
        : source;
    return 'Translated from $sourceText to ${result.targetLanguage}';
  }

  bool _isTitleLine(String line, {required bool isFirstLine}) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    if (isFirstLine) return true;
    if (trimmed.length > 50) return false;
    final lastChar = trimmed.substring(trimmed.length - 1);
    if (const ['.', ',', '!', '?', ';'].contains(lastChar)) return false;
    return true;
  }

  List<String> _splitIntoParagraphs(String text) {
    final chunks = text
        .split('\n')
        .map((line) => _sanitizeForPdf(line.trim()))
        .where((line) => line.isNotEmpty)
        .toList();
    return chunks.isEmpty ? [_sanitizeForPdf(text)] : chunks;
  }

  static const _arrowReplacements = <String, String>{
    '←': '<',
    '↑': '^',
    '→': '>',
    '↓': 'v',
    '↔': '<->',
    '↕': '^v',
    '⇐': '<=',
    '⇒': '=>',
    '⇔': '<=>',
  };

  String _sanitizeForPdf(String text) {
    var out = text;
    _arrowReplacements.forEach((from, to) {
      out = out.replaceAll(from, to);
    });
    out = out.replaceAll(RegExp(r'[←-⇿]'), '*');
    return out;
  }
}
