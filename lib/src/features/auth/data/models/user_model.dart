// lib/src/features/auth/data/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String? email;
  final String? displayName;

  const UserModel({required this.id, this.email, this.displayName});

  factory UserModel.fromFirebaseUser(User u) => UserModel(
    id: u.uid,
    email: u.email,
    displayName: u.displayName,
  );

  UserEntity toEntity() => UserEntity(id: id, email: email, displayName: displayName);
}
