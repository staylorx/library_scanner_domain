import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'test_utils.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });

  tearDown(() async {
    await env.dispose();
  });

  test('IsBookDuplicateUsecase and IsAuthorDuplicateUsecase', () async {
    final author = await env.addAuthor('Dup Author');
    final tag = await env.addTag('DupTag');
    final book = await env.addBook(
      title: 'Dup Book',
      authors: [author],
      tags: [tag],
    );

    final isBookDup = IsBookDuplicateUsecase();
    final bookDupResult = isBookDup(bookA: book, bookB: book);
    expect(bookDupResult.isRight(), true);
    expect(bookDupResult.fold((l) => false, (r) => r), true);

    final isAuthorDup = IsAuthorDuplicateUsecase();
    final authorDupResult = isAuthorDup(authorA: author, authorB: author);
    expect(authorDupResult.isRight(), true);
    expect(authorDupResult.fold((l) => false, (r) => r), true);
  });
}
