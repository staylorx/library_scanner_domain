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

  test('GetAuthorByIdUsecase returns author', () async {
    final author = await env.addAuthor('TestAuthor');

    final usecase = GetAuthorByIdUsecase(
      authorRepository: env.authorRepository,
    );
    final res = await usecase(id: author.id).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => null, (r) => r);
    expect(found?.name, 'TestAuthor');
    expect(found?.id, author.id);
  });
}
