import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mercados/features/customers/models/customer.dart';

class CustomersState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  CustomersState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final _now = DateTime.now();

List<Customer> _buildSampleCustomers() {
  return [
    Customer(
      id: 'cust-001',
      name: 'Ana Ramírez López',
      phone: '+52 999 123 4567',
      email: 'ana.ramirez@email.com',
      address: 'Calle 60 #312, Col. Centro, Mérida',
      points: 1250,
      currentDebt: 0.00,
      creditLimit: 2000.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 540)),
    ),
    Customer(
      id: 'cust-002',
      name: 'Carlos Mendoza Pérez',
      phone: '+52 999 234 5678',
      email: 'cmendoza@gmail.com',
      address: 'Av. Itzaes 234, Fracc. Las Américas, Mérida',
      points: 320,
      currentDebt: 450.00,
      creditLimit: 1000.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 210)),
    ),
    Customer(
      id: 'cust-003',
      name: 'Sofía Hernández Uc',
      phone: '+52 999 345 6789',
      email: 'sofia.h@outlook.com',
      address: 'Calle 21 #456, Col. México, Mérida',
      points: 3680,
      currentDebt: 0.00,
      creditLimit: 5000.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 720)),
    ),
    Customer(
      id: 'cust-004',
      name: 'Miguel Torres Canto',
      phone: '+52 999 456 7890',
      email: 'miguel.torres@yahoo.com',
      address: 'Prolongación Montejo 876, Mérida',
      points: 85,
      currentDebt: 200.00,
      creditLimit: 500.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 60)),
    ),
    Customer(
      id: 'cust-005',
      name: 'Patricia Gómez Sosa',
      phone: '+52 999 567 8901',
      email: 'patty.gomez@email.mx',
      address: 'Calle 47 #789, Col. Pensiones, Mérida',
      points: 960,
      currentDebt: 0.00,
      creditLimit: 1500.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 380)),
    ),
    Customer(
      id: 'cust-006',
      name: 'Roberto Chan Dzul',
      phone: '+52 999 678 9012',
      email: 'roberto.chan@email.com',
      address: 'Fracc. Real Montejo, Calle 14 #23, Mérida',
      points: 2100,
      currentDebt: 750.00,
      creditLimit: 3000.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 600)),
    ),
    Customer(
      id: 'cust-007',
      name: 'Elena Puc Balam',
      phone: '+52 999 789 0123',
      email: '',
      address: 'Calle 82 #100, Col. Francisco de Montejo',
      points: 40,
      currentDebt: 0.00,
      creditLimit: 300.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 30)),
    ),
    Customer(
      id: 'cust-008',
      name: 'José Canul May',
      phone: '+52 999 890 1234',
      email: 'jcanul@hotmail.com',
      address: 'Av. Correa Rachó 56, Mérida',
      points: 150,
      currentDebt: 100.00,
      creditLimit: 800.00,
      isActive: false,
      createdAt: _now.subtract(const Duration(days: 180)),
    ),
    Customer(
      id: 'cust-009',
      name: 'Lucía Uicab Chi',
      phone: '+52 999 901 2345',
      email: 'lucia.uicab@email.com',
      address: 'Calle 68 #420, Col. García Ginerés, Mérida',
      points: 4920,
      currentDebt: 0.00,
      creditLimit: 8000.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 900)),
    ),
    Customer(
      id: 'cust-010',
      name: 'Fernando Xool Tun',
      phone: '+52 999 012 3456',
      email: 'fxool@gmail.com',
      address: 'Av. 20 de Noviembre 345, Mérida',
      points: 560,
      currentDebt: 300.00,
      creditLimit: 1200.00,
      isActive: true,
      createdAt: _now.subtract(const Duration(days: 250)),
    ),
  ];
}

class CustomersNotifier extends StateNotifier<CustomersState> {
  final _uuid = const Uuid();

  CustomersNotifier() : super(const CustomersState()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    state = state.copyWith(customers: _buildSampleCustomers(), isLoading: false);
  }

  void searchCustomers(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> addCustomer(Customer customer) async {
    final newCustomer = customer.copyWith(id: _uuid.v4());
    state = state.copyWith(customers: [...state.customers, newCustomer]);
  }

  Future<void> updateCustomer(Customer customer) async {
    final updated =
        state.customers.map((c) => c.id == customer.id ? customer : c).toList();
    state = state.copyWith(customers: updated);
  }

  Future<void> addPoints(String customerId, int points) async {
    final index = state.customers.indexWhere((c) => c.id == customerId);
    if (index == -1) return;
    final customer = state.customers[index];
    final updated = [...state.customers];
    updated[index] = customer.copyWith(points: customer.points + points);
    state = state.copyWith(customers: updated);
  }

  Future<void> recordDebt(String customerId, double amount) async {
    final index = state.customers.indexWhere((c) => c.id == customerId);
    if (index == -1) return;
    final customer = state.customers[index];
    final updated = [...state.customers];
    updated[index] =
        customer.copyWith(currentDebt: customer.currentDebt + amount);
    state = state.copyWith(customers: updated);
  }

  Future<void> payDebt(String customerId, double amount) async {
    final index = state.customers.indexWhere((c) => c.id == customerId);
    if (index == -1) return;
    final customer = state.customers[index];
    final newDebt =
        (customer.currentDebt - amount).clamp(0.0, double.infinity);
    final updated = [...state.customers];
    updated[index] = customer.copyWith(currentDebt: newDebt);
    state = state.copyWith(customers: updated);
  }

  List<Customer> get filteredCustomers {
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return state.customers;
    return state.customers
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            c.email.toLowerCase().contains(q))
        .toList();
  }

  List<Customer> get customersWithDebt =>
      state.customers.where((c) => c.currentDebt > 0).toList();
}

final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>(
  (ref) => CustomersNotifier(),
);

final filteredCustomersProvider = Provider<List<Customer>>((ref) {
  return ref.watch(customersProvider.notifier).filteredCustomers;
});
