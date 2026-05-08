import 'package:mercados/features/auth/models/user_model.dart';

class Employee {
  final String id;
  final String name;
  final String phone;
  final String email;

  /// The role this employee holds — shared with [UserRole] so that an
  /// employee's permissions are consistent with their auth account.
  final UserRole role;

  /// Monthly or agreed salary in the store's base currency.
  final double salary;

  /// Date the employee was hired.
  final DateTime hireDate;

  final bool isActive;

  /// Optional reference to an auth [UserModel] account.
  /// Null when the employee has no system login (e.g. warehouse staff).
  final String? userId;

  const Employee({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.salary,
    required this.hireDate,
    required this.isActive,
    this.userId,
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Pass [clearUserId] = true to explicitly null out [userId].
  Employee copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    double? salary,
    DateTime? hireDate,
    bool? isActive,
    String? userId,
    bool clearUserId = false,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      salary: salary ?? this.salary,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
      userId: clearUserId ? null : (userId ?? this.userId),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.value,
      'salary': salary,
      'hireDate': hireDate.toIso8601String(),
      'isActive': isActive,
      'userId': userId,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      role: UserRoleExtension.fromString(json['role'] as String),
      salary: (json['salary'] as num).toDouble(),
      hireDate: DateTime.parse(json['hireDate'] as String),
      isActive: json['isActive'] as bool,
      userId: json['userId'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.email == email &&
        other.role == role &&
        other.salary == salary &&
        other.hireDate == hireDate &&
        other.isActive == isActive &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      name,
      phone,
      email,
      role,
      salary,
      hireDate,
      isActive,
      userId,
    ]);
  }

  @override
  String toString() {
    return 'Employee(id: $id, name: $name, role: ${role.value}, '
        'salary: $salary, isActive: $isActive, userId: $userId)';
  }
}
