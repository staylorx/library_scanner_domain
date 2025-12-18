import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';
import '../entities/book.dart';
import '../entities/tag.dart';
import '../repositories/book_repository.dart';

class GetBooksByTagUseCase {
  final IBookRepository _bookRepository;

  GetBooksByTagUseCase({required IBookRepository bookRepository})
    : _bookRepository = bookRepository;

  Future<Either<Failure, List<Book>>> call({required Tag tag}) async {
    return await _bookRepository.getBooksByTag(tag: tag);
  }
}
