import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

enum EmployeeRole {
  manager,
  cashier,
  stocker,
  deliveryPerson,
  supervisor,
}

extension EmployeeRoleExtension on EmployeeRole {
  String get label {
    switch (this) {
      case EmployeeRole.manager:
        return 'Gerente';
      case EmployeeRole.cashier:
        return 'Cajero/a';
      case EmployeeRole.stocker:
        return 'Almacenero/a';
      case EmployeeRole.deliveryPerson:
        return 'Repartidor/a';
      case EmployeeRole.supervisor:
        return 'Supervisor/a';
    }
  }

  String get value {
    switch (this) {
      case EmployeeRole.manager:
        return 'manager';
      case EmployeeRole.cashier:
        return 'cashier';
      case EmployeeRole.stocker:
        return 'stocker';
      case EmployeeRole.deliveryPerson:
        return 'deliveryPerson';
      case EmployeeRole.supervisor:
        return 'supervisor';
    }
  }

  static EmployeeRole fromString(String value) {
    switch (value) {
      case 'manager':
        return EmployeeRole.manager;
      case 'cashier':
        return EmployeeRole.cashier;
      case 'stocker':
        return EmployeeRole.stocker;
      case 'deliveryPerson':
        return EmployeeRole.deliveryPerson;
      case 'supervisor':
        return EmployeeRole.supervisor;
      default:
        throw ArgumentError('Unknown EmployeeRole: $value');
    }
  }
}

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final EmployeeRole role;
  final String phone;
  final String email;
  final DateTime hireDate;
  final bool isActive;
  final String? notes;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phone,
    required this.email,
    required this.hireDate,
    required this.isActive,
    this.notes,
  });

  String get fullName => '$firstName $lastName';

  /// Returns the two uppercase initials of the employee (e.g. "JP").
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    EmployeeRole? role,
    String? phone,
    String? email,
    DateTime? hireDate,
    bool? isActive,
    String? notes,
    bool clearNotes = false,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role &&
        other.phone == phone &&
        other.email == email &&
        other.hireDate == hireDate &&
        other.isActive == isActive &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(
        id,
        firstName,
        lastName,
        role,
        phone,
        email,
        hireDate,
        isActive,
        notes,
      );

  @override
  String toString() =>
      'Employee(id: $id, name: $fullName, role: ${role.value}, isActive: $isActive)';
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class EmployeesState {
  final List<Employee> employees;
  final bool isLoading;
  final String? error;

  const EmployeesState({
    this.employees = const [],
    this.isLoading = false,
    this.error,
  });

  EmployeesState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

List<Employee> _sampleEmployees() {
  return [
    Employee(
      id: 'emp-001',
      firstName: 'Carlos',
      lastName: 'Mendoza',
      role: EmployeeRole.manager,
      phone: '+51 987 654 321',
      email: 'c.mendoza@mercados.pe',
      hireDate: DateTime(2021, 3, 15),
      isActive: true,
      notes: 'Gerente general, turno completo.',
    ),
    Employee(
      id: 'emp-002',
      firstName: 'Lucía',
      lastName: 'Ramos',
      role: EmployeeRole.cashier,
      phone: '+51 912 345 678',
      email: 'l.ramos@mercados.pe',
      hireDate: DateTime(2022, 7, 1),
      isActive: true,
      notes: 'Turno mañana, caja principal.',
    ),
    Employee(
      id: 'emp-003',
      firstName: 'Jorge',
      lastName: 'Palacios',
      role: EmployeeRole.stocker,
      phone: '+51 934 567 890',
      email: 'j.palacios@mercados.pe',
      hireDate: DateTime(2023, 1, 20),
      isActive: true,
    ),
    Employee(
      id: 'emp-004',
      firstName: 'Ana',
      lastName: 'Torres',
      role: EmployeeRole.deliveryPerson,
      phone: '+51 956 789 012',
      email: 'a.torres@mercados.pe',
      hireDate: DateTime(2023, 6, 5),
      isActive: true,
      notes: 'Zona norte de la ciudad.',
    ),
    Employee(
      id: 'emp-005',
      firstName: 'Miguel',
      lastName: 'Flores',
      role: EmployeeRole.supervisor,
      phone: '+51 978 901 234',
      email: 'm.flores@mercados.pe',
      hireDate: DateTime(2022, 11, 10),
      isActive: false,
      notes: 'Licencia temporal.',
    ),
  ];
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class EmployeesNotifier extends StateNotifier<EmployeesState> {
  final _uuid = const Uuid();

  EmployeesNotifier() : super(const EmployeesState());

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true, clearError: true);
    // Simulate async fetch.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      employees: _sampleEmployees(),
      isLoading: false,
    );
  }

  Future<void> addEmployee({
    required String firstName,
    required String lastName,
    required EmployeeRole role,
    required String phone,
    required String email,
    required DateTime hireDate,
    String? notes,
  }) async {
    final employee = Employee(
      id: _uuid.v4(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      role: role,
      phone: phone.trim(),
      email: email.trim(),
      hireDate: hireDate,
      isActive: true,
      notes: notes?.trim(),
    );
    state = state.copyWith(
      employees: [...state.employees, employee],
    );
  }

  Future<void> updateEmployee(Employee updated) async {
    final idx = state.employees.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    final list = [...state.employees];
    list[idx] = updated;
    state = state.copyWith(employees: list);
  }

  Future<void> toggleActive(String id) async {
    final idx = state.employees.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final list = [...state.employees];
    list[idx] = list[idx].copyWith(isActive: !list[idx].isActive);
    state = state.copyWith(employees: list);
  }

  // ── Convenience getters ────────────────────────────────────────────────────

  List<Employee> get activeEmployees =>
      state.employees.where((e) => e.isActive).toList();

  List<Employee> get deliveryPersonnel => state.employees
      .where((e) => e.role == EmployeeRole.deliveryPerson && e.isActive)
      .toList();

  List<Employee> byRole(EmployeeRole role) =>
      state.employees.where((e) => e.role == role).toList();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final employeesProvider =
    StateNotifierProvider<EmployeesNotifier, EmployeesState>((ref) {
  final notifier = EmployeesNotifier();
  notifier.loadEmployees();
  return notifier;
});
