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

  test('GetAuthorsByNamesUsecase returns matching authors', () async {
    await env.addAuthor('Author A');
    await env.addAuthor('Author B');

    final usecase = GetAuthorsByNamesUsecase(
      authorRepository: env.authorRepository,
    );
    final res = await usecase(names: ['Author A']).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => <Author>[], (r) => r);
    expect(found.any((a) => a.name == 'Author A'), true);
  });
}
