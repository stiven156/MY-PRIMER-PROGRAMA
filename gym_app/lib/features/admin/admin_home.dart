import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/theme/app_colors.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  final Widget child;
  const AdminHomeScreen({super.key, required this.child});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    '/admin/dashboard',
    '/admin/members',
    '/admin/financial',
    '/admin/equipment',
    '/admin/gym-settings',
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => loc.startsWith(t));
    if (idx >= 0 && idx != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _selectedIndex = idx));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          selectedIndex: _selectedIndex.clamp(0, 4),
          indicatorColor: AppColors.primary.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) {
            setState(() => _selectedIndex = i);
            context.go(_tabs[i]);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people),
              label: 'Miembros',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Finanzas',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_gymnastics), selectedIcon: Icon(Icons.sports_gymnastics),
              label: 'Ops',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings),
              label: 'Config',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Acción rápida', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _QuickAction(icon: Icons.person_add, label: 'Miembro', color: AppColors.success,
              onTap: () { Navigator.pop(context); context.push('/members/add'); }),
          _QuickAction(icon: Icons.event_available, label: 'Clase', color: AppColors.accent,
              onTap: () { Navigator.pop(context); context.push('/schedule/add-class'); }),
          _QuickAction(icon: Icons.attach_money, label: 'Pago', color: AppColors.warning,
              onTap: () { Navigator.pop(context); }),
          _QuickAction(icon: Icons.fitness_center, label: 'Equipo', color: AppColors.secondary,
              onTap: () { Navigator.pop(context); }),
        ]),
        const SizedBox(height: 8),
      ])),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(width: 56, height: 56,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Icon(icon, color: color, size: 26)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  );
}
