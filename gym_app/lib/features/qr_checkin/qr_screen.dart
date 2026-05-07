import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/models/user_model.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});
  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _scanning = false;
  String? _lastScanned;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.role == UserRole.gymAdmin || user?.role == UserRole.trainer || user?.role == UserRole.superAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Check-in QR', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: isAdmin ? TabBar(controller: _tabCtrl,
            tabs: const [Tab(text: 'Mi QR'), Tab(text: 'Escanear')]) : null,
      ),
      body: isAdmin
          ? TabBarView(controller: _tabCtrl, children: [
              _MyQrTab(user: user),
              _ScannerTab(onScanned: _handleScan, lastScanned: _lastScanned),
            ])
          : _MyQrTab(user: user),
    );
  }

  void _handleScan(String memberId) async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 800));
    ref.read(membersProvider.notifier).checkInMember(memberId);
    setState(() { _scanning = false; _lastScanned = memberId; });
  }
}

class _MyQrTab extends ConsumerWidget {
  final UserModel? user;
  const _MyQrTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user == null) return const SizedBox();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Column(children: [
              // Avatar
              CircleAvatar(radius: 36, backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(user!.name.isNotEmpty ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 28))),
              const Gap(12),
              Text(user!.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
              const Gap(4),
              const Text('Plan Pro · Activo', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
              const Gap(20),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: user!.id,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              ),
              const Gap(16),
              Text(user!.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace'),
                  textAlign: TextAlign.center),
              const Gap(20),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Descargar'),
                )),
                const Gap(12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Compartir'),
                )),
              ]),
            ]),
          ),
          const Gap(24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              const Row(children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                Gap(8),
                Text('Cómo usar tu QR', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              ]),
              const Gap(8),
              const Text('Muestra este código en la recepción para registrar tu asistencia. Tu QR es personal e intransferible.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ScannerTab extends ConsumerWidget {
  final void Function(String) onScanned;
  final String? lastScanned;
  const _ScannerTab({required this.onScanned, required this.lastScanned});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider).members;
    final recentCheckIns = members.where((m) => m.lastCheckIn != null)
        .toList()..sort((a, b) => b.lastCheckIn!.compareTo(a.lastCheckIn!));

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Scanner area (mock)
      Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
        ),
        child: Stack(alignment: Alignment.center, children: [
          // Corner decorations
          ...[ Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight]
              .map((a) => Align(alignment: a, child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: a == Alignment.topLeft || a == Alignment.topRight ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
                    bottom: a == Alignment.bottomLeft || a == Alignment.bottomRight ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
                    left: a == Alignment.topLeft || a == Alignment.bottomLeft ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
                    right: a == Alignment.topRight || a == Alignment.bottomRight ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
                  ),
                ),
              ))),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 48),
            const Gap(12),
            const Text('Apunta al QR del miembro', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const Gap(16),
            // Scanning animation line
            Container(height: 2, width: 200, color: AppColors.primary)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -60, end: 60, duration: 1500.ms, curve: Curves.easeInOut),
          ]),
        ]),
      ),
      const Gap(12),

      // Manual entry
      Row(children: [
        Expanded(child: TextField(
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Ingresar ID del miembro manualmente...', prefixIcon: Icon(Icons.person_search)),
          onSubmitted: (v) => v.isNotEmpty ? onScanned(v) : null,
        )),
        const Gap(8),
        ElevatedButton(onPressed: () {}, child: const Text('Check-in')),
      ]),

      const Gap(20),
      const Text('Últimas Asistencias', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      const Gap(12),
      if (recentCheckIns.isEmpty)
        const Center(child: Padding(padding: EdgeInsets.all(20),
            child: Text('Sin asistencias hoy', style: TextStyle(color: AppColors.textMuted))))
      else
        ...recentCheckIns.take(10).map((m) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.success.withOpacity(0.2),
                child: Text(m.name.isNotEmpty ? m.name[0] : 'M',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(m.membershipPlanId, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ])),
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const Gap(4),
            Text(m.lastCheckIn != null
                ? '${m.lastCheckIn!.hour.toString().padLeft(2,'0')}:${m.lastCheckIn!.minute.toString().padLeft(2,'0')}'
                : '--',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        )),
    ]);
  }
}
