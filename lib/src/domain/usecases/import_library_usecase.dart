import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for importing a library from a file.
class ImportLibraryUsecase with Loggable {
  final LibraryRepository libraryRepository;

  ImportLibraryUsecase({Logger? logger, required this.libraryRepository});

  /// Imports a library from the specified file path.
  Future<Either<Failure, ImportResult>> call({
    required String filePath,
    bool overwrite = false,
  }) async {
    logger?.info(
      'ImportLibraryUsecase: Importing library from $filePath, overwrite: $overwrite',
    );
    final result = await libraryRepository.importLibrary(
      filePath,
      overwrite: overwrite,
    );
    result.fold(
      (failure) => logger?.error(
        'ImportLibraryUsecase: Failed to import library: ${failure.message}',
      ),
      (library) =>
          logger?.info('ImportLibraryUsecase: Successfully imported library'),
    );
    return result;
  }
}
