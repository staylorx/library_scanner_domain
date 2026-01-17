import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for deleting an author from the repository.
class DeleteAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  DeleteAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Deletes an author by id and returns the updated list of authors.
  Future<Either<Failure, List<Author>>> call({required String id}) async {
    logger?.info('DeleteAuthorUsecase: Entering call with id: $id');
    final getAuthorEither = await authorRepository.getById(id: id);
    return getAuthorEither.fold((failure) => Left(failure), (author) async {
      logger?.info('DeleteAuthorUsecase: Deleting author: ${author.name}');
      final deleteEither = await authorRepository.deleteAuthor(author: author);
      return deleteEither.fold((failure) => Left(failure), (_) async {
        final getAuthorsEither = await authorRepository.getAuthors();
        return getAuthorsEither.fold((failure) => Left(failure), (authors) {
          final updatedAuthors = authors.where((a) => a.id != id).toList();
          logger?.info('DeleteAuthorUsecase: Success in call');
          logger?.info(
            'DeleteAuthorUsecase: Output: ${updatedAuthors.map((a) => a.name).toList()}',
          );
          return Right(updatedAuthors);
        });
      });
    });
  }
}
