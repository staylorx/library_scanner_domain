import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';
import 'package:path_provider/path_provider.dart';
import 'flutter_image_service.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) => Dio());

// Database path provider
final databasePathProvider = FutureProvider<String?>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/library.db';
});

// Override library's external providers
final databaseServiceProviderOverride = databaseServiceProvider.overrideWith((
  ref,
) async {
  final dbPath = await ref.watch(databasePathProvider.future);
  return SembastDatabase(testDbPath: dbPath);
});

final unitOfWorkProviderOverride = unitOfWorkProvider.overrideWith((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SembastUnitOfWork(dbService: dbService);
});

final imageServiceProviderOverride = imageServiceProvider.overrideWith((ref) {
  final dio = ref.watch(dioProvider);
  return FlutterImageService(dio);
});

// State providers for UI
final authorsProvider = FutureProvider<List<Author>>((ref) async {
  final usecase = await ref.watch(getAuthorsUsecaseProvider.future);
  final result = await usecase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (authors) => authors,
  );
});

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final usecase = await ref.watch(getBooksUsecaseProvider.future);
  final result = await usecase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (books) => books,
  );
});
