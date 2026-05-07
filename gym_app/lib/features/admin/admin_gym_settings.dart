import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/gym_provider.dart';
import 'package:gym_app/core/providers/members_provider.dart';
import 'package:gym_app/core/models/membership_plan_model.dart';

class AdminGymSettingsScreen extends ConsumerStatefulWidget {
  const AdminGymSettingsScreen({super.key});
  @override
  ConsumerState<AdminGymSettingsScreen> createState() => _AdminGymSettingsScreenState();
}

class _AdminGymSettingsScreenState extends ConsumerState<AdminGymSettingsScreen> {
  bool _checkinRequired = true;
  bool _autoRenewal = false;
  bool _smsAlerts = true;
  bool _emailAlerts = true;
  bool _maintenanceMode = false;
  int _expiryWarningDays = 7;
  String _currency = 'USD';
  String _timezone = 'America/Bogota';

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(currentGymProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: const Text('Configuración', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
          ),
          SliverToBoxAdapter(
            child: ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
              // Gym profile
              _Section(title: '🏢 Perfil del Gimnasio', children: [
                _NavTile(label: gym?.name ?? 'Mi Gimnasio', subtitle: 'Nombre del gimnasio',
                    icon: Icons.business, onTap: () => _editGymName(context, gym?.name ?? '')),
                _NavTile(label: gym?.address ?? 'Sin dirección', subtitle: 'Dirección',
                    icon: Icons.location_on, onTap: () {}),
                _NavTile(label: gym?.phone ?? 'Sin teléfono', subtitle: 'Teléfono de contacto',
                    icon: Icons.phone, onTap: () {}),
                _NavTile(label: gym?.email ?? 'Sin email', subtitle: 'Email de contacto',
                    icon: Icons.email, onTap: () {}),
                _NavTile(label: 'Cargar logo', subtitle: 'Imagen del gimnasio',
                    icon: Icons.photo_camera, onTap: () {}),
              ]),

              // Membership plans
              _Section(title: '💳 Planes de Membresía', children: [
                Consumer(builder: (_, ref, __) {
                  final plans = ref.watch(membersProvider).members
                      .map((m) => m.membershipPlanId)
                      .toSet().length;
                  return _NavTile(label: 'Gestionar Planes', subtitle: 'Planes activos configurados',
                      icon: Icons.card_membership, trailing: Text('$plans planes', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      onTap: () => _showPlansSheet(context));
                }),
              ]),

              // Operations
              _Section(title: '⚙️ Operaciones', children: [
                _SwitchTile(label: 'Requiere check-in', sub: 'Los miembros deben hacer check-in al entrar',
                    value: _checkinRequired, onChanged: (v) => setState(() => _checkinRequired = v)),
                _SwitchTile(label: 'Renovación automática', sub: 'Renovar membresías automáticamente',
                    value: _autoRenewal, onChanged: (v) => setState(() => _autoRenewal = v)),
                _TileWithValue(label: 'Días de alerta vencimiento', value: '$_expiryWarningDays días',
                    icon: Icons.notifications_active, onTap: () => _pickExpiryDays(context)),
                _TileWithValue(label: 'Moneda', value: _currency,
                    icon: Icons.attach_money, onTap: () => _pickCurrency(context)),
                _TileWithValue(label: 'Zona horaria', value: _timezone,
                    icon: Icons.schedule, onTap: () {}),
              ]),

              // Notifications
              _Section(title: '🔔 Notificaciones', children: [
                _SwitchTile(label: 'Alertas por SMS', sub: 'Enviar recordatorios por SMS a miembros',
                    value: _smsAlerts, onChanged: (v) => setState(() => _smsAlerts = v)),
                _SwitchTile(label: 'Alertas por Email', sub: 'Enviar emails de renovación y avisos',
                    value: _emailAlerts, onChanged: (v) => setState(() => _emailAlerts = v)),
                _NavTile(label: 'Personalizar mensajes', subtitle: 'Templates de notificación',
                    icon: Icons.message, onTap: () {}),
              ]),

              // Hours
              _Section(title: '🕐 Horarios del Gimnasio', children: [
                ...['Lunes-Viernes', 'Sábado', 'Domingo'].map((day) => _NavTile(
                  label: day, subtitle: day == 'Domingo' ? '9:00 - 17:00' : (day == 'Sábado' ? '8:00 - 20:00' : '6:00 - 22:00'),
                  icon: Icons.schedule, onTap: () {},
                )),
                _NavTile(label: 'Festivos', subtitle: 'Horario especial en días festivos',
                    icon: Icons.celebration, onTap: () {}),
              ]),

              // Access control
              _Section(title: '🔒 Control de Acceso', children: [
                _NavTile(label: 'Dispositivos QR', subtitle: 'Gestionar lectores de acceso',
                    icon: Icons.qr_code_scanner, onTap: () {}),
                _NavTile(label: 'Zonas del gimnasio', subtitle: 'Áreas restringidas por plan',
                    icon: Icons.map, onTap: () {}),
                _NavTile(label: 'Límite de aforo', subtitle: 'Máximo de personas simultáneas',
                    icon: Icons.group, onTap: () {}),
              ]),

              // Integrations
              _Section(title: '🔗 Integraciones', children: [
                _IntegrationTile(label: 'WhatsApp Business', icon: Icons.chat, connected: false, onTap: () {}),
                _IntegrationTile(label: 'Stripe / Pagos', icon: Icons.credit_card, connected: true, onTap: () {}),
                _IntegrationTile(label: 'Google Calendar', icon: Icons.calendar_month, connected: false, onTap: () {}),
                _IntegrationTile(label: 'Mailchimp', icon: Icons.email, connected: false, onTap: () {}),
              ]),

              // Backup / data
              _Section(title: '💾 Datos y Respaldos', children: [
                _NavTile(label: 'Exportar datos', subtitle: 'CSV de miembros, pagos, asistencias',
                    icon: Icons.download, onTap: () {}),
                _NavTile(label: 'Importar miembros', subtitle: 'Importar desde CSV o Excel',
                    icon: Icons.upload, onTap: () {}),
                _NavTile(label: 'Respaldo automático', subtitle: 'Diario a las 3:00 AM',
                    icon: Icons.backup, onTap: () {}),
              ]),

              // Danger
              _Section(title: '⚠️ Zona Peligrosa', isDanger: true, children: [
                _SwitchTile(label: 'Modo mantenimiento', sub: 'Bloquea acceso de miembros a la app',
                    value: _maintenanceMode, onChanged: (v) => _confirmMaintenance(context, v), isRed: true),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.error),
                  title: const Text('Resetear todos los datos', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  onTap: () => _confirmReset(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('Eliminar gimnasio', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  onTap: () {},
                ),
              ]),
              const Gap(40),
            ]),
          ),
        ],
      ),
    );
  }

  void _editGymName(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Nombre del Gimnasio', style: TextStyle(color: AppColors.textPrimary)),
      content: TextField(controller: ctrl, style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nombre', labelStyle: TextStyle(color: AppColors.textMuted))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('Guardar')),
      ],
    ));
  }

  void _showPlansSheet(BuildContext context) {
    final plans = [
      ('Básico', 30.0, '1 mes', AppColors.textSecondary),
      ('Estándar', 50.0, '1 mes', AppColors.success),
      ('Pro', 120.0, '3 meses', AppColors.primary),
      ('Elite', 400.0, '12 meses', AppColors.warning),
    ];

    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(expand: false, initialChildSize: 0.65, maxChildSize: 0.9,
        builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
          const Text('Planes de Membresía', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
          const Gap(16),
          ...plans.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.$4.withOpacity(0.3))),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: p.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.card_membership, color: p.$4, size: 20)),
              const Gap(12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.$1, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(p.$3, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ])),
              Text('\$${p.$2.toStringAsFixed(0)}', style: TextStyle(color: p.$4, fontWeight: FontWeight.w800, fontSize: 16)),
              const Gap(8),
              IconButton(icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 18), onPressed: () {}),
            ]),
          )),
          const Gap(16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nuevo Plan', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ])),
    );
  }

  void _pickExpiryDays(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Días de alerta', style: TextStyle(color: AppColors.textPrimary)),
      content: StatefulBuilder(builder: (_, ss) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text('$_expiryWarningDays días', style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w800)),
        Slider(value: _expiryWarningDays.toDouble(), min: 1, max: 30, divisions: 29,
            activeColor: AppColors.primary, inactiveColor: AppColors.border,
            onChanged: (v) { setState(() => _expiryWarningDays = v.toInt()); ss(() {}); }),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
      ],
    ));
  }

  void _pickCurrency(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Moneda', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: ['USD', 'EUR', 'COP', 'MXN', 'ARS', 'BRL']
          .map((c) => RadioListTile<String>(value: c, groupValue: _currency,
              title: Text(c, style: const TextStyle(color: AppColors.textPrimary)),
              activeColor: AppColors.primary,
              onChanged: (v) { setState(() => _currency = v!); Navigator.pop(context); })).toList()),
    ));
  }

  void _confirmMaintenance(BuildContext context, bool v) {
    if (!v) { setState(() => _maintenanceMode = false); return; }
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('¿Activar modo mantenimiento?', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Los miembros no podrán acceder a la app hasta que lo desactives.', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () { setState(() => _maintenanceMode = true); Navigator.pop(context); },
            child: const Text('Activar', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }

  void _confirmReset(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('⚠️ ¿Resetear datos?', style: TextStyle(color: AppColors.error)),
      content: const Text('Esta acción eliminará TODOS los datos del gimnasio y no se puede deshacer.', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Resetear', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final String title; final List<Widget> children; final bool isDanger;
  const _Section({required this.title, required this.children, this.isDanger = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: TextStyle(color: isDanger ? AppColors.error : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13))),
    Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDanger ? AppColors.error.withOpacity(0.2) : AppColors.border)),
      child: Column(children: children.asMap().entries.map((e) => Column(children: [
        e.value,
        if (e.key < children.length - 1) const Divider(indent: 16, endIndent: 16, height: 1, color: AppColors.border),
      ])).toList()),
    ),
  ]);
}

