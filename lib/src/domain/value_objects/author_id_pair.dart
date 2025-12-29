import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';

import 'author_id_type.dart';

/// Represents an identifier pair for an author.
class AuthorIdPair with EquatableMixin implements IdPair {
  /// The type of the identifier.
  @override
  final AuthorIdType idType;

  /// The code of the identifier.
  @override
  final String idCode;

  /// Creates an AuthorIdPair instance.
  /// Creates an AuthorIdPair instance.
  const AuthorIdPair({required this.idType, required this.idCode});

  /// Checks if the identifier is valid.
  @override
  bool get isValid {
    switch (idType) {
      case AuthorIdType.isni:
        return _isValidISNI(idCode);
      case AuthorIdType.orcid:
        return _isValidORCID(idCode);
      case AuthorIdType.viaf:
        return _isValidVIAF(idCode);
      case AuthorIdType.local:
        return true;
    }
  }

  bool _isValidISNI(String code) {
    return RegExp(r'^\d{16}$').hasMatch(code);
  }

  bool _isValidORCID(String code) {
    return RegExp(r'^\d{4}-\d{4}-\d{4}-\d{4}$').hasMatch(code);
  }

  bool _isValidVIAF(String code) {
    return RegExp(r'^\d+$').hasMatch(code);
  }

  /// The display name of the identifier type.
  @override
  String get displayName => idType.displayName;

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return AuthorIdPair(
      idType: (idType as AuthorIdType?) ?? this.idType,
      idCode: idCode ?? this.idCode,
    );
  }

  @override
  List<Object?> get props => [idType, idCode];
}
