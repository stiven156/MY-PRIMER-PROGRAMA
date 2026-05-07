import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/core/models/member_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class MembersState {
  final List<MemberModel> members;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final MemberStatus? filterStatus;

  const MembersState({
    this.members = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterStatus,
  });

  MembersState copyWith({
    List<MemberModel>? members,
    bool? isLoading,
    String? error,
    String? searchQuery,
    MemberStatus? filterStatus,
    bool clearError = false,
    bool clearFilterStatus = false,
  }) {
    return MembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus:
          clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data — 15 realistic members
// ---------------------------------------------------------------------------

final _now = DateTime.now();

List<MemberModel> _buildMockMembers() => [
      MemberModel(
        id: 'mem_001',
        userId: 'user_member_001',
        gymId: 'gym_mock_001',
        name: 'Juan López',
        email: 'juan.lopez@email.com',
        phone: '+1 555-1001',
        photoUrl: 'https://i.pravatar.cc/150?img=12',
        status: MemberStatus.active,
        planId: 'plan_premium',
        planName: 'Premium',
        memberSince: DateTime(_now.year - 1, 3, 10),
        membershipExpiry: _now.add(const Duration(days: 45)),
        totalCheckIns: 87,
        lastCheckIn: _now.subtract(const Duration(days: 1)),
        weight: 78.5,
        height: 175.0,
        age: 29,
        gender: 'Male',
        emergencyContact: 'Ana López',
        emergencyPhone: '+1 555-1002',
      ),
      MemberModel(
        id: 'mem_002',
        userId: 'user_002',
        gymId: 'gym_mock_001',
        name: 'Sofía Martínez',
        email: 'sofia.martinez@email.com',
        phone: '+1 555-1003',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        status: MemberStatus.active,
        planId: 'plan_basic',
        planName: 'Básico',
        memberSince: DateTime(_now.year, 1, 5),
        membershipExpiry: _now.add(const Duration(days: 20)),
        totalCheckIns: 32,
        lastCheckIn: _now.subtract(const Duration(days: 2)),
        weight: 60.0,
        height: 162.0,
        age: 25,
        gender: 'Female',
        emergencyContact: 'Pedro Martínez',
        emergencyPhone: '+1 555-1004',
      ),
      MemberModel(
        id: 'mem_003',
        userId: 'user_003',
        gymId: 'gym_mock_001',
        name: 'Andrés Pérez',
        email: 'andres.perez@email.com',
        phone: '+1 555-1005',
        photoUrl: 'https://i.pravatar.cc/150?img=5',
        status: MemberStatus.active,
        planId: 'plan_premium',
        planName: 'Premium',
        memberSince: DateTime(_now.year - 2, 6, 15),
        membershipExpiry: _now.add(const Duration(days: 90)),
        totalCheckIns: 215,
        lastCheckIn: _now,
        weight: 90.0,
        height: 182.0,
        age: 34,
        gender: 'Male',
        emergencyContact: 'Laura Pérez',
        emergencyPhone: '+1 555-1006',
      ),
      MemberModel(
        id: 'mem_004',
        userId: 'user_004',
        gymId: 'gym_mock_001',
        name: 'Valentina Torres',
        email: 'valentina.torres@email.com',
        phone: '+1 555-1007',
        photoUrl: 'https://i.pravatar.cc/150?img=45',
        status: MemberStatus.expired,
        planId: 'plan_basic',
        planName: 'Básico',
        memberSince: DateTime(_now.year - 1, 10, 1),
        membershipExpiry: _now.subtract(const Duration(days: 15)),
        totalCheckIns: 45,
        lastCheckIn: _now.subtract(const Duration(days: 20)),
        weight: 55.0,
        height: 158.0,
        age: 22,
        gender: 'Female',
      ),
      MemberModel(
        id: 'mem_005',
        userId: 'user_005',
        gymId: 'gym_mock_001',
        name: 'Diego Ramírez',
        email: 'diego.ramirez@email.com',
        phone: '+1 555-1009',
        photoUrl: 'https://i.pravatar.cc/150?img=8',
        status: MemberStatus.active,
        planId: 'plan_vip',
        planName: 'VIP',
        memberSince: DateTime(_now.year - 3, 2, 20),
        membershipExpiry: _now.add(const Duration(days: 180)),
        totalCheckIns: 512,
        lastCheckIn: _now,
        weight: 85.0,
        height: 178.0,
        age: 38,
        gender: 'Male',
        emergencyContact: 'Carmen Ramírez',
        emergencyPhone: '+1 555-1010',
        medicalNotes: 'Hipertensión leve, monitorear intensidad.',
      ),
      MemberModel(
        id: 'mem_006',
        userId: 'user_006',
        gymId: 'gym_mock_001',
        name: 'Camila Flores',
        email: 'camila.flores@email.com',
        phone: '+1 555-1011',
        photoUrl: 'https://i.pravatar.cc/150?img=41',
        status: MemberStatus.inactive,
        planId: 'plan_basic',
        planName: 'Básico',
        memberSince: DateTime(_now.year, 2, 14),
        membershipExpiry: _now.add(const Duration(days: 30)),
        totalCheckIns: 8,
        lastCheckIn: _now.subtract(const Duration(days: 30)),
        weight: 63.0,
        height: 165.0,
        age: 27,
        gender: 'Female',
      ),
      MemberModel(
        id: 'mem_007',
        userId: 'user_007',
        gymId: 'gym_mock_001',
        name: 'Rodrigo Sánchez',
        email: 'rodrigo.sanchez@email.com',
        phone: '+1 555-1013',
        photoUrl: 'https://i.pravatar.cc/150?img=15',
        status: MemberStatus.active,
        planId: 'plan_premium',
        planName: 'Premium',
        memberSince: DateTime(_now.year - 1, 8, 3),
        membershipExpiry: _now.add(const Duration(days: 60)),
        totalCheckIns: 130,
        lastCheckIn: _now.subtract(const Duration(days: 3)),
        weight: 95.0,
        height: 185.0,
        age: 31,
        gender: 'Male',
      ),
      MemberModel(
        id: 'mem_008',
        userId: 'user_008',
        gymId: 'gym_mock_001',
        name: 'Isabella Gómez',
        email: 'isabella.gomez@email.com',
        phone: '+1 555-1015',
        photoUrl: 'https://i.pravatar.cc/150?img=44',
        status: MemberStatus.active,
        planId: 'plan_vip',
        planName: 'VIP',
        memberSince: DateTime(_now.year - 2, 11, 25),
        membershipExpiry: _now.add(const Duration(days: 120)),
        totalCheckIns: 298,
        lastCheckIn: _now.subtract(const Duration(days: 1)),
        weight: 58.0,
        height: 168.0,
        age: 26,
        gender: 'Female',
        emergencyContact: 'Manuel Gómez',
        emergencyPhone: '+1 555-1016',
      ),
      MemberModel(
        id: 'mem_009',
        userId: 'user_009',
        gymId: 'gym_mock_001',
        name: 'Alejandro Vargas',
        email: 'alejandro.vargas@email.com',
        phone: '+1 555-1017',
        photoUrl: 'https://i.pravatar.cc/150?img=6',
        status: MemberStatus.suspended,
        planId: 'plan_premium',
        planName: 'Premium',
        memberSince: DateTime(_now.year - 1, 5, 12),
        membershipExpiry: _now.add(const Duration(days: 10)),
        totalCheckIns: 67,
        lastCheckIn: _now.subtract(const Duration(days: 14)),
        weight: 82.0,
        height: 176.0,
        age: 33,
        gender: 'Male',
        medicalNotes: 'Cuenta suspendida por falta de pago.',
      ),
      MemberModel(
        id: 'mem_010',
        userId: 'user_010',
        gymId: 'gym_mock_001',
        name: 'Natalia Cruz',
        email: 'natalia.cruz@email.com',
        phone: '+1 555-1019',
        photoUrl: 'https://i.pravatar.cc/150?img=48',
        status: MemberStatus.active,
        planId: 'plan_basic',
        planName: 'Básico',
        memberSince: DateTime(_now.year, 3, 1),
        membershipExpiry: _now.add(const Duration(days: 55)),
        totalCheckIns: 22,
        lastCheckIn: _now.subtract(const Duration(days: 4)),
        weight: 66.0,
        height: 170.0,
        age: 24,
        gender: 'Female',
      ),
      MemberModel(
        id: 'mem_011',
        userId: 'user_011',
        gymId: 'gym_mock_001',
        name: 'Felipe Morales',
        email: 'felipe.morales@email.com',
        phone: '+1 555-1021',
        photoUrl: 'https://i.pravatar.cc/150?img=18',
        status: MemberStatus.active,
        planId: 'plan_vip',
        planName: 'VIP',
        memberSince: DateTime(_now.year - 4, 9, 8),
        membershipExpiry: _now.add(const Duration(days: 200)),
        totalCheckIns: 742,
        lastCheckIn: _now,
        weight: 88.0,
        height: 180.0,
        age: 42,
        gender: 'Male',
        emergencyContact: 'Rosa Morales',
        emergencyPhone: '+1 555-1022',
      ),
      MemberModel(
        id: 'mem_012',
        userId: 'user_012',
        gymId: 'gym_mock_001',
        name: 'Gabriela Herrera',
        email: 'gabriela.herrera@email.com',
        phone: '+1 555-1023',
        photoUrl: 'https://i.pravatar.cc/150?img=43',
        status: MemberStatus.expired,
        planId: 'plan_basic',
        planName: 'Básico',
        memberSince: DateTime(_now.year - 1, 1, 20),
        membershipExpiry: _now.subtract(const Duration(days: 5)),
        totalCheckIns: 56,
        lastCheckIn: _now.subtract(const Duration(days: 10)),
        weight: 72.0,
        height: 172.0,
        age: 30,
        gender: 'Female',
      ),
      MemberModel(
        id: 'mem_013',
        userId: 'user_013',
        gymId: 'gym_mock_001',
        name: 'Sebastián Castro',
        email: 'sebastian.castro@email.com',
        phone: '+1 555-1025',
        photoUrl: 'https://i.pravatar.cc/150?img=21',
        status: MemberStatus.active,
        planId: 'plan_premium',
        planName: 'Premium',
        memberSince: DateTime(_now.year - 1, 12, 10),
        membershipExpiry: _now.add(const Duration(days: 75)),
        totalCheckIns: 98,
        lastCheckIn: _now.subtract(const Duration(days: 2)),
        weight: 76.0,
        height: 173.0,
        age: 28,
        gender: 'Male',
      ),
      MemberModel(
        id: 'mem_014',
        userId: 'user_014',
        gymId: 'gym_mock_001',
        name: 'Daniela Ortiz',
        email: 'daniela.ortiz@email.com',
        phone: '+1 555-1027',
        photoUrl: 'https://i.pravatar.cc/150?img=49',
        status: MemberStatus.active,
        planId: 'plan_vip',
        planName: 'VIP',
        memberSince: DateTime(_now.year - 2, 7, 4),
        membershipExpiry: _now.add(const Duration(days: 150)),
        totalCheckIns: 385,
        lastCheckIn: _now,
        weight: 54.0,
        height: 160.0,
        age: 23,
        gender: 'Female',
        emergencyContact: 'Lucia Ortiz',
        emergencyPhone: '+1 555-1028',
      ),
      MemberModel(
        id: 'mem_015',
        userId: 'user_015',
        gymId: 'gym_mock_001',
        name: 'Mateo Jiménez',
        email: 'mateo.jimenez@email.com',
        phone: '+1 555-1029',
        photoUrl: 'https://i.pravatar.cc/150?img=25',
        status: MemberStatus.inactive,
        planId: 'plan_basic',
        planName: 'Básico',
        memberSince: DateTime(_now.year, 1, 15),
        membershipExpiry: _now.add(const Duration(days: 40)),
        totalCheckIns: 5,
        lastCheckIn: _now.subtract(const Duration(days: 45)),
        weight: 100.0,
        height: 185.0,
        age: 19,
        gender: 'Male',
        medicalNotes: 'Principiante, requiere supervisión adicional.',
      ),
    ];

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MembersNotifier extends StateNotifier<MembersState> {
  MembersNotifier() : super(MembersState(members: _buildMockMembers()));

  /// Simulates loading members for a given gym from the backend.
  Future<void> loadMembers(String gymId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 600));
    final gymMembers =
        state.members.where((m) => m.gymId == gymId).toList();
    state = state.copyWith(
      isLoading: false,
      members: gymMembers.isNotEmpty ? gymMembers : state.members,
      clearError: true,
    );
  }

  /// Adds a new member to the list.
  Future<void> addMember(MemberModel member) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(
      isLoading: false,
      members: [...state.members, member],
      clearError: true,
    );
  }

  /// Updates an existing member.
  Future<void> updateMember(MemberModel updated) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final members =
        state.members.map((m) => m.id == updated.id ? updated : m).toList();
    state = state.copyWith(
        isLoading: false, members: members, clearError: true);
  }

  /// Removes a member from the list.
  Future<void> deleteMember(String memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final members =
        state.members.where((m) => m.id != memberId).toList();
    state = state.copyWith(
        isLoading: false, members: members, clearError: true);
  }

  /// Records a check-in for the specified member.
  Future<void> checkInMember(String memberId) async {
    final member = state.members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) return;
    final updated = member.copyWith(
      totalCheckIns: member.totalCheckIns + 1,
      lastCheckIn: DateTime.now(),
    );
    await updateMember(updated);
  }

  /// Updates the search query used for filtering.
  void searchMembers(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Sets or clears the status filter.
  void filterByStatus(MemberStatus? status) {
    if (status == null) {
      state = state.copyWith(clearFilterStatus: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
  }

  /// Renews a member's membership by adding [days] to today's date.
  Future<void> renewMembership(
      String memberId, String planId, int days) async {
    final member = state.members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) return;
    final newExpiry = DateTime.now().add(Duration(days: days));
    final updated = member.copyWith(
      planId: planId,
      status: MemberStatus.active,
      membershipExpiry: newExpiry,
    );
    await updateMember(updated);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final membersProvider = StateNotifierProvider<MembersNotifier, MembersState>(
  (ref) => MembersNotifier(),
);

/// Applies active search query and status filter to the full members list.
final filteredMembersProvider = Provider<List<MemberModel>>((ref) {
  final state = ref.watch(membersProvider);
  var result = state.members;

  if (state.searchQuery.isNotEmpty) {
    final q = state.searchQuery.toLowerCase();
    result = result
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.email.toLowerCase().contains(q) ||
            (m.phone?.contains(q) ?? false))
        .toList();
  }

  if (state.filterStatus != null) {
    result =
        result.where((m) => m.status == state.filterStatus).toList();
  }

  return result;
});
