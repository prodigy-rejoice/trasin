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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        textDirection: textDirection,
        header: (context) => _buildHeader(result, regular, bold),
        footer: (context) => _buildFooter(context, regular),
        build: (context) => [
          pw.SizedBox(height: 20),
          for (final paragraph in _splitIntoParagraphs(result.translatedText))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                paragraph,
                style: pw.TextStyle(font: regular, fontSize: 12),
                textDirection: textDirection,
              ),
            ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'trasin_translation.pdf');
    _log.i('PDF download triggered');
  }

  pw.Widget _buildHeader(
    TranslationResult result,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Trasin',
              style: pw.TextStyle(
                font: bold,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF1A56DB),
              ),
            ),
            pw.Text(
              _sanitizeForPdf(
                  '${result.sourceLanguage} → ${result.targetLanguage}'),
              style: pw.TextStyle(
                font: regular,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font regular) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(
            font: regular,
            fontSize: 9,
            color: PdfColors.grey500,
          ),
        ),
      ],
    );
  }

  bool _isRtlLanguage(String language) => language == 'Arabic';

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
