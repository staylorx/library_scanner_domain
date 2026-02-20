import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// Clears all data from the library atomically.
///
/// Books, authors and tags are deleted together inside a single [UnitOfWork]
/// transaction so that a partial failure cannot leave the database in an
/// inconsistent state.
///
/// Deletion order matters to minimise orphaned references during the
/// transaction:
///   1. Books (they reference authors and tags)
///   2. Tags  (they reference books via bookIds)
///   3. Authors
class ClearLibraryUsecase with Loggable {
  final LibraryDataAccess _dataAccess;

  ClearLibraryUsecase({Logger? logger, required LibraryDataAccess dataAccess})
      : _dataAccess = dataAccess {
    this.logger = logger;
  }

  /// Deletes all books, tags and authors within a single transaction.
  TaskEither<Failure, Unit> call() {
    logger?.info('ClearLibraryUsecase: clearing library');
    return _dataAccess.unitOfWork.run(
      (txn) => _dataAccess.bookRepository
          .deleteAll(txn: txn)
          .flatMap((_) => _dataAccess.tagRepository.deleteAll(txn: txn))
          .flatMap((_) => _dataAccess.authorRepository.deleteAll(txn: txn))
          .map((_) {
            logger?.info('ClearLibraryUsecase: library cleared successfully');
            return unit;
          })
          .mapLeft((failure) {
            logger?.error(
              'ClearLibraryUsecase: failed — ${failure.message}',
            );
            return failure;
          }),
    );
  }
}
