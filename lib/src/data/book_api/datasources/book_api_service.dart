import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_logging/id_logging.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Service for fetching book data from external APIs.
class BookApiServiceImpl with Loggable implements BookApiService {
  final Dio _dio;

  BookApiServiceImpl({required Dio dio, Logger? logger}) : _dio = dio;

  @override
  Future<Either<Failure, BookMetadata?>> fetchBookByIsbn({
    required String isbn,
  }) async {
    logger?.info('Fetching book by ISBN: $isbn');
    return TaskEither.tryCatch(
      () async {
        final response = await _dio.get(
          'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn',
        );
        logger?.debug('API response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          logger?.debug('Raw API response data: $data');
          final items = data['items'] as List<dynamic>?;
          logger?.debug('Items count: ${items?.length ?? 0}');

          if (items == null || items.isEmpty) {
            logger?.warning('No items found in response for ISBN: $isbn');
            return null;
          }

          final volumeInfo =
              (items.first as Map<String, dynamic>)['volumeInfo']
                  as Map<String, dynamic>;
          logger?.debug('VolumeInfo: $volumeInfo');

          // Map authors to authorIds (using author names as temporary IDs)
          final authors = volumeInfo['authors'] as List<dynamic>? ?? [];
          logger?.debug('Authors: $authors');
          final authorIds = authors.map((author) => author as String).toList();
          logger?.debug('Author IDs: $authorIds');

          // Handle description
          final description = volumeInfo['description'] as String?;

          // Parse published date
          DateTime? publishedDate;
          final publishDateStr = volumeInfo['publishedDate'] as String?;
          if (publishDateStr != null) {
            publishedDate = DateTime.tryParse(publishDateStr);
            if (publishedDate == null) {
              final year = int.tryParse(publishDateStr);
              if (year != null) {
                publishedDate = DateTime(year);
              }
            }
          }
          logger?.debug('Parsed published date: $publishedDate');

          // Extract cover image from imageLinks
          String? coverImageUrl;
          final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
          if (imageLinks != null) {
            coverImageUrl = imageLinks['thumbnail'] as String?;
          }
          logger?.debug('Cover image URL: $coverImageUrl');

          logger?.info(
            'Successfully parsed book: ${volumeInfo['title'] ?? 'Unknown Title'} by ${authorIds.join(', ')}',
          );
          return BookMetadata(
            title: volumeInfo['title'] as String? ?? 'Unknown Title',
            description: description,
            authors: authorIds,
            publishedDate: publishedDate,
            coverImageUrl: coverImageUrl,
            coverImage: null, // Will be downloaded later
            notes: null,
          );
        } else {
          logger?.error(
            'API request failed with status: ${response.statusCode}',
          );
          throw NetworkFailure('Failed to fetch book: ${response.statusCode}');
        }
      },
      (error, stackTrace) {
        if (error is DioException) {
          logger?.error('DioException during API call: $error');
          return NetworkFailure('DioException: ${error.message}');
        } else if (error is Failure) {
          return error;
        } else {
          logger?.error('Failed to parse book data: $error');
          return ParsingFailure('Failed to parse book data: $error');
        }
      },
    ).run();
  }
}
