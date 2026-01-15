import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

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
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for addAuthor');
      final db = (txn as SembastTransaction).db;
      final saveResult = await _authorDatasource.saveAuthor(model, db: db);
      if (saveResult.isLeft()) {
        throw saveResult.getLeft().getOrElse(
          () => DatabaseFailure('Save failed'),
        );
      }
      logger?.info('Transaction operation completed for addAuthor');
      return AuthorProjection(handle: handle, author: author);
    });
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
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for updateAuthor');
      final db = (txn as SembastTransaction).db;
      final result = await _authorDatasource.saveAuthor(model, db: db);
      if (result.isLeft()) {
        throw result.getLeft().getOrElse(
          () => DatabaseFailure('Update failed'),
        );
      }
      logger?.info('Update author completed');
      return unit;
    });
  }

  /// Deletes an author from the database.
  @override
  Future<Either<Failure, Unit>> deleteAuthor({
    required AuthorHandle handle,
  }) async {
    logger?.info('Entering deleteAuthor with handle: $handle');
    return _unitOfWork.run((Transaction txn) async {
      logger?.info('Transaction started for deleteAuthor');
      final db = (txn as SembastTransaction).db;
      final result = await _authorDatasource.deleteAuthorWithCascade(
        handle.toString(),
        db: db,
      );
      if (result.isLeft()) {
        throw result.getLeft().getOrElse(
          () => DatabaseFailure('Delete failed'),
        );
      }
      logger?.info('Delete author completed');
      return unit;
    });
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
