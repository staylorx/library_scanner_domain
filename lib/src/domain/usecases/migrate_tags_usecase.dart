import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

/// Use case for migrating tags from name-based IDs to UUID-based IDs.
class MigrateTagsUsecase {
  final TagRepository tagRepository;
  final BookRepository bookRepository;

  MigrateTagsUsecase({
    required this.tagRepository,
    required this.bookRepository,
  });

  final logger = Logger('MigrateTagsUsecase');

  /// Migrates existing tags to use UUID IDs and updates book references.
  ///
  /// This method performs the following operations:
  /// 1. Retrieves all tags from the repository.
  /// 2. For each tag that still uses name as ID (legacy), generates a new UUID and updates the tag.
  /// 3. Retrieves all books and updates their tagIds from old names to new UUIDs.
  /// 4. Returns success or failure.
  ///
  /// This migration should be run once after updating the codebase to UUID-based tag IDs.
  Future<Either<Failure, Unit>> call() async {
    logger.info('MigrateTagsUsecase: Entering call');

    try {
      // Get all tags
      final tagsEither = await tagRepository.getTags();
      if (tagsEither.isLeft()) {
        return Left(
          tagsEither.getLeft().getOrElse(
            () => DatabaseFailure('Failed to get tags'),
          ),
        );
      }
      final tags = tagsEither.getRight().getOrElse(() => []);

      // Create a map of old name to new id for tags that need migration
      final nameToNewId = <String, String>{};
      final updatedTags = <Tag>[];

      for (final tag in tags) {
        if (tag.id.toString() == tag.name) {
          // This is a legacy tag using name as ID
          final newId = const Uuid().v4();
          final updatedTag = Tag(
            id: TagHandle(newId),
            name: tag.name,
            description: tag.description,
            color: tag.color,
          );
          nameToNewId[tag.name] = newId;
          updatedTags.add(updatedTag);
          logger.info(
            'MigrateTagsUsecase: Migrating tag ${tag.name} to new ID $newId',
          );
        }
      }

      // Update tags with new IDs
      for (final updatedTag in updatedTags) {
        final updateEither = await tagRepository.updateTag(
          handle: updatedTag.id,
          tag: updatedTag,
        );
        if (updateEither.isLeft()) {
          return Left(
            updateEither.getLeft().getOrElse(
              () => DatabaseFailure('Failed to update tag'),
            ),
          );
        }
      }

      // Get all books
      final booksEither = await bookRepository.getBooks();
      if (booksEither.isLeft()) {
        return Left(
          booksEither.getLeft().getOrElse(
            () => DatabaseFailure('Failed to get books'),
          ),
        );
      }
      final books = booksEither.getRight().getOrElse(() => []);

      // Update books with new tag IDs
      for (final book in books) {
        final updatedTagIds = book.tags.map((tag) {
          return nameToNewId[tag.name] ?? tag.name;
        }).toList();

        if (updatedTagIds != book.tags.map((t) => t.name).toList()) {
          // Need to update this book
          final updatedBook = Book(
            businessIds: book.businessIds,
            title: book.title,
            originalTitle: book.originalTitle,
            description: book.description,
            authors: book.authors,
            tags: book.tags.map((tag) {
              final newId = nameToNewId[tag.name] ?? tag.id.toString();
              return Tag(
                id: TagHandle(newId),
                name: tag.name,
                description: tag.description,
                color: tag.color,
              );
            }).toList(),
            publishedDate: book.publishedDate,
            coverImage: book.coverImage,
            notes: book.notes,
          );

          final updateEither = await bookRepository.updateBook(
            book: updatedBook,
          );
          if (updateEither.isLeft()) {
            return Left(
              updateEither.getLeft().getOrElse(
                () => DatabaseFailure('Failed to update book'),
              ),
            );
          }
          logger.info(
            'MigrateTagsUsecase: Updated book ${book.title} with new tag IDs',
          );
        }
      }

      logger.info('MigrateTagsUsecase: Migration completed successfully');
      logger.info('MigrateTagsUsecase: Exiting call');
      return Right(unit);
    } catch (e) {
      logger.severe('MigrateTagsUsecase: Exception during migration: $e');
      return Left(DatabaseFailure('Migration failed: $e'));
    }
  }
}
