import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app/app.logger.dart';
import '../models/translation_result.dart';

class PdfService {
  final _log = getLogger('PdfService');

  Future<void> generateAndDownload(TranslationResult result) async {
    _log.i('Generating PDF for: ${result.fileName}');

    final pdf = pw.Document();
    final font = await _loadFont(result.targetLanguage);
    final isRtl = _isRtlLanguage(result.targetLanguage);
    final textDirection =
        isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    pdf.addPage(
      pw.MultiPage(
        textDirection: textDirection,
        header: (context) => _buildHeader(result, font),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text(
            result.translatedText,
            style: pw.TextStyle(font: font, fontSize: 12),
            textDirection: textDirection,
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'trasin_translation.pdf');
    _log.i('PDF download triggered');
  }

  pw.Widget _buildHeader(TranslationResult result, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Trasin',
              style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF1A56DB)),
            ),
            pw.Text(
              '${result.sourceLanguage} → ${result.targetLanguage}',
              style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.grey600),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(
              font: font, fontSize: 9, color: PdfColors.grey500),
        ),
      ],
    );
  }

  Future<pw.Font> _loadFont(String language) async {
    try {
      if (language == 'Chinese (Simplified)') {
        return await PdfGoogleFonts.notoSansSCRegular();
      }
      if (language == 'Japanese') {
        return await PdfGoogleFonts.notoSansJPRegular();
      }
      if (language == 'Korean') {
        return await PdfGoogleFonts.notoSansKRRegular();
      }
      if (language == 'Arabic') {
        return await PdfGoogleFonts.notoNaskhArabicRegular();
      }
    } catch (e) {
      _log.w('Specific font unavailable for $language, using fallback', error: e);
    }
    return await PdfGoogleFonts.notoSansRegular();
  }

  bool _isRtlLanguage(String language) => language == 'Arabic';
}
