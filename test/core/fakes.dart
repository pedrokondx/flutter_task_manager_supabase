import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';

class FakeCategoryEntity extends Fake implements CategoryEntity {}

class FakeCategoryException extends Fake implements CategoryException {}
