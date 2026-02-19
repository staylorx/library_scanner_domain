import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'test_utils.dart';
import 'package:library_scanner_domain/src/data/core/services/book_validation_service.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });

  tearDown(() async {
    await env.dispose();
  });

  test('ValidateBookUsecase accepts valid book', () async {
    final author = await env.addAuthor('Valid Author');
    final tag = await env.addTag('Valid Tag');
    final book = await env.addBook(
      title: 'Valid Book',
      authors: [author],
      tags: [tag],
    );

    final validateUsecase = ValidateBookUsecase(
      bookValidationService: BookValidationServiceImpl(
        idRegistryService: NoopBookRegistry(),
      ),
    );
    final res = await validateUsecase(book).run();
    expect(res.isRight(), true);
  });
}
