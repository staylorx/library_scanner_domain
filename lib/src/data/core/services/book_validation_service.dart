import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

// TODO: more of a usecase here

/// Implementation of book validation service
class BookValidationServiceImpl with Loggable implements BookValidationService {
  final BookIdRegistryService idRegistryService;

  BookValidationServiceImpl({required this.idRegistryService, Logger? logger});

  @override
  TaskEither<Failure, Book> validate(Book book) {
    return TaskEither(() async {
      if (book.title.isEmpty) {
        return Left(ValidationFailure('Book title cannot be empty'));
      }
      if (book.authors.isEmpty) {
        return Left(ValidationFailure('Book must have at least one author'));
      }

      // Check ID format validity
      for (final idPair in book.businessIds) {
        if (!idPair.isValid) {
          return Left(ValidationFailure('Book ID ${idPair.idType.displayName}:${idPair.idCode} has invalid format'));
        }
      }

      // Check for duplicate ID pairs
      final checks = book.businessIds
          .map(
            (idPair) => idRegistryService.isRegistered(
              idPair.idType.name,
              idPair.idCode,
            ),
          )
          .toList();

      final eitherList = await TaskEither.traverseList(checks, (x) => x).run();
      return eitherList.fold((failure) => Left(failure), (results) {
        for (int i = 0; i < results.length; i++) {
          if (results[i]) {
            final idPair = book.businessIds[i];
            return Left(
              DuplicateIdFailure(
                'Book ID ${idPair.idType.displayName}:${idPair.idCode} is already registered',
              ),
            );
          }
        }
        return Right(book);
      });
    });
  }
}
