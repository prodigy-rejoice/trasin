import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import '../repositories/translation_repository.dart';
import '../services/gemini_service.dart';
import '../services/pdf_service.dart';
import '../screens/processing/processing_view.dart';
import '../screens/result/result_view.dart';
import '../screens/upload/upload_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: UploadView, initial: true),
    MaterialRoute(page: ProcessingView),
    MaterialRoute(page: ResultView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: GeminiService),
    LazySingleton(classType: PdfService),
    LazySingleton(classType: TranslationRepository),
  ],
  logger: StackedLogger(),
)
class App {}