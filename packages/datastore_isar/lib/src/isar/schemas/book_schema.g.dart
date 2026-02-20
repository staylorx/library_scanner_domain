// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookSchemaCollection on Isar {
  IsarCollection<BookSchema> get bookSchemas => this.collection();
}

const BookSchemaSchema = CollectionSchema(
  name: r'BookSchema',
  id: 5585715102345208269,
  properties: {
    r'authorIds': PropertySchema(
      id: 0,
      name: r'authorIds',
      type: IsarType.stringList,
    ),
    r'dataJson': PropertySchema(
      id: 1,
      name: r'dataJson',
      type: IsarType.string,
    ),
    r'stringId': PropertySchema(
      id: 2,
      name: r'stringId',
      type: IsarType.string,
    ),
    r'tagIds': PropertySchema(
      id: 3,
      name: r'tagIds',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _bookSchemaEstimateSize,
  serialize: _bookSchemaSerialize,
  deserialize: _bookSchemaDeserialize,
  deserializeProp: _bookSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'stringId': IndexSchema(
      id: 2631728708659333672,
      name: r'stringId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'stringId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'authorIds': IndexSchema(
      id: -7996935101339351690,
      name: r'authorIds',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'authorIds',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'tagIds': IndexSchema(
      id: 4953378336043540110,
      name: r'tagIds',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tagIds',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bookSchemaGetId,
  getLinks: _bookSchemaGetLinks,
  attach: _bookSchemaAttach,
  version: '3.1.0+1',
);

int _bookSchemaEstimateSize(
  BookSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorIds.length * 3;
  {
    for (var i = 0; i < object.authorIds.length; i++) {
      final value = object.authorIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.dataJson.length * 3;
  bytesCount += 3 + object.stringId.length * 3;
  bytesCount += 3 + object.tagIds.length * 3;
  {
    for (var i = 0; i < object.tagIds.length; i++) {
      final value = object.tagIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _bookSchemaSerialize(
  BookSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.authorIds);
  writer.writeString(offsets[1], object.dataJson);
  writer.writeString(offsets[2], object.stringId);
  writer.writeStringList(offsets[3], object.tagIds);
  writer.writeString(offsets[4], object.title);
}

BookSchema _bookSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BookSchema();
  object.authorIds = reader.readStringList(offsets[0]) ?? [];
  object.dataJson = reader.readString(offsets[1]);
  object.stringId = reader.readString(offsets[2]);
  object.tagIds = reader.readStringList(offsets[3]) ?? [];
  object.title = reader.readString(offsets[4]);
  return object;
}

P _bookSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookSchemaGetId(BookSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookSchemaGetLinks(BookSchema object) {
  return [];
}

void _bookSchemaAttach(IsarCollection<dynamic> col, Id id, BookSchema object) {}

extension BookSchemaByIndex on IsarCollection<BookSchema> {
  Future<BookSchema?> getByStringId(String stringId) {
    return getByIndex(r'stringId', [stringId]);
  }

  BookSchema? getByStringIdSync(String stringId) {
    return getByIndexSync(r'stringId', [stringId]);
  }

  Future<bool> deleteByStringId(String stringId) {
    return deleteByIndex(r'stringId', [stringId]);
  }

  bool deleteByStringIdSync(String stringId) {
    return deleteByIndexSync(r'stringId', [stringId]);
  }

  Future<List<BookSchema?>> getAllByStringId(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringId', values);
  }

  List<BookSchema?> getAllByStringIdSync(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'stringId', values);
  }

  Future<int> deleteAllByStringId(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'stringId', values);
  }

  int deleteAllByStringIdSync(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'stringId', values);
  }

  Future<Id> putByStringId(BookSchema object) {
    return putByIndex(r'stringId', object);
  }

  Id putByStringIdSync(BookSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringId(List<BookSchema> objects) {
    return putAllByIndex(r'stringId', objects);
  }

  List<Id> putAllByStringIdSync(List<BookSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'stringId', objects, saveLinks: saveLinks);
  }
}

extension BookSchemaQueryWhereSort
    on QueryBuilder<BookSchema, BookSchema, QWhere> {
  QueryBuilder<BookSchema, BookSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookSchemaQueryWhere
    on QueryBuilder<BookSchema, BookSchema, QWhereClause> {
  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> stringIdEqualTo(
      String stringId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stringId',
        value: [stringId],
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> stringIdNotEqualTo(
      String stringId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [],
              upper: [stringId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [stringId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [stringId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'stringId',
              lower: [],
              upper: [stringId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> authorIdsEqualTo(
      List<String> authorIds) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'authorIds',
        value: [authorIds],
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> authorIdsNotEqualTo(
      List<String> authorIds) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIds',
              lower: [],
              upper: [authorIds],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIds',
              lower: [authorIds],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIds',
              lower: [authorIds],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'authorIds',
              lower: [],
              upper: [authorIds],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> tagIdsEqualTo(
      List<String> tagIds) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tagIds',
        value: [tagIds],
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterWhereClause> tagIdsNotEqualTo(
      List<String> tagIds) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tagIds',
              lower: [],
              upper: [tagIds],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tagIds',
              lower: [tagIds],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tagIds',
              lower: [tagIds],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tagIds',
              lower: [],
              upper: [tagIds],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BookSchemaQueryFilter
    on QueryBuilder<BookSchema, BookSchema, QFilterCondition> {
  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorIds',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorIds',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'authorIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'authorIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'authorIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'authorIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'authorIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      authorIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'authorIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> dataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      dataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> dataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> dataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      dataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> dataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> dataJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> dataJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> stringIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      stringIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> stringIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> stringIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stringId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      stringIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> stringIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> stringIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> stringIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stringId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      stringIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      stringIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stringId',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tagIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tagIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tagIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tagIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagIds',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tagIds',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> tagIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      tagIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tagIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension BookSchemaQueryObject
    on QueryBuilder<BookSchema, BookSchema, QFilterCondition> {}

extension BookSchemaQueryLinks
    on QueryBuilder<BookSchema, BookSchema, QFilterCondition> {}

extension BookSchemaQuerySortBy
    on QueryBuilder<BookSchema, BookSchema, QSortBy> {
  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByStringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByStringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension BookSchemaQuerySortThenBy
    on QueryBuilder<BookSchema, BookSchema, QSortThenBy> {
  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByStringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByStringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.desc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension BookSchemaQueryWhereDistinct
    on QueryBuilder<BookSchema, BookSchema, QDistinct> {
  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByAuthorIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorIds');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByStringId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByTagIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagIds');
    });
  }

  QueryBuilder<BookSchema, BookSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension BookSchemaQueryProperty
    on QueryBuilder<BookSchema, BookSchema, QQueryProperty> {
  QueryBuilder<BookSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BookSchema, List<String>, QQueryOperations> authorIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorIds');
    });
  }

  QueryBuilder<BookSchema, String, QQueryOperations> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataJson');
    });
  }

  QueryBuilder<BookSchema, String, QQueryOperations> stringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringId');
    });
  }

  QueryBuilder<BookSchema, List<String>, QQueryOperations> tagIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagIds');
    });
  }

  QueryBuilder<BookSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
