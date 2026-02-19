import 'package:test/test.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'test_utils.dart';
import 'package:library_scanner_domain/src/data/core/services/author_filtering_service.dart';

void main() {
  late TestEnv env;

  setUp(() async {
    env = await TestEnv.create();
  });

  tearDown(() async {
    await env.dispose();
  });

  test('FilterAuthorsUsecase filters by query', () async {
    await env.addAuthor('Alice');
    await env.addAuthor('Bob');
    final authorsAll = await env.authorRepository.getAll().run();
    final authors = authorsAll.fold((l) => <Author>[], (r) => r);

    final usecase = FilterAuthorsUsecase(AuthorFilteringServiceImpl());
    final res = await usecase(authors: authors, searchQuery: 'Ali').run();
    expect(res.isRight(), true);
    final filtered = res.fold((l) => <Author>[], (r) => r);
    expect(filtered.any((a) => a.name == 'Alice'), true);
  });
}
