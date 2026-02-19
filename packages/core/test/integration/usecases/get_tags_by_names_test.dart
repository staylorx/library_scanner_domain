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

  test('GetTagsByNamesUsecase returns tags by name', () async {
    await env.addTag('TagY');

    final usecase = GetTagsByNamesUsecase(tagRepository: env.tagRepository);
    final res = await usecase(names: ['TagY']).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => <Tag>[], (r) => r);
    expect(found.any((t) => t.name == 'TagY'), true);
  });
}
