import 'package:domain_entities/domain_entities.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for deleting an author from the repository.
class DeleteAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  DeleteAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Deletes an author by id and returns the updated list of authors.
  /// Deletes an author by id and returns `unit` on success.
  TaskEither<Failure, Unit> call({required String id}) {
    logger?.info('DeleteAuthorUsecase: Entering call with id: $id');
    return authorRepository.getById(id: id).flatMap((author) {
      logger?.info('DeleteAuthorUsecase: Deleting author: ${author.name}');
      return authorRepository.deleteById(item: author).map((_) {
        logger?.info('DeleteAuthorUsecase: Success in call');
        return unit;
      });
    });
  }
}
