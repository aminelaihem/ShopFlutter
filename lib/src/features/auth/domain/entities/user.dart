// lib/src/features/auth/domain/entities/user.dart
class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  const UserEntity({required this.id, this.email, this.displayName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserEntity &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email &&
              displayName == other.displayName;

  @override
  int get hashCode => Object.hash(id, email, displayName);
}
