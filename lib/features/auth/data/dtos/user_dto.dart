import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserDTO {
  final String id;
  final String email;

  UserDTO({required this.id, required this.email});

  factory UserDTO.fromSupabaseUser(User user) {
    return UserDTO(id: user.id, email: user.email ?? '');
  }

  UserEntity toEntity() {
    return UserEntity(id: id, email: email);
  }
}
