enum UserRole { admin, manager, cashier, supervisor, customer }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.manager:
        return 'Gerente';
      case UserRole.cashier:
        return 'Cajero';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.customer:
        return 'Cliente';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.cashier:
        return 'cashier';
      case UserRole.supervisor:
        return 'supervisor';
      case UserRole.customer:
        return 'customer';
    }
  }

  bool get isStaff =>
      this == UserRole.admin ||
      this == UserRole.manager ||
      this == UserRole.cashier ||
      this == UserRole.supervisor;

  bool get isCustomer => this == UserRole.customer;

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'cashier':
        return UserRole.cashier;
      case 'supervisor':
        return UserRole.supervisor;
      case 'customer':
        return UserRole.customer;
      default:
        throw ArgumentError('Unknown UserRole: "$value"');
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  /// Returns a copy with the given fields replaced.
  /// Pass [clearLastLogin] = true to explicitly set [lastLogin] to null.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool clearLastLogin = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: clearLastLogin ? null : (lastLogin ?? this.lastLogin),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRoleExtension.fromString(json['role'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.lastLogin == lastLogin;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, isActive, createdAt, lastLogin);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, '
        'role: ${role.value}, isActive: $isActive, '
        'createdAt: $createdAt, lastLogin: $lastLogin)';
  }
}
