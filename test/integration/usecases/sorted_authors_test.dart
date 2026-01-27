import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'test_utils.dart';
import 'package:library_scanner_domain/src/data/core/services/author_sorting_service.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });

  tearDown(() async {
    await env.dispose();
  });

  test('GetSortedAuthorsUsecase sorts authors', () async {
    await env.addAuthor('Charlie');
    await env.addAuthor('Alice');
    final authorsAll = await env.authorRepository.getAll().run();
    final authors = authorsAll.fold((l) => <Author>[], (r) => r);

    final usecase = GetSortedAuthorsUsecase(
      sortingService: AuthorSortingServiceImpl(),
    );
    final res = await usecase(authors, const AuthorSortSettings()).run();
    expect(res.isRight(), true);
    final sorted = res.fold((l) => <Author>[], (r) => r);
    expect(sorted.first.name.compareTo(sorted.last.name) <= 0, true);
  });
}
