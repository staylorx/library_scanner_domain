import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:library_scanner_domain/library_scanner_domain.dart';

/// Implementation of PersistenceService using SharedPreferences
class SharedPreferencesSettingsService implements AbstractSettingsService {
  final SharedPreferences _prefs;

  SharedPreferencesSettingsService(this._prefs);

  @override
  Future<Either<Failure, Unit>> saveString({
    required String key,
    required String value,
  }) async {
    try {
      await _prefs.setString(key, value);
      return right(unit);
    } catch (e) {
      return left(ServiceFailure('Failed to save string: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getString({required String key}) async {
    try {
      final value = _prefs.getString(key);
      return right(value);
    } catch (e) {
      return left(ServiceFailure('Failed to get string: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> remove({required String key}) async {
    try {
      await _prefs.remove(key);
      return right(unit);
    } catch (e) {
      return left(ServiceFailure('Failed to remove key: $e'));
    }
  }

  @override
  Future<Either<Failure, TagColorMode>> getTagColorMode() async {
    try {
      final value = _prefs.getString('tag_color_mode');
      if (value != null) {
        final mode = TagColorMode.values.firstWhere(
          (e) => e.name == value,
          orElse: () => TagColorMode.normal,
        );
        return right(mode);
      } else {
        return right(TagColorMode.normal);
      }
    } catch (e) {
      return left(ServiceFailure('Failed to get tag color mode: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setTagColorMode({
    required TagColorMode mode,
  }) async {
    try {
      await _prefs.setString('tag_color_mode', mode.name);
      return right(unit);
    } catch (e) {
      return left(ServiceFailure('Failed to set tag color mode: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getFetchCoverArt() async {
    try {
      final value = _prefs.getBool('fetch_cover_art');
      return right(value ?? true); // Default to true
    } catch (e) {
      return left(ServiceFailure('Failed to get fetch cover art: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setFetchCoverArt({required bool fetch}) async {
    try {
      await _prefs.setBool('fetch_cover_art', fetch);
      return right(unit);
    } catch (e) {
      return left(ServiceFailure('Failed to set fetch cover art: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getTagSelectionInclusive() async {
    try {
      final value = _prefs.getBool('tag_selection_inclusive');
      return right(value ?? false); // Default to false (exclusive)
    } catch (e) {
      return left(ServiceFailure('Failed to get tag selection inclusive: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setTagSelectionInclusive({
    required bool inclusive,
  }) async {
    try {
      await _prefs.setBool('tag_selection_inclusive', inclusive);
      return right(unit);
    } catch (e) {
      return left(ServiceFailure('Failed to set tag selection inclusive: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getBookListFiltersCollapsed() async {
    try {
      final value = _prefs.getBool('book_list_filters_collapsed');
      return right(value ?? false); // Default to false (expanded)
    } catch (e) {
      return left(
        ServiceFailure('Failed to get book list filters collapsed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setBookListFiltersCollapsed({
    required bool collapsed,
  }) async {
    try {
      await _prefs.setBool('book_list_filters_collapsed', collapsed);
      return right(unit);
    } catch (e) {
      return left(
        ServiceFailure('Failed to set book list filters collapsed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> getBookListSortDropdownCollapsed() async {
    try {
      final value = _prefs.getBool('book_list_sort_dropdown_collapsed');
      return right(value ?? false); // Default to false (expanded)
    } catch (e) {
      return left(
        ServiceFailure('Failed to get book list sort dropdown collapsed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setBookListSortDropdownCollapsed({
    required bool collapsed,
  }) async {
    try {
      await _prefs.setBool('book_list_sort_dropdown_collapsed', collapsed);
      return right(unit);
    } catch (e) {
      return left(
        ServiceFailure('Failed to set book list sort dropdown collapsed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> getBookListTagFilterDropdownCollapsed() async {
    try {
      final value = _prefs.getBool('book_list_tag_filter_dropdown_collapsed');
      return right(value ?? false); // Default to false (expanded)
    } catch (e) {
      return left(
        ServiceFailure(
          'Failed to get book list tag filter dropdown collapsed: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setBookListTagFilterDropdownCollapsed({
    required bool collapsed,
  }) async {
    try {
      await _prefs.setBool(
        'book_list_tag_filter_dropdown_collapsed',
        collapsed,
      );
      return right(unit);
    } catch (e) {
      return left(
        ServiceFailure(
          'Failed to set book list tag filter dropdown collapsed: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> getAuthorListSortDropdownCollapsed() async {
    try {
      final value = _prefs.getBool('author_list_sort_dropdown_collapsed');
      return right(value ?? false); // Default to false (expanded)
    } catch (e) {
      return left(
        ServiceFailure('Failed to get author list sort dropdown collapsed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setAuthorListSortDropdownCollapsed({
    required bool collapsed,
  }) async {
    try {
      await _prefs.setBool('author_list_sort_dropdown_collapsed', collapsed);
      return right(unit);
    } catch (e) {
      return left(
        ServiceFailure('Failed to set author list sort dropdown collapsed: $e'),
      );
    }
  }
}
