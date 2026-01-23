import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for clearing the entire library.
class ClearLibraryUsecase with Loggable {
  final LibraryDataAccess dataAccess;

  ClearLibraryUsecase({Logger? logger, required this.dataAccess});

  /// Clears all data from the library (books, authors, tags).
  TaskEither<Failure, Unit> call() {
    logger?.info('ClearLibraryUsecase: Clearing library');
    return dataAccess.databaseService
        .clearAll()
        .map((_) {
          logger?.info('ClearLibraryUsecase: Successfully cleared library');
          return unit;
        })
        .mapLeft((failure) {
          logger?.error(
            'ClearLibraryUsecase: Failed to clear library: ${failure.message}',
          );
          return failure;
        });
  }
}