class _NavTile extends StatelessWidget {
  final String label; final String? subtitle; final IconData icon;
  final Widget? trailing; final VoidCallback onTap;
  const _NavTile({required this.label, this.subtitle, required this.icon, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(icon, color: AppColors.textSecondary, size: 20),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
    subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)) : null,
    trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
    onTap: onTap,
  );
}

class _SwitchTile extends StatelessWidget {
  final String label; final String? sub; final bool value;
  final void Function(bool) onChanged; final bool isRed;
  const _SwitchTile({required this.label, this.sub, required this.value, required this.onChanged, this.isRed = false});
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    title: Text(label, style: TextStyle(color: isRed ? AppColors.error : AppColors.textPrimary, fontSize: 14)),
    subtitle: sub != null ? Text(sub!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)) : null,
    value: value, onChanged: onChanged,
    activeColor: isRed ? AppColors.error : AppColors.primary,
  );
}

class _TileWithValue extends StatelessWidget {
  final String label, value; final IconData icon; final VoidCallback onTap;
  const _TileWithValue({required this.label, required this.value, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(icon, color: AppColors.textSecondary, size: 20),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const Gap(4),
      const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
    ]),
    onTap: onTap,
  );
}

class _IntegrationTile extends StatelessWidget {
  final String label; final IconData icon; final bool connected; final VoidCallback onTap;
  const _IntegrationTile({required this.label, required this.icon, required this.connected, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(icon, color: connected ? AppColors.success : AppColors.textSecondary, size: 20),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
    trailing: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: connected ? AppColors.success.withOpacity(0.1) : AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(connected ? 'Conectado' : 'Conectar',
          style: TextStyle(color: connected ? AppColors.success : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
    ),
    onTap: onTap,
  );
}
