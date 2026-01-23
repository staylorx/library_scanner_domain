import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

import 'package:fpdart/fpdart.dart';
import 'package:id_registry/id_registry.dart';

/// Use case for checking if two authors are duplicates.
class IsAuthorDuplicateUsecase with Loggable {
  IsAuthorDuplicateUsecase();

  /// Checks if two authors are duplicates based on name and non-local id pairs.
  Either<Failure, bool> call({
    required Author authorA,
    required Author authorB,
  }) {
    logger?.info(
      'IsAuthorDuplicateUsecase: Entering call with authors: ${authorA.name} and ${authorB.name}',
    );

    if (authorA.name != authorB.name) {
      logger?.info('IsAuthorDuplicateUsecase: Names do not match');
      return Either.of(false);
    }

    // Check if any non-local AuthorIdPair matches
    final aNonLocal = IdPairSet(
      authorA.businessIds.where((p) => p.idType != AuthorIdType.local).toList(),
    );
    final bNonLocal = IdPairSet(
      authorB.businessIds.where((p) => p.idType != AuthorIdType.local).toList(),
    );

    // If there's any overlapping AuthorIdPair, they are duplicates
    if (aNonLocal.idPairs.any((id) => bNonLocal.idPairs.contains(id))) {
      logger?.info('IsAuthorDuplicateUsecase: Non-local IDs overlap');
      return Either.of(true);
    }

    // If no overlapping non-local ids, but names match, they are duplicates
    logger?.info(
      'IsAuthorDuplicateUsecase: Authors are duplicates based on name',
    );
    return Either.of(true);
  }
}
