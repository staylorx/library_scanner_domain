import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for retrieving an author by name.
class GetAuthorByNameUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorByNameUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves an author by name.
  TaskEither<Failure, Author> call({required String name}) {
    logger?.info('getByNameUsecase: Entering call with name: $name');
    return authorRepository.getAuthorByName(name: name).map((author) {
      logger?.info('getByNameUsecase: Output: ${author.name}');
      return author;
    });
  }
}
