import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';

/// Use case for deleting an author from the repository.
class DeleteAuthorUsecase with Loggable {
  final AuthorRepository authorRepository;

  DeleteAuthorUsecase({Logger? logger, required this.authorRepository});

  /// Deletes an author by name and returns the updated list of authors.
  Future<Either<Failure, List<Author>>> call({required String name}) async {
    logger?.info('DeleteAuthorUsecase: Entering call with name: $name');
    final getAuthorsEither = await authorRepository.getAuthors();
    return getAuthorsEither.fold((failure) => Left(failure), (authors) async {
      final author = authors.where((a) => a.name == name).firstOrNull;
      if (author == null) {
        return Left(NotFoundFailure('Author not found'));
      }
      logger?.info('DeleteAuthorUsecase: Deleting author: ${author.name}');
      final deleteEither = await authorRepository.deleteAuthor(author: author);
      return deleteEither.fold((failure) => Left(failure), (_) {
        final updatedAuthors = authors.where((a) => a.name != name).toList();
        logger?.info('DeleteAuthorUsecase: Success in call');
        logger?.info(
          'DeleteAuthorUsecase: Output: ${updatedAuthors.map((a) => a.name).toList()}',
        );
        return Right(updatedAuthors);
      });
    });
  }
}
