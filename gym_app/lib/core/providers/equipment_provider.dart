import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum EquipmentStatus {
  operational,
  maintenance,
  outOfService,
  retired;

  String get displayName {
    switch (this) {
      case EquipmentStatus.operational:
        return 'Operativo';
      case EquipmentStatus.maintenance:
        return 'En Mantenimiento';
      case EquipmentStatus.outOfService:
        return 'Fuera de Servicio';
      case EquipmentStatus.retired:
        return 'Retirado';
    }
  }
}

@immutable
class EquipmentItem {
  final String id;
  final String gymId;
  final String name;
  final String category;
  final String brand;
  final String? model;
  final String? serialNumber;
  final DateTime purchaseDate;
  final double? purchasePrice;
  final EquipmentStatus status;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? maintenanceNotes;
  final String? imageUrl;
  final int quantity;

  const EquipmentItem({
    required this.id,
    required this.gymId,
    required this.name,
    required this.category,
    required this.brand,
    this.model,
    this.serialNumber,
    required this.purchaseDate,
    this.purchasePrice,
    this.status = EquipmentStatus.operational,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceNotes,
    this.imageUrl,
    this.quantity = 1,
  });

  bool get isMaintenanceDue {
    if (nextMaintenanceDate == null) return false;
    return nextMaintenanceDate!.isBefore(
      DateTime.now().add(const Duration(days: 7)),
    );
  }

