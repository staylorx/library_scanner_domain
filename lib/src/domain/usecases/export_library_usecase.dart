import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for exporting a library to a file.
class ExportLibraryUsecase with Loggable {
  final LibraryRepository libraryRepository;

  ExportLibraryUsecase({Logger? logger, required this.libraryRepository});

  /// Exports the library to the specified file path.
  Future<Either<Failure, Unit>> call({
    required String filePath,
    required Library library,
  }) async {
    logger?.info('ExportLibraryUsecase: Exporting library to $filePath');
    final result = await libraryRepository.exportLibrary(
      filePath: filePath,
      library: library,
    );
    result.fold(
      (failure) => logger?.error(
        'ExportLibraryUsecase: Failed to export library: ${failure.message}',
      ),
      (_) =>
          logger?.info('ExportLibraryUsecase: Successfully exported library'),
    );
    return result;
  }
}
