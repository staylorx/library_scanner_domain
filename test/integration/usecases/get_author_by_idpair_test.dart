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

  test('GetAuthorByIdPairUsecase finds author by id pair', () async {
    final author = await env.addAuthor('Author X');

    final usecase = GetAuthorByIdPairUsecase(
      authorRepository: env.authorRepository,
    );
    final res = await usecase(authorIdPair: author.businessIds.first).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => null, (r) => r);
    expect(found?.name, 'Author X');
  });
}
