import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';

/// Use case for clearing the entire library.
class ClearLibraryUsecase {
  final LibraryRepository libraryRepository;

  ClearLibraryUsecase({required this.libraryRepository});

  final logger = Logger('ClearLibraryUsecase');

  /// Clears all data from the library (books, authors, tags).
  Future<Either<Failure, Unit>> call() async {
    logger.info('ClearLibraryUsecase: Clearing library');
    final result = await libraryRepository.clearLibrary();
    result.fold(
      (failure) => logger.severe(
        'ClearLibraryUsecase: Failed to clear library: ${failure.message}',
      ),
      (_) => logger.info('ClearLibraryUsecase: Successfully cleared library'),
    );
    return result;
  }
}
