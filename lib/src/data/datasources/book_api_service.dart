import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

class BookApiService implements IBookApiService {
  final Dio _dio;
  final DevLogger _logger = DevLogger('BookApiService');

  BookApiService({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, BookModel?>> fetchBookByIsbn({
    required String isbn,
  }) async {
    _logger.info('Fetching book by ISBN: $isbn');
    // NOTE: other options: https://openlibrary.org/isbn/$isbn.json
    try {
      final response = await _dio.get(
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn',
      );
      _logger.debug('API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = response.data as Map<String, dynamic>;
          _logger.debug('Raw API response data: $data');
          final items = data['items'] as List<dynamic>?;
          _logger.debug('Items count: ${items?.length ?? 0}');

          if (items == null || items.isEmpty) {
            _logger.warning('No items found in response for ISBN: $isbn');
            return Right(null);
          }

          final volumeInfo =
              (items.first as Map<String, dynamic>)['volumeInfo']
                  as Map<String, dynamic>;
          _logger.debug('VolumeInfo: $volumeInfo');

          // Map authors to authorIds (using author names as temporary IDs)
          final authors = volumeInfo['authors'] as List<dynamic>? ?? [];
          _logger.debug('Authors: $authors');
          final authorIds = authors.map((author) => author as String).toList();
          _logger.debug('Author IDs: $authorIds');

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
          _logger.debug('Parsed published date: $publishedDate');

          // Extract cover image from imageLinks
          String? coverImageUrl;
          final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
          if (imageLinks != null) {
            coverImageUrl = imageLinks['thumbnail'] as String?;
          }
          _logger.debug('Cover image URL: $coverImageUrl');

          _logger.info(
            'Successfully parsed book: ${volumeInfo['title'] ?? 'Unknown Title'} by ${authorIds.join(', ')}',
          );
          return Right(
            BookModel(
              id: isbn,
              idPairs: [BookIdPair(idType: BookIdType.isbn, idCode: isbn)],
              title: volumeInfo['title'] as String? ?? 'Unknown Title',
              description: description,
              authorIds: authorIds,
              tagIds: [], // Empty for partial model
              publishedDate: publishedDate,
              coverImage: null, // Will be downloaded later
              coverImageUrl: coverImageUrl,
            ),
          );
        } catch (e) {
          _logger.error('Failed to parse book data', error: e);
          return Left(ParsingFailure('Failed to parse book data: $e'));
        }
      } else {
        _logger.error('API request failed with status: ${response.statusCode}');
        return Left(
          NetworkFailure('Failed to fetch book: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      _logger.error('DioException during API call', error: e);
      return Left(NetworkFailure('DioException: ${e.message}'));
    }
  }
}
