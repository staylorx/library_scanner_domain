import 'package:domain_usecases/domain_usecase.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });

  tearDown(() async {
    await env.dispose();
  });

  test('GetBookByIdPairUsecase returns book', () async {
    final author = await env.addAuthor('BookAuthor');
    final tag = await env.addTag('BookTag');
    final book = await env.addBook(
      title: 'My Book',
      authors: [author],
      tags: [tag],
    );

    final usecase = GetBookByIdPairUsecase(bookRepository: env.bookRepository);
    final res = await usecase(bookIdPair: book.businessIds.first).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => null, (r) => r);
    expect(found?.title, 'My Book');
  });
}