  EquipmentItem copyWith({
    String? id,
    String? gymId,
    String? name,
    String? category,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? purchaseDate,
    double? purchasePrice,
    EquipmentStatus? status,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? maintenanceNotes,
    String? imageUrl,
    int? quantity,
  }) {
    return EquipmentItem(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      status: status ?? this.status,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceNotes: maintenanceNotes ?? this.maintenanceNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class EquipmentState {
  final List<EquipmentItem> equipment;
  final bool isLoading;
  final String? error;
  final String? filterCategory;

  const EquipmentState({
    this.equipment = const [],
    this.isLoading = false,
    this.error,
    this.filterCategory,
  });

  EquipmentState copyWith({
    List<EquipmentItem>? equipment,
    bool? isLoading,
    String? error,
    String? filterCategory,
    bool clearError = false,
    bool clearFilterCategory = false,
  }) {
    return EquipmentState(
      equipment: equipment ?? this.equipment,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterCategory:
          clearFilterCategory ? null : (filterCategory ?? this.filterCategory),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data — 25 equipment items
// ---------------------------------------------------------------------------

List<EquipmentItem> _buildMockEquipment() {
  final gymId = 'gym_mock_001';
  final now = DateTime.now();

  return [
    // Cardio machines
    EquipmentItem(
      id: 'eq_001', gymId: gymId, name: 'Cinta de Correr Pro',
      category: 'Cardio', brand: 'Life Fitness', model: 'F3',
      purchaseDate: DateTime(2022, 3, 15), purchasePrice: 3500,
      status: EquipmentStatus.operational, quantity: 6,
      lastMaintenanceDate: now.subtract(const Duration(days: 30)),
      nextMaintenanceDate: now.add(const Duration(days: 60)),
    ),
    EquipmentItem(
      id: 'eq_002', gymId: gymId, name: 'Bicicleta Estática',
      category: 'Cardio', brand: 'Technogym', model: 'Bike',
      purchaseDate: DateTime(2022, 3, 15), purchasePrice: 2800,
      status: EquipmentStatus.operational, quantity: 8,
      lastMaintenanceDate: now.subtract(const Duration(days: 45)),
      nextMaintenanceDate: now.add(const Duration(days: 45)),
    ),
    EquipmentItem(
      id: 'eq_003', gymId: gymId, name: 'Elíptica',
      category: 'Cardio', brand: 'Matrix', model: 'E50',
      purchaseDate: DateTime(2021, 8, 10), purchasePrice: 3200,
      status: EquipmentStatus.operational, quantity: 4,
      lastMaintenanceDate: now.subtract(const Duration(days: 20)),
      nextMaintenanceDate: now.add(const Duration(days: 70)),
    ),
    EquipmentItem(
      id: 'eq_004', gymId: gymId, name: 'Remo Ergómetro',
      category: 'Cardio', brand: 'Concept2', model: 'RowErg',
      purchaseDate: DateTime(2023, 1, 20), purchasePrice: 1200,
      status: EquipmentStatus.operational, quantity: 3,
      lastMaintenanceDate: now.subtract(const Duration(days: 60)),
      nextMaintenanceDate: now.add(const Duration(days: 5)),
      maintenanceNotes: 'Revisión de cadena y pantalla.',
    ),
    EquipmentItem(
      id: 'eq_005', gymId: gymId, name: 'Bicicleta Spinning',
      category: 'Cardio', brand: 'Keiser', model: 'M3i',
      purchaseDate: DateTime(2022, 6, 1), purchasePrice: 1800,
      status: EquipmentStatus.maintenance, quantity: 20,
      lastMaintenanceDate: now.subtract(const Duration(days: 3)),
      nextMaintenanceDate: now.add(const Duration(days: 90)),
      maintenanceNotes: 'Mantenimiento rutinario de pedales.',
    ),

    // Free weights
    EquipmentItem(
      id: 'eq_006', gymId: gymId, name: 'Set de Mancuernas (2-50 kg)',
      category: 'Pesas Libres', brand: 'Ivanko', model: 'Premium Hex',
      purchaseDate: DateTime(2021, 1, 5), purchasePrice: 8000,
      status: EquipmentStatus.operational, quantity: 1,
      lastMaintenanceDate: now.subtract(const Duration(days: 90)),
      nextMaintenanceDate: now.add(const Duration(days: 275)),
    ),
    EquipmentItem(
      id: 'eq_007', gymId: gymId, name: 'Barra Olímpica 20 kg',
      category: 'Pesas Libres', brand: 'Eleiko', model: 'Sport',
      purchaseDate: DateTime(2021, 1, 5), purchasePrice: 600,
      status: EquipmentStatus.operational, quantity: 10,
      lastMaintenanceDate: now.subtract(const Duration(days: 180)),
      nextMaintenanceDate: now.add(const Duration(days: 185)),
    ),
    EquipmentItem(
      id: 'eq_008', gymId: gymId, name: 'Disco de Peso (5-25 kg)',
      category: 'Pesas Libres', brand: 'Eleiko',
      purchaseDate: DateTime(2021, 1, 5), purchasePrice: 2500,
      status: EquipmentStatus.operational, quantity: 1,
    ),
    EquipmentItem(
      id: 'eq_009', gymId: gymId, name: 'Kettlebells (8-48 kg)',
      category: 'Pesas Libres', brand: 'Rogue',
      purchaseDate: DateTime(2022, 5, 10), purchasePrice: 3000,
      status: EquipmentStatus.operational, quantity: 1,
    ),
    EquipmentItem(
      id: 'eq_010', gymId: gymId, name: 'Barra EZ Curl',
      category: 'Pesas Libres', brand: 'York', model: 'EZ',
      purchaseDate: DateTime(2021, 3, 15), purchasePrice: 300,
      status: EquipmentStatus.operational, quantity: 5,
    ),

    // Strength machines
    EquipmentItem(
      id: 'eq_011', gymId: gymId, name: 'Rack de Sentadillas',
      category: 'Máquinas de Fuerza', brand: 'Rogue', model: 'Monster Lite',
      purchaseDate: DateTime(2021, 1, 5), purchasePrice: 4500,
      status: EquipmentStatus.operational, quantity: 4,
      lastMaintenanceDate: now.subtract(const Duration(days: 120)),
      nextMaintenanceDate: now.add(const Duration(days: 245)),
    ),
    EquipmentItem(
      id: 'eq_012', gymId: gymId, name: 'Banco Ajustable',
      category: 'Máquinas de Fuerza', brand: 'Body-Solid', model: 'GFID71',
      purchaseDate: DateTime(2021, 2, 20), purchasePrice: 400,
      status: EquipmentStatus.operational, quantity: 8,
    ),
    EquipmentItem(
      id: 'eq_013', gymId: gymId, name: 'Prensa de Piernas',
      category: 'Máquinas de Fuerza', brand: 'Technogym', model: 'Leg Press',
      purchaseDate: DateTime(2022, 4, 12), purchasePrice: 6000,
      status: EquipmentStatus.operational, quantity: 2,
      lastMaintenanceDate: now.subtract(const Duration(days: 60)),
      nextMaintenanceDate: now.add(const Duration(days: 3)),
      maintenanceNotes: 'Lubricación de guías y revisión de cables.',
    ),
    EquipmentItem(
      id: 'eq_014', gymId: gymId, name: 'Máquina de Jalones',
      category: 'Máquinas de Fuerza', brand: 'Life Fitness', model: 'Signature',
      purchaseDate: DateTime(2022, 4, 12), purchasePrice: 5500,
      status: EquipmentStatus.operational, quantity: 3,
      lastMaintenanceDate: now.subtract(const Duration(days: 45)),
      nextMaintenanceDate: now.add(const Duration(days: 45)),
    ),
    EquipmentItem(
      id: 'eq_015', gymId: gymId, name: 'Máquina de Extensión de Cuádriceps',
      category: 'Máquinas de Fuerza', brand: 'Cybex', model: 'Eagle',
      purchaseDate: DateTime(2021, 6, 30), purchasePrice: 4200,
      status: EquipmentStatus.outOfService, quantity: 1,
      lastMaintenanceDate: now.subtract(const Duration(days: 10)),
      maintenanceNotes: 'Esperando repuesto del selector de peso.',
    ),
    EquipmentItem(
      id: 'eq_016', gymId: gymId, name: 'Cable Crossover',
      category: 'Máquinas de Fuerza', brand: 'Precor', model: 'DSL0714',
      purchaseDate: DateTime(2022, 1, 15), purchasePrice: 7000,
      status: EquipmentStatus.operational, quantity: 2,
      lastMaintenanceDate: now.subtract(const Duration(days: 30)),
      nextMaintenanceDate: now.add(const Duration(days: 60)),
    ),

    // Functional area
    EquipmentItem(
      id: 'eq_017', gymId: gymId, name: 'Plataforma de Salto (Box)',
      category: 'Funcional', brand: 'Rogue', model: 'Wood Box',
      purchaseDate: DateTime(2022, 8, 5), purchasePrice: 800,
      status: EquipmentStatus.operational, quantity: 6,
    ),
    EquipmentItem(
      id: 'eq_018', gymId: gymId, name: 'Battle Ropes',
      category: 'Funcional', brand: 'Rogue', model: '1.5" x 50ft',
      purchaseDate: DateTime(2022, 8, 5), purchasePrice: 300,
      status: EquipmentStatus.operational, quantity: 4,
    ),
    EquipmentItem(
      id: 'eq_019', gymId: gymId, name: 'TRX Suspension Trainer',
      category: 'Funcional', brand: 'TRX', model: 'PRO4',
      purchaseDate: DateTime(2023, 2, 10), purchasePrice: 250,
      status: EquipmentStatus.operational, quantity: 8,
      lastMaintenanceDate: now.subtract(const Duration(days: 90)),
      nextMaintenanceDate: now.add(const Duration(days: 275)),
    ),
    EquipmentItem(
      id: 'eq_020', gymId: gymId, name: 'Balón Medicinal (3-10 kg)',
      category: 'Funcional', brand: 'Dynamax',
      purchaseDate: DateTime(2022, 3, 20), purchasePrice: 600,
      status: EquipmentStatus.operational, quantity: 1,
    ),
    EquipmentItem(
      id: 'eq_021', gymId: gymId, name: 'Saco de Boxeo',
      category: 'Boxeo', brand: 'Everlast', model: 'MMA',
      purchaseDate: DateTime(2023, 4, 1), purchasePrice: 400,
      status: EquipmentStatus.operational, quantity: 6,
      location: 'Sala de Boxeo',
    ),

    // Studio equipment
    EquipmentItem(
      id: 'eq_022', gymId: gymId, name: 'Colchoneta Yoga',
      category: 'Studio', brand: 'Manduka', model: 'PRO',
      purchaseDate: DateTime(2022, 9, 15), purchasePrice: 50,
      status: EquipmentStatus.operational, quantity: 25,
    ),
    EquipmentItem(
      id: 'eq_023', gymId: gymId, name: 'Foam Roller',
      category: 'Recuperación', brand: 'TriggerPoint', model: 'GRID',
      purchaseDate: DateTime(2023, 1, 10), purchasePrice: 35,
      status: EquipmentStatus.operational, quantity: 15,
    ),
    EquipmentItem(
      id: 'eq_024', gymId: gymId, name: 'Banda de Resistencia Set',
      category: 'Accesorios', brand: 'Perform Better',
      purchaseDate: DateTime(2023, 3, 5), purchasePrice: 80,
      status: EquipmentStatus.operational, quantity: 10,
    ),
    EquipmentItem(
      id: 'eq_025', gymId: gymId, name: 'Sistema de Sonido Sala Principal',
      category: 'Infraestructura', brand: 'JBL', model: 'PRX900',
      purchaseDate: DateTime(2021, 1, 15), purchasePrice: 4000,
      status: EquipmentStatus.operational, quantity: 1,
      lastMaintenanceDate: now.subtract(const Duration(days: 180)),
      nextMaintenanceDate: now.add(const Duration(days: 2)),
      maintenanceNotes: 'Revisión anual de amplificadores.',
    ),
  ];
}

extension on EquipmentItem {
  // Extra field not in the immutable model — used for display only.
  String? get location => null;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class EquipmentNotifier extends StateNotifier<EquipmentState> {
  EquipmentNotifier()
      : super(EquipmentState(equipment: _buildMockEquipment()));

  /// Simulates loading equipment for a gym.
  Future<void> loadEquipment(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false, clearError: true);
  }

  /// Adds a new equipment item.
  Future<void> addEquipment(EquipmentItem item) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      isLoading: false,
      equipment: [...state.equipment, item],
    );
  }

  /// Replaces an existing item.
  Future<void> updateEquipment(EquipmentItem updated) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final equipment = state.equipment
        .map((e) => e.id == updated.id ? updated : e)
        .toList();
    state = state.copyWith(isLoading: false, equipment: equipment);
  }

  /// Removes an item by id.
  Future<void> deleteEquipment(String id) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final equipment = state.equipment.where((e) => e.id != id).toList();
    state = state.copyWith(isLoading: false, equipment: equipment);
  }

  /// Schedules the next maintenance date for an item.
  Future<void> scheduleMaintenance(String id, DateTime date) async {
    final item = state.equipment.where((e) => e.id == id).firstOrNull;
    if (item == null) return;
    final updated = item.copyWith(nextMaintenanceDate: date);
    await updateEquipment(updated);
  }

  /// Records a completed maintenance, clearing the scheduled date.
  Future<void> markMaintenanceComplete(String id) async {
    final item = state.equipment.where((e) => e.id == id).firstOrNull;
    if (item == null) return;
    final updated = item.copyWith(
      status: EquipmentStatus.operational,
      lastMaintenanceDate: DateTime.now(),
      nextMaintenanceDate:
          DateTime.now().add(const Duration(days: 90)),
    );
    await updateEquipment(updated);
  }

  /// Sets or clears the active category filter.
  void filterByCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearFilterCategory: true);
    } else {
      state = state.copyWith(filterCategory: category);
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final equipmentProvider =
    StateNotifierProvider<EquipmentNotifier, EquipmentState>(
  (ref) => EquipmentNotifier(),
);

/// Returns equipment items whose next maintenance is within 7 days.
final maintenanceDueProvider = Provider<List<EquipmentItem>>((ref) {
  return ref
      .watch(equipmentProvider)
      .equipment
      .where((e) => e.isMaintenanceDue)
      .toList()
    ..sort((a, b) {
      final aDate = a.nextMaintenanceDate ?? DateTime(9999);
      final bDate = b.nextMaintenanceDate ?? DateTime(9999);
      return aDate.compareTo(bDate);
    });
});

/// Returns equipment grouped by category, respecting the active filter.
final equipmentByCategoryProvider =
    Provider<Map<String, List<EquipmentItem>>>((ref) {
  final state = ref.watch(equipmentProvider);
  final items = state.filterCategory != null
      ? state.equipment
          .where((e) => e.category == state.filterCategory)
          .toList()
      : state.equipment;

  final map = <String, List<EquipmentItem>>{};
  for (final item in items) {
    map.putIfAbsent(item.category, () => []).add(item);
  }
  return map;
});
