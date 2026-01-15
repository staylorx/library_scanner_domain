import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for clearing the entire library.
class ClearLibraryUsecase with Loggable {
  final LibraryRepository libraryRepository;

  ClearLibraryUsecase({Logger? logger, required this.libraryRepository});

  /// Clears all data from the library (books, authors, tags).
  Future<Either<Failure, Unit>> call() async {
    logger?.info('ClearLibraryUsecase: Clearing library');
    final result = await libraryRepository.clearLibrary();
    result.fold(
      (failure) => logger?.error(
        'ClearLibraryUsecase: Failed to clear library: ${failure.message}',
      ),
      (_) => logger?.info('ClearLibraryUsecase: Successfully cleared library'),
    );
    return result;
  }
}
