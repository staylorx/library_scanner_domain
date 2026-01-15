import 'package:fpdart/fpdart.dart';

import '../../utils/failure.dart';
import '../entities/book_metadata.dart';

abstract class BookMetadataRepository {
  Future<Either<Failure, BookMetadata>> fetchBookByIsbn({
    required String isbn,
    bool fetchCoverArt = true,
  });
}
