import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for deleting an author from the repository.
class DeleteAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  DeleteAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Deletes an author by id and returns the updated list of authors.
  TaskEither<Failure, List<Author>> call({required String id}) {
    logger?.info('DeleteAuthorUsecase: Entering call with id: $id');
    return authorRepository.getById(id: id).flatMap((author) {
      logger?.info('DeleteAuthorUsecase: Deleting author: ${author.name}');
      return authorRepository.deleteById(item: author).flatMap((_) {
        return authorRepository.getAll().map((authors) {
          final updatedAuthors = authors.where((a) => a.id != id).toList();
          logger?.info('DeleteAuthorUsecase: Success in call');
          logger?.info(
            'DeleteAuthorUsecase: Output: ${updatedAuthors.map((a) => a.name).toList()}',
          );
          return updatedAuthors;
        });
      });
    });
  }
}
