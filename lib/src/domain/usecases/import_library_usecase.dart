import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Use case for importing a library from a file.
class ImportLibraryUsecase {
  final ILibraryRepository libraryRepository;

  ImportLibraryUsecase({required this.libraryRepository});

  final logger = Logger('ImportLibraryUsecase');

  /// Imports a library from the specified file path.
  Future<Either<Failure, ImportResult>> call({
    required String filePath,
    bool overwrite = false,
  }) async {
    logger.info(
      'ImportLibraryUsecase: Importing library from $filePath, overwrite: $overwrite',
    );
    final result = await libraryRepository.importLibrary(filePath);
    result.fold(
      (failure) => logger.severe(
        'ImportLibraryUsecase: Failed to import library: ${failure.message}',
      ),
      (library) =>
          logger.info('ImportLibraryUsecase: Successfully imported library'),
    );
    return result;
  }
}
