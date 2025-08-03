import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';

class FakeTaskEntity extends Fake implements TaskEntity {}

class FakeTaskException extends Fake implements TaskException {}
