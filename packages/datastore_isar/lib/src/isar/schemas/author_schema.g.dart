// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAuthorSchemaCollection on Isar {
  IsarCollection<AuthorSchema> get authorSchemas => this.collection();
}

const AuthorSchemaSchema = CollectionSchema(
  name: r'AuthorSchema',
  id: -8275186733838068354,
  properties: {
    r'dataJson': PropertySchema(
      id: 0,
      name: r'dataJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'stringId': PropertySchema(
      id: 2,
      name: r'stringId',
      type: IsarType.string,
    )
  },
  estimateSize: _authorSchemaEstimateSize,
  serialize: _authorSchemaSerialize,
  deserialize: _authorSchemaDeserialize,
  deserializeProp: _authorSchemaDeserializeProp,
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
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _authorSchemaGetId,
  getLinks: _authorSchemaGetLinks,
  attach: _authorSchemaAttach,
  version: '3.1.0+1',
);

int _authorSchemaEstimateSize(
  AuthorSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dataJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.stringId.length * 3;
  return bytesCount;
}

void _authorSchemaSerialize(
  AuthorSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dataJson);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.stringId);
}

AuthorSchema _authorSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuthorSchema();
  object.dataJson = reader.readString(offsets[0]);
  object.name = reader.readString(offsets[1]);
  object.stringId = reader.readString(offsets[2]);
  return object;
}

P _authorSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _authorSchemaGetId(AuthorSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _authorSchemaGetLinks(AuthorSchema object) {
  return [];
}

void _authorSchemaAttach(
    IsarCollection<dynamic> col, Id id, AuthorSchema object) {}

extension AuthorSchemaByIndex on IsarCollection<AuthorSchema> {
  Future<AuthorSchema?> getByStringId(String stringId) {
    return getByIndex(r'stringId', [stringId]);
  }

  AuthorSchema? getByStringIdSync(String stringId) {
    return getByIndexSync(r'stringId', [stringId]);
  }

  Future<bool> deleteByStringId(String stringId) {
    return deleteByIndex(r'stringId', [stringId]);
  }

  bool deleteByStringIdSync(String stringId) {
    return deleteByIndexSync(r'stringId', [stringId]);
  }

  Future<List<AuthorSchema?>> getAllByStringId(List<String> stringIdValues) {
    final values = stringIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'stringId', values);
  }

  List<AuthorSchema?> getAllByStringIdSync(List<String> stringIdValues) {
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

  Future<Id> putByStringId(AuthorSchema object) {
    return putByIndex(r'stringId', object);
  }

  Id putByStringIdSync(AuthorSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'stringId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStringId(List<AuthorSchema> objects) {
    return putAllByIndex(r'stringId', objects);
  }

  List<Id> putAllByStringIdSync(List<AuthorSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'stringId', objects, saveLinks: saveLinks);
  }
}

extension AuthorSchemaQueryWhereSort
    on QueryBuilder<AuthorSchema, AuthorSchema, QWhere> {
  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AuthorSchemaQueryWhere
    on QueryBuilder<AuthorSchema, AuthorSchema, QWhereClause> {
  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> stringIdEqualTo(
      String stringId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'stringId',
        value: [stringId],
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause>
      stringIdNotEqualTo(String stringId) {
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AuthorSchemaQueryFilter
    on QueryBuilder<AuthorSchema, AuthorSchema, QFilterCondition> {
  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonEqualTo(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonLessThan(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonBetween(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonEndsWith(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      dataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdEqualTo(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdLessThan(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdBetween(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdEndsWith(
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

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stringId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stringId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringId',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterFilterCondition>
      stringIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stringId',
        value: '',
      ));
    });
  }
}

extension AuthorSchemaQueryObject
    on QueryBuilder<AuthorSchema, AuthorSchema, QFilterCondition> {}

extension AuthorSchemaQueryLinks
    on QueryBuilder<AuthorSchema, AuthorSchema, QFilterCondition> {}

extension AuthorSchemaQuerySortBy
    on QueryBuilder<AuthorSchema, AuthorSchema, QSortBy> {
  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> sortByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> sortByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> sortByStringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> sortByStringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.desc);
    });
  }
}

extension AuthorSchemaQuerySortThenBy
    on QueryBuilder<AuthorSchema, AuthorSchema, QSortThenBy> {
  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataJson', Sort.desc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByStringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.asc);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QAfterSortBy> thenByStringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringId', Sort.desc);
    });
  }
}

extension AuthorSchemaQueryWhereDistinct
    on QueryBuilder<AuthorSchema, AuthorSchema, QDistinct> {
  QueryBuilder<AuthorSchema, AuthorSchema, QDistinct> distinctByDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthorSchema, AuthorSchema, QDistinct> distinctByStringId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringId', caseSensitive: caseSensitive);
    });
  }
}

extension AuthorSchemaQueryProperty
    on QueryBuilder<AuthorSchema, AuthorSchema, QQueryProperty> {
  QueryBuilder<AuthorSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AuthorSchema, String, QQueryOperations> dataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataJson');
    });
  }

  QueryBuilder<AuthorSchema, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AuthorSchema, String, QQueryOperations> stringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringId');
    });
  }
}
