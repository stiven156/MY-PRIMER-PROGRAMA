import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';

import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/models/member_model.dart';
import 'package:gym_app/core/providers/members_provider.dart';

// ---------------------------------------------------------------------------
// Members Screen
// ---------------------------------------------------------------------------

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  MemberStatus? _selectedStatus;
  String _sortBy = 'name';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        ref.read(membersProvider.notifier).searchMembers('');
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _FilterBottomSheet(
        selectedStatus: _selectedStatus,
        sortBy: _sortBy,
        onApply: (status, sortBy) {
          setState(() {
            _selectedStatus = status;
            _sortBy = sortBy;
          });
          ref.read(membersProvider.notifier).filterByStatus(status);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);
    final filteredMembers = ref.watch(filteredMembersProvider);
    final allMembers = membersState.members;
    final isLoading = membersState.isLoading;

    final activeCount =
        allMembers.where((m) => m.status == MemberStatus.active).length;
    final expiredCount =
        allMembers.where((m) => m.status == MemberStatus.expired).length;
    final trialCount =
        allMembers.where((m) => m.status == MemberStatus.trial).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/members/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ).animate().scale(delay: 300.ms, duration: 400.ms),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(allMembers.length),
            // Search bar (animated)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isSearchActive ? _buildSearchBar() : const SizedBox.shrink(),
            ),
            // Stats chips
            _buildStatsChips(
              total: allMembers.length,
              active: activeCount,
              expired: expiredCount,
              trial: trialCount,
            ),
            const Gap(4),
            // Members list
            Expanded(
              child: isLoading
                  ? _buildShimmerList()
                  : filteredMembers.isEmpty
                      ? _buildEmptyState()
                      : _buildMembersList(filteredMembers),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App Bar
  // ---------------------------------------------------------------------------

  Widget _buildAppBar(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: AppColors.surface,
      child: Row(
        children: [
          Text(
            'Miembros',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              '$total',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          // Filter badge
          badges.Badge(
            showBadge: _selectedStatus != null,
            badgeContent: const SizedBox(width: 6, height: 6),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: AppColors.primary,
              padding: EdgeInsets.all(3),
            ),
            child: IconButton(
              onPressed: _openFilterSheet,
              icon: const Icon(Icons.tune_rounded,
                  color: AppColors.textSecondary, size: 22),
            ),
          ),
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchActive ? Icons.close : Icons.search,
              color: _isSearchActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search Bar
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, email o teléfono...',
          hintStyle: GoogleFonts.inter(
              color: AppColors.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search,
              color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          ref.read(membersProvider.notifier).searchMembers(value);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stats Chips
  // ---------------------------------------------------------------------------

  Widget _buildStatsChips({
    required int total,
    required int active,
    required int expired,
    required int trial,
  }) {
    return Container(
      height: 42,
      color: AppColors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: [
          _statChip('Total', total, AppColors.textSecondary, null),
          const Gap(8),
          _statChip('Activos', active, AppColors.success, MemberStatus.active),
          const Gap(8),
          _statChip('Vencidos', expired, AppColors.error, MemberStatus.expired),
          const Gap(8),
          _statChip('Trial', trial, AppColors.warning, MemberStatus.trial),
        ],
      ),
    );
  }

  Widget _statChip(
      String label, int count, Color color, MemberStatus? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
        });
        ref
            .read(membersProvider.notifier)
            .filterByStatus(isSelected ? null : status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const Gap(4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Members List
  // ---------------------------------------------------------------------------

  Widget _buildMembersList(List<MemberModel> members) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, __) => const Gap(8),
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member, index);
      },
    );
  }

  Widget _buildMemberCard(MemberModel member, int index) {
    return Slidable(
      key: ValueKey(member.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) async {
              await ref
                  .read(membersProvider.notifier)
                  .checkInMember(member.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Check-in registrado para ${member.name}'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.check_circle_outline,
            label: 'Check-in',
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) => _confirmDelete(member),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.push('/members/${member.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar with status dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildMemberAvatar(member),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _statusDotColor(member.status),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildExpiryBadge(member),
                        ],
                      ),
                      const Gap(2),
                      Text(
                        member.email,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(6),
                      Row(
                        children: [
                          // Plan badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            child: Text(
                              member.membershipPlanId
                                  .replaceFirst('plan_', '')
                                  .toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const Gap(8),
                          // Check-ins
                          Row(
                            children: [
                              const Icon(Icons.login,
                                  size: 11,
                                  color: AppColors.textMuted),
                              const Gap(3),
                              Text(
                                '${member.totalCheckIns} check-ins',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (member.lastCheckIn != null) ...[
                            const Gap(8),
                            Text(
                              _formatLastCheckIn(member.lastCheckIn!),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                // Arrow
                const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 40 * index))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildMemberAvatar(MemberModel member) {
    final initials = member.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    if (member.photoUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.cardElevated,
        backgroundImage: NetworkImage(member.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: _statusDotColor(member.status).withOpacity(0.2),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _statusDotColor(member.status),
        ),
      ),
    );
  }

  Widget _buildExpiryBadge(MemberModel member) {
    final days = member.daysUntilExpiry;
    Color color;
    String text;

    if (member.status == MemberStatus.expired || days < 0) {
      color = AppColors.error;
      text = 'Vencida';
    } else if (days <= 7) {
      color = AppColors.warning;
      text = 'Vence en $days días';
    } else {
      color = AppColors.success;
      text = '$days días';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusDotColor(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return AppColors.success;
      case MemberStatus.expired:
        return AppColors.error;
      case MemberStatus.frozen:
        return AppColors.accent;
      case MemberStatus.cancelled:
        return AppColors.textMuted;
      case MemberStatus.trial:
        return AppColors.warning;
    }
  }

  String _formatLastCheckIn(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) return 'hoy';
    if (diff.inDays == 1) return 'ayer';
    return 'hace ${diff.inDays}d';
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              color: AppColors.textMuted,
              size: 50,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const Gap(20),
          Text(
            'No hay miembros aún',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const Gap(8),
          Text(
            'Agrega tu primer miembro\npara comenzar a gestionar tu gimnasio',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: () => context.push('/members/add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Agregar Miembro',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer Loading
  // ---------------------------------------------------------------------------

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.cardElevated,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: 8,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (_, __) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delete Confirmation
  // ---------------------------------------------------------------------------

  Future<void> _confirmDelete(MemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Eliminar miembro',
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${member.name}? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: GoogleFonts.inter(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(membersProvider.notifier).deleteMember(member.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Filter Bottom Sheet
// ---------------------------------------------------------------------------

class _FilterBottomSheet extends StatefulWidget {
  final MemberStatus? selectedStatus;
  final String sortBy;
  final void Function(MemberStatus? status, String sortBy) onApply;

  const _FilterBottomSheet({
    required this.selectedStatus,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  MemberStatus? _status;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _sortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(20),
          Text(
            'Filtrar Miembros',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(20),
          Text(
            'ESTADO',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Todos', null),
              _filterChip('Activo', MemberStatus.active),
              _filterChip('Vencido', MemberStatus.expired),
              _filterChip('Congelado', MemberStatus.frozen),
              _filterChip('Cancelado', MemberStatus.cancelled),
              _filterChip('Trial', MemberStatus.trial),
            ],
          ),
          const Gap(20),
          Text(
            'ORDENAR POR',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('Nombre', 'name'),
              _sortChip('Fecha registro', 'created'),
              _sortChip('Vencimiento', 'expiry'),
              _sortChip('Check-ins', 'checkins'),
            ],
          ),
          const Gap(24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_status, _sortBy),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Aplicar Filtros',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, MemberStatus? status) {
    final isSelected = _status == status;
    Color chipColor = AppColors.textSecondary;
    if (status == MemberStatus.active) chipColor = AppColors.success;
    if (status == MemberStatus.expired) chipColor = AppColors.error;
    if (status == MemberStatus.frozen) chipColor = AppColors.accent;
    if (status == MemberStatus.cancelled) chipColor = AppColors.textMuted;
    if (status == MemberStatus.trial) chipColor = AppColors.warning;
    if (status == null) chipColor = AppColors.primary;

    return GestureDetector(
      onTap: () => setState(() => _status = isSelected ? null : status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? chipColor.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? chipColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.secondary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
