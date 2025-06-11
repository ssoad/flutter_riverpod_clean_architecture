import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profilePicture,
        phone,
        createdAt,
        updatedAt,
      ];

  // Factory constructor to create an empty user
  factory UserEntity.empty() {
    return const UserEntity(
      id: '',
      name: '',
      email: '',
    );
  }

  // CopyWith method for creating a new instance with some updated properties
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Method to check if user is empty
  bool get isEmpty => id.isEmpty && name.isEmpty && email.isEmpty;
  bool get isNotEmpty => !isEmpty;
}
