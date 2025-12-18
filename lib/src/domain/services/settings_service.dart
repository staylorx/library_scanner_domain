import 'package:fpdart/fpdart.dart';

import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Enum for tag color mode options
enum TagColorMode { normal, colorblind, none }

/// Abstract interface for persistence operations.
/// This allows for easy swapping of persistence mechanisms (SharedPreferences, Hive, etc.)
abstract class AbstractSettingsService {
  /// Saves a string value with the given key
  Future<Either<Failure, Unit>> saveString({
    required String key,
    required String value,
  });

  /// Retrieves a string value for the given key
  Future<Either<Failure, String?>> getString({required String key});

  /// Removes a value for the given key
  Future<Either<Failure, Unit>> remove({required String key});

  /// Retrieves the tag color mode setting
  Future<Either<Failure, TagColorMode>> getTagColorMode();

  /// Saves the tag color mode setting
  Future<Either<Failure, Unit>> setTagColorMode({required TagColorMode mode});

  /// Retrieves the fetch cover art setting
  Future<Either<Failure, bool>> getFetchCoverArt();

  /// Saves the fetch cover art setting
  Future<Either<Failure, Unit>> setFetchCoverArt({required bool fetch});

  /// Retrieves the tag selection inclusive setting (true for AND, false for OR)
  Future<Either<Failure, bool>> getTagSelectionInclusive();

  /// Saves the tag selection inclusive setting
  Future<Either<Failure, Unit>> setTagSelectionInclusive({
    required bool inclusive,
  });

  /// Retrieves the book list filters collapsed setting
  Future<Either<Failure, bool>> getBookListFiltersCollapsed();

  /// Saves the book list filters collapsed setting
  Future<Either<Failure, Unit>> setBookListFiltersCollapsed({
    required bool collapsed,
  });

  /// Retrieves the book list sort dropdown collapsed setting
  Future<Either<Failure, bool>> getBookListSortDropdownCollapsed();

  /// Saves the book list sort dropdown collapsed setting
  Future<Either<Failure, Unit>> setBookListSortDropdownCollapsed({
    required bool collapsed,
  });

  /// Retrieves the book list tag filter dropdown collapsed setting
  Future<Either<Failure, bool>> getBookListTagFilterDropdownCollapsed();

  /// Saves the book list tag filter dropdown collapsed setting
  Future<Either<Failure, Unit>> setBookListTagFilterDropdownCollapsed({
    required bool collapsed,
  });

  /// Retrieves the author list sort dropdown collapsed setting
  Future<Either<Failure, bool>> getAuthorListSortDropdownCollapsed();

  /// Saves the author list sort dropdown collapsed setting
  Future<Either<Failure, Unit>> setAuthorListSortDropdownCollapsed({
    required bool collapsed,
  });
}
