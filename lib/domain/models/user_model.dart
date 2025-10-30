import 'package:collection/collection.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final List<String> roleIds;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.roleIds,
  });

  /// Factory estándar: construye desde Firestore (Map) + uid del doc
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    final rawRoles = (data['roleIds'] as List?) ?? const [];
    final roles = rawRoles.map((e) => e.toString()).toList();

    return UserModel(
      uid: uid,
      email: (data['email'] ?? '').toString(),
      displayName: (data['displayName'] ?? '').toString(),
      roleIds: roles,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'roleIds': roleIds,
      };

  bool get isAdmin => roleIds.contains('admin');
  bool get isOperador => roleIds.contains('operador');
  bool get isCliente => roleIds.contains('cliente');

  @override
  String toString() =>
      'UserModel(uid=$uid, email=$email, displayName=$displayName, roleIds=$roleIds)';

  @override
  bool operator ==(Object other) =>
      other is UserModel &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      const ListEquality().equals(other.roleIds, roleIds);

  @override
  int get hashCode =>
      Object.hash(uid, email, displayName, const ListEquality().hash(roleIds));
}
