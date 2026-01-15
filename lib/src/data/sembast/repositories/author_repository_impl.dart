import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:library_scanner_domain/src/domain/repositories/unit_of_work.dart';

/// Implementation of author repository using Sembast.
class AuthorRepositoryImpl with Loggable implements AuthorRepository {
  final AuthorDatasource _authorDatasource;
  final UnitOfWork _unitOfWork;

  /// Creates an AuthorRepositoryImpl instance.
  AuthorRepositoryImpl({
    required AuthorDatasource authorDatasource,
    required UnitOfWork unitOfWork,
    Logger? logger,
  }) : _authorDatasource = authorDatasource,
       _unitOfWork = unitOfWork;

  /// Retrieves all authors from the database.
  @override
  Future<Either<Failure, List<AuthorProjection>>> getAuthors() async {
    logger?.info('Entering getAuthors');
    final result = await _authorDatasource.getAllAuthors();
    return result.fold(
      (failure) {
        logger?.warning('Failed to get authors: ${failure.message}');
        return Either.left(failure);
      },
      (models) {
        logger?.info('Successfully retrieved ${models.length} authors');
        final projections = <AuthorProjection>[];
        for (final model in models) {
          final author = model.toEntity();
          final handle = AuthorHandle.fromString(model.id);
          projections.add(AuthorProjection(handle: handle, author: author));
        }
        return Either.right(projections);
      },
    );
  }

  /// Retrieves an author by name.
  @override
  Future<Either<Failure, Author>> getByName({required String name}) async {
    logger?.info('Entering getByName with name: $name');
    final result = await _authorDatasource.getAuthorByName(name);
    return result.fold((failure) => Either.left(failure), (model) {
      if (model == null) {
        return Either.left(NotFoundFailure('Author not found'));
      }
      logger?.info('Success, fetched author ${model.name}');
      return Either.right(model.toEntity());
    });
  }

  /// Retrieves authors by a list of names.
  @override
  Future<Either<Failure, List<AuthorProjection>>> getAuthorsByNames({
    required List<String> names,
  }) async {
    logger?.info('Entering getAuthorsByNames with names: $names');
    if (names.isEmpty) {
      logger?.info('names is empty, returning empty list');
      return Either.right([]);
    }
    final result = await _authorDatasource.getAuthorsByNames(names);
    return result.fold((failure) => Either.left(failure), (models) {
      final projections = <AuthorProjection>[];
      for (final model in models) {
        final author = model.toEntity();
        final handle = AuthorHandle.fromString(model.id);
        projections.add(AuthorProjection(handle: handle, author: author));
      }
      logger?.info(
        'Success in getAuthorsByNames, fetched ${projections.length} authors',
      );
      return Either.right(projections);
    });
  }

  /// Adds a new author to the database.
  @override
  Future<Either<Failure, AuthorProjection>> addAuthor({
    required Author author,
  }) async {
    logger?.info('Entering addAuthor with author: ${author.name}');
    final handle = AuthorHandle.fromName(author.name);
    final model = AuthorModel.fromEntity(author, handle.toString());
    final saveResult = await _authorDatasource.saveAuthor(model);
    if (saveResult.isLeft()) {
      logger?.warning(
        'Failed to save author: ${saveResult.getLeft().getOrElse(() => DatabaseFailure('Save failed')).message}',
      );
      return Either.left(
        saveResult.getLeft().getOrElse(() => DatabaseFailure('Save failed')),
      );
    }

    logger?.info('Add author completed');
    final projection = AuthorProjection(handle: handle, author: author);
    return Either.right(projection);
  }

  /// Updates an existing author in the database.
  @override
  Future<Either<Failure, Unit>> updateAuthor({
    required AuthorHandle handle,
    required Author author,
  }) async {
    logger?.info(
      'Entering updateAuthor with handle: $handle and author: ${author.name}',
    );
    final model = AuthorModel.fromEntity(author, handle.toString());
    final result = await _authorDatasource.saveAuthor(model);
    result.fold(
      (failure) =>
          logger?.warning('Failed to update author: ${failure.message}'),
      (_) => logger?.info('Update author completed'),
    );
    return result.map((_) => unit);
  }

  /// Deletes an author from the database.
  @override
  Future<Either<Failure, Unit>> deleteAuthor({
    required AuthorHandle handle,
  }) async {
    logger?.info('Entering deleteAuthor with handle: $handle');
    final result = await _authorDatasource.deleteAuthorWithCascade(
      handle.toString(),
    );
    if (result.isLeft()) {
      logger?.warning(
        'Failed to delete author: ${result.getLeft().getOrElse(() => DatabaseFailure('Delete failed')).message}',
      );
      return Either.left(
        result.getLeft().getOrElse(() => DatabaseFailure('Delete failed')),
      );
    }
    logger?.info('Delete author completed');
    return Either.right(unit);
  }

  /// Retrieves an author by handle.
  @override
  Future<Either<Failure, Author>> getByHandle({
    required AuthorHandle handle,
  }) async {
    logger?.info('Entering getByHandle with handle: $handle');
    final result = await _authorDatasource.getAuthorById(handle.toString());
    return result.fold(
      (failure) {
        logger?.warning(
          'Failed to get Author by handle: $handle, Error: ${failure.message}',
        );
        return Either.left(failure);
      },
      (model) {
        logger?.info('Successfully retrieved Author by handle: $handle');
        if (model == null) {
          logger?.info('Author with handle $handle not found');
          return Either.left(NotFoundFailure('Author not found'));
        }
        final author = model.toEntity();
        logger?.info('Output: ${author.name}');
        return Either.right(author);
      },
    );
  }
}
