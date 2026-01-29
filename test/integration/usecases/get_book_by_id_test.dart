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

  test('GetBookByIdUsecase returns book', () async {
    final author = await env.addAuthor('BookAuthor');
    final tag = await env.addTag('BookTag');
    final book = await env.addBook(
      title: 'My Book',
      authors: [author],
      tags: [tag],
    );

    final usecase = GetBookByIdUsecase(bookRepository: env.bookRepository);
    final res = await usecase(id: book.id).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => null, (r) => r);
    expect(found?.title, 'My Book');
    expect(found?.id, book.id);
  });
}
