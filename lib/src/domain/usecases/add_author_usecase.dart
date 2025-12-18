import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Use case for adding a new author to the repository.
class AddAuthorUsecase {
  final IAuthorRepository authorRepository;

  AddAuthorUsecase(this.authorRepository);

  final logger = DevLogger('AddAuthorUsecase');

  /// Adds a new author and returns the updated list of authors.
  Future<Either<Failure, List<Author>>> call({required Author author}) async {
    logger.info('AddAuthorUsecase: Entering call with author: ${author.name}');
    final addEither = await authorRepository.addAuthor(author: author);
    return addEither.fold((failure) => Future.value(Left(failure)), (_) async {
      final getEither = await authorRepository.getAuthors();
      logger.info('AddAuthorUsecase: Success in call');
      return getEither.fold((failure) => Left(failure), (authors) {
        logger.info(
          'AddAuthorUsecase: Output: ${authors.map((a) => a.name).toList()}',
        );
        logger.info('AddAuthorUsecase: Exiting call');
        return Right(authors);
      });
    });
  }
}
