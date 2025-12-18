import 'package:equatable/equatable.dart';
import 'package:id_pair_set/id_pair_set.dart';

import '../../utils/isbn_utils.dart';

enum BookIdType {
  isbn('ISBN'),
  isbn13('ISBN-13'),
  asin('ASIN'),
  doi('DOI'),
  ean('EAN'),
  local('LOCAL');

  const BookIdType(this.displayName);
  final String displayName;

  String get name => toString().split('.').last;
}

// idPairs are used to represent a combination of an ID type and a business code ID code
// this is not the same thing as our internal database ID of a book
class BookIdPair with EquatableMixin implements IdPair {
  @override
  final BookIdType idType;
  @override
  final String idCode;

  const BookIdPair({required this.idType, required this.idCode});

  // local is anything we come up with ourselves, so always valid
  @override
  bool get isValid {
    switch (idType) {
      case BookIdType.isbn:
        return isValidISBN10(idCode);
      case BookIdType.isbn13:
        return isValidISBN13(idCode);
      case BookIdType.asin:
        return _isValidASIN(idCode);
      case BookIdType.doi:
        return _isValidDOI(idCode);
      case BookIdType.ean:
        return isValidISBN13(idCode);
      case BookIdType.local:
        return true;
    }
  }

  bool _isValidASIN(String code) {
    if (code.length != 10) return false;
    return RegExp(r'^[A-Za-z0-9]{10}$').hasMatch(code);
  }

  bool _isValidDOI(String code) {
    return RegExp(r'^10\.[A-Za-z0-9]+$').hasMatch(code);
  }

  @override
  String get displayName => idType.displayName;

  @override
  IdPair copyWith({dynamic idType, String? idCode}) {
    return BookIdPair(
      idType: (idType as BookIdType?) ?? this.idType,
      idCode: idCode ?? this.idCode,
    );
  }

  @override
  List<Object?> get props => [idType, idCode];
}
