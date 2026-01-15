import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';
import 'package:id_registry/id_registry.dart';

/// Use case for checking if two books are duplicates.

class IsBookDuplicateUsecase with Loggable {
  IsBookDuplicateUsecase();

  /// Checks if two books are duplicates based on title, authors, and non-local id pairs.
  Either<Failure, bool> call({required Book bookA, required Book bookB}) {
    logger?.info(
      'IsBookDuplicateUsecase: Entering call with books: ${bookA.title} and ${bookB.title}',
    );

    if (bookA.title != bookB.title) {
      logger?.info('IsBookDuplicateUsecase: Titles do not match');
      return Right(false);
    }

    // Compare authors as sets
    final aAuthors = bookA.authors.map((author) => author.name).toSet();
    final bAuthors = bookB.authors.map((author) => author.name).toSet();
    if (aAuthors.length != bAuthors.length || !aAuthors.containsAll(bAuthors)) {
      logger?.info('IsBookDuplicateUsecase: Authors do not match');
      return Right(false);
    }

    // Check if any non-local BookIdPair matches
    final aNonLocal = IdPairSet(
      bookA.businessIds.where((p) => p.idType != BookIdType.local).toList(),
    );
    final bNonLocal = IdPairSet(
      bookB.businessIds.where((p) => p.idType != BookIdType.local).toList(),
    );

    // If there's any overlapping BookIdPair, they are duplicates
    if (aNonLocal.idPairs.any((id) => bNonLocal.idPairs.contains(id))) {
      logger?.info('IsBookDuplicateUsecase: Non-local IDs overlap');
      return Right(true);
    }

    // If no overlapping non-local ids, but title and authors match, they are duplicates
    logger?.info(
      'IsBookDuplicateUsecase: Books are duplicates based on title and authors',
    );
    return Right(true);
  }
}
