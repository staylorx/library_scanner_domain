import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Use case for exporting a library to a file.
class ExportLibraryUsecase {
  final AbstractLibraryRepository libraryRepository;

  ExportLibraryUsecase({required this.libraryRepository});

  final logger = Logger('ExportLibraryUsecase');

  /// Exports the library to the specified file path.
  Future<Either<Failure, Unit>> call({
    required String filePath,
    required Library library,
  }) async {
    logger.info('ExportLibraryUsecase: Exporting library to $filePath');
    final result = await libraryRepository.exportLibrary(
      filePath: filePath,
      library: library,
    );
    result.fold(
      (failure) => logger.severe(
        'ExportLibraryUsecase: Failed to export library: ${failure.message}',
      ),
      (_) => logger.info('ExportLibraryUsecase: Successfully exported library'),
    );
    return result;
  }
}
