/// User model for Localicious
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  /// Create a UserModel from a Firebase User and additional data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'],
    );
  }

  /// Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy of this UserModel with modified fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
