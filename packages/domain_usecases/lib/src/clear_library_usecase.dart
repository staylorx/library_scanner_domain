import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// Use case for clearing the entire library.
class ClearLibraryUsecase with Loggable {
  final LibraryDataAccess dataAccess;

  ClearLibraryUsecase({Logger? logger, required this.dataAccess});

  /// Clears all data from the library (books, authors, tags).
  TaskEither<Failure, Unit> call() {
    logger?.info('ClearLibraryUsecase: Clearing library');
    // TODO: run through all data access layers and clear them in the correct order (e.g., clear books before authors)
    return dataAccess.tagRepository
        .deleteAll()
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
