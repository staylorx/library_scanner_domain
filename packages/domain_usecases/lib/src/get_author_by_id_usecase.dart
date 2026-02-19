import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';

import 'package:fpdart/fpdart.dart';

import 'package:id_logging/id_logging.dart';

/// Use case for retrieving an author by ID.
class GetAuthorByIdUsecase with Loggable {
  final AuthorRepository authorRepository;

  GetAuthorByIdUsecase({Logger? logger, required this.authorRepository});

  /// Retrieves an author by ID.
  TaskEither<Failure, Author> call({required String id}) {
    logger?.info('GetAuthorByIdUsecase: Entering call with id: $id');
    return authorRepository.getById(id: id).map((author) {
      logger?.info(
        'GetAuthorByIdUsecase: Output: ${author.name} (id: ${author.id})',
      );
      return author;
    });
  }
}
