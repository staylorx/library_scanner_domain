import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

// TODO: more of a usecase here
/// Implementation of author validation service
class AuthorValidationServiceImpl
    with Loggable
    implements AuthorValidationService {
  final AuthorIdRegistryService idRegistryService;

  AuthorValidationServiceImpl({
    required this.idRegistryService,
    Logger? logger,
  });

  @override
  TaskEither<Failure, Author> validate(Author author) {
    if (author.name.isEmpty) {
      return TaskEither.left(ValidationFailure('Author name cannot be empty'));
    }

    // Check for duplicate ID pairs
    final checks = author.businessIds
        .map(
          (idPair) =>
              idRegistryService.isRegistered(idPair.idType.name, idPair.idCode),
        )
        .toList();

    return TaskEither.traverseList(checks, (x) => x).flatMap((results) {
      for (int i = 0; i < results.length; i++) {
        if (results[i]) {
          final idPair = author.businessIds[i];
          return TaskEither.left(
            DuplicateIdFailure(
              'Author ID ${idPair.idType.displayName}:${idPair.idCode} is already registered',
            ),
          );
        }
      }
      return TaskEither.right(author);
    });
  }
}
