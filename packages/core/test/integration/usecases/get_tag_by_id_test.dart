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

  test('GetTagByIdUsecase returns tag', () async {
    final tag = await env.addTag('TestTag');

    final usecase = GetTagByIdUsecase(tagRepository: env.tagRepository);
    final res = await usecase(id: tag.id).run();
    expect(res.isRight(), true);
    final found = res.fold((l) => null, (r) => r);
    expect(found?.name, 'TestTag');
    expect(found?.id, tag.id);
  });
}
