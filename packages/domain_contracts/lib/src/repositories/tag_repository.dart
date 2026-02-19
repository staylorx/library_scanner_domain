import 'package:fpdart/fpdart.dart';
import 'package:domain_entities/domain_entities.dart';

import 'basic_crud_contract.dart';

abstract class TagRepository implements BasicCrudContract<Tag> {
  TaskEither<Failure, Tag> getByName({required String name});

  TaskEither<Failure, List<Tag>> getTagsByNames({required List<String> names});
}
