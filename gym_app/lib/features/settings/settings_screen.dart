import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/settings_provider.dart';
import 'package:gym_app/core/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Configuración', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _Section(title: '🎨 Apariencia', children: [
            _TileItem(
              label: 'Tema',
              trailing: SegmentedButton<ThemeMode>(
                selected: {settings.themeMode},
                onSelectionChanged: (s) => ref.read(settingsProvider.notifier).setThemeMode(s.first),
                segments: const [
                  ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro', style: TextStyle(fontSize: 11))),
                  ButtonSegment(value: ThemeMode.light, label: Text('Claro', style: TextStyle(fontSize: 11))),
                  ButtonSegment(value: ThemeMode.system, label: Text('Sistema', style: TextStyle(fontSize: 11))),
                ],
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ),
            _TileItem(
              label: 'Idioma',
              trailing: DropdownButton<String>(
                value: settings.language,
                dropdownColor: AppColors.card,
                underline: const SizedBox(),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: const [
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'pt', child: Text('Português')),
                ],
                onChanged: (v) => ref.read(settingsProvider.notifier).setLanguage(v!),
              ),
            ),
          ]),

          // Units
          _Section(title: '📏 Unidades', children: [
            _SwitchTile(
              label: 'Usar libras (lb)', sub: 'Por defecto: kilogramos',
              value: settings.weightUnit == 'lb',
              onChanged: (v) => ref.read(settingsProvider.notifier).setWeightUnit(v ? 'lb' : 'kg'),
            ),
            _SwitchTile(
              label: 'Usar pies/pulgadas', sub: 'Por defecto: centímetros',
              value: settings.heightUnit == 'ft',
              onChanged: (v) => ref.read(settingsProvider.notifier).setHeightUnit(v ? 'ft' : 'cm'),
            ),
          ]),

          // Notifications
          _Section(title: '🔔 Notificaciones', children: [
            _SwitchTile(
              label: 'Activar notificaciones',
              value: settings.notificationsEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).toggleNotifications(),
            ),
            _SwitchTile(
              label: 'Recordatorios de entreno',
              value: settings.workoutReminders,
              onChanged: settings.notificationsEnabled
                  ? (v) => ref.read(settingsProvider.notifier).toggleWorkoutReminders()
                  : null,
            ),
            _SwitchTile(
              label: 'Recordatorios de clases',
              value: settings.classReminders,
              onChanged: settings.notificationsEnabled
                  ? (v) => ref.read(settingsProvider.notifier).toggleClassReminders()
                  : null,
            ),
            _SwitchTile(
              label: 'Alertas de membresía',
              value: settings.paymentReminders,
              onChanged: settings.notificationsEnabled
                  ? (v) => ref.read(settingsProvider.notifier).togglePaymentReminders()
                  : null,
            ),
          ]),

          // Privacy
          _Section(title: '🔒 Privacidad y Seguridad', children: [
            _NavTile(label: 'Cambiar Contraseña', icon: Icons.lock_outline, onTap: () {}),
            _SwitchTile(label: 'Autenticación biométrica', value: false, onChanged: (_) {}),
            _SwitchTile(label: 'Compartir datos con el gimnasio', value: true, onChanged: (_) {}),
            _NavTile(label: 'Descargar mis datos', icon: Icons.download, onTap: () {}),
          ]),

          // About
          _Section(title: 'ℹ️ Acerca de', children: [
            const _TileItem(label: 'Versión', trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary))),
            _NavTile(label: 'Términos de servicio', icon: Icons.description_outlined, onTap: () {}),
            _NavTile(label: 'Política de privacidad', icon: Icons.privacy_tip_outlined, onTap: () {}),
            _NavTile(label: 'Calificar la app', icon: Icons.star_outline, onTap: () {}),
            _NavTile(label: 'Contactar soporte', icon: Icons.support_agent, onTap: () {}),
          ]),

          // Danger
          _Section(title: '⚠️ Zona Peligrosa', isDanger: true, children: [
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () {
                showDialog(context: context, builder: (_) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: const Text('¿Cerrar sesión?', style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?', style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    TextButton(onPressed: () { ref.read(authProvider.notifier).logout(); Navigator.pop(context); },
                        child: const Text('Salir', style: TextStyle(color: AppColors.error))),
                  ],
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Eliminar cuenta', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () {},
            ),
          ]),
          const Gap(40),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final List<Widget> children; final bool isDanger;
  const _Section({required this.title, required this.children, this.isDanger = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(title, style: TextStyle(color: isDanger ? AppColors.error : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13))),
    Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDanger ? AppColors.error.withOpacity(0.2) : AppColors.border)),
      child: Column(children: children.asMap().entries.map((e) => Column(children: [
        e.value,
        if (e.key < children.length - 1) const Divider(indent: 16, endIndent: 16, height: 1),
      ])).toList()),
    ),
  ]);
}

class _TileItem extends StatelessWidget {
  final String label; final Widget? trailing;
  const _TileItem({required this.label, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
      if (trailing != null) trailing!,
    ]),
  );
}

class _SwitchTile extends StatelessWidget {
  final String label; final String? sub; final bool value; final void Function(bool)? onChanged;
  const _SwitchTile({required this.label, required this.value, required this.onChanged, this.sub});
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
    subtitle: sub != null ? Text(sub!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)) : null,
    value: value, onChanged: onChanged,
    activeColor: AppColors.primary,
  );
}

class _NavTile extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _NavTile({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(icon, color: AppColors.textSecondary, size: 20),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
    onTap: onTap,
  );
}
