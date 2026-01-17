import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/src/data/data.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:uuid/uuid.dart';

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
  Future<Either<Failure, List<Author>>> getAuthors() async {
    logger?.info('Entering getAuthors');
    final result = await _authorDatasource.getAllAuthors();
    return result.fold(
      (failure) {
        logger?.warning('Failed to get authors: ${failure.message}');
        return Either.left(failure);
      },
      (models) {
        logger?.info('Successfully retrieved ${models.length} authors');
        final authors = <Author>[];
        for (final model in models) {
          final author = model.toEntity();
          authors.add(author);
        }
        return Either.right(authors);
      },
    );
  }

  /// Retrieves an author by name.
  @override
  Future<Either<Failure, Author>> getAuthorByName({
    required String name,
  }) async {
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
  Future<Either<Failure, List<Author>>> getAuthorsByNames({
    required List<String> names,
  }) async {
    logger?.info('Entering getAuthorsByNames with names: $names');
    if (names.isEmpty) {
      logger?.info('names is empty, returning empty list');
      return Either.right([]);
    }
    final result = await _authorDatasource.getAuthorsByNames(names);
    return result.fold((failure) => Either.left(failure), (models) {
      final authors = <Author>[];
      for (final model in models) {
        final author = model.toEntity();
        authors.add(author);
      }
      logger?.info(
        'Success in getAuthorsByNames, fetched ${authors.length} authors',
      );
      return Either.right(authors);
    });
  }

  /// Adds a new author to the database.
  @override
  Future<Either<Failure, Author>> addAuthor({
    required Author author,
    Transaction? txn,
  }) async {
    logger?.info('Entering addAuthor with author: ${author.name}');
    final id = const Uuid().v4();
    final authorWithId = author.copyWith(id: id);
    final model = AuthorModel.fromEntity(authorWithId);
    if (txn != null) {
      logger?.info('Using provided transaction for addAuthor');
      final db = (txn as SembastTransaction).db;
      final saveResult = await _authorDatasource.saveAuthor(model, db: db);
      return saveResult.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(authorWithId),
      );
    } else {
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
        return authorWithId;
      });
    }
  }

  /// Updates an existing author in the database.
  @override
  Future<Either<Failure, Unit>> updateAuthor({
    required Author author,
    Transaction? txn,
  }) async {
    logger?.info(
      'Entering updateAuthor with id: ${author.id} and author: ${author.name}',
    );
    final model = AuthorModel.fromEntity(author);
    if (txn != null) {
      logger?.info('Using provided transaction for updateAuthor');
      final db = (txn as SembastTransaction).db;
      final result = await _authorDatasource.saveAuthor(model, db: db);
      return result.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } else {
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
  }

  /// Deletes an author from the database.
  @override
  Future<Either<Failure, Unit>> deleteAuthor({
    required Author author,
    Transaction? txn,
  }) async {
    logger?.info('Entering deleteAuthor with id: ${author.id}');
    if (txn != null) {
      logger?.info('Using provided transaction for deleteAuthor');
      final db = (txn as SembastTransaction).db;
      final result = await _authorDatasource.deleteAuthorWithCascade(
        author.id,
        db: db,
      );
      return result.fold(
        (failure) => Either.left(failure),
        (_) => Either.right(unit),
      );
    } else {
      return _unitOfWork.run((Transaction txn) async {
        logger?.info('Transaction started for deleteAuthor');
        final db = (txn as SembastTransaction).db;
        final result = await _authorDatasource.deleteAuthorWithCascade(
          author.id,
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
  }

  /// Retrieves an author by id.
  @override
  Future<Either<Failure, Author>> getAuthorById({required String id}) async {
    logger?.info('Entering getById with id: $id');
    final result = await _authorDatasource.getAuthorById(id);
    return result.fold(
      (failure) {
        logger?.warning(
          'Failed to get Author by id: $id, Error: ${failure.message}',
        );
        return Either.left(failure);
      },
      (model) {
        logger?.info('Successfully retrieved Author by id: $id');
        if (model == null) {
          logger?.info('Author with id $id not found');
          return Either.left(NotFoundFailure('Author not found'));
        }
        final author = model.toEntity();
        logger?.info('Output: ${author.name}');
        return Either.right(author);
      },
    );
  }
}
