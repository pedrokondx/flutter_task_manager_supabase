import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

class FakeUserEntity extends Fake implements UserEntity {}

class FakeAuthException extends Fake implements AuthException {}
