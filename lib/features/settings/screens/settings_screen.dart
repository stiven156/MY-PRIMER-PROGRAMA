import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mercados/core/constants/app_constants.dart';
import 'package:mercados/core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// SettingsScreen
// ---------------------------------------------------------------------------

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loading = true;

  // ── Negocio ──────────────────────────────────────────────────────────────
  final _storeNameCtrl = TextEditingController();
  final _storeAddressCtrl = TextEditingController();
  final _storePhoneCtrl = TextEditingController();
  final _storeRucCtrl = TextEditingController();

  // ── Impresora ─────────────────────────────────────────────────────────────
  final _printerIpCtrl = TextEditingController();
  final _printerPortCtrl = TextEditingController(text: '9100');
  String _paperSize = '80mm';

  // ── Impuestos ─────────────────────────────────────────────────────────────
  final _taxNameCtrl = TextEditingController(text: 'IVA');
  double _taxRate = 16.0;
  final _taxRateCtrl = TextEditingController(text: '16.0');

  // ── Moneda ────────────────────────────────────────────────────────────────
  final _currencySymbolCtrl = TextEditingController(text: r'$');
  int _decimalPlaces = 2;
  String _thousandsSep = ',';

  // ── Supabase ──────────────────────────────────────────────────────────────
  final _supabaseUrlCtrl = TextEditingController();
  final _supabaseKeyCtrl = TextEditingController();
  bool _supabaseKeyObscured = true;
  _ConnectionStatus _connectionStatus = _ConnectionStatus.idle;

  // ── Respaldo ──────────────────────────────────────────────────────────────
  String? _lastBackupDate;

  // ── SharedPrefs keys (extra, beyond AppConstants) ─────────────────────────
  static const _kPrinterIp = 'pref_printer_ip';
  static const _kPrinterPort = 'pref_printer_port';
  static const _kPaperSize = 'pref_paper_size';
  static const _kTaxName = 'pref_tax_name';
  static const _kDecimalPlaces = 'pref_decimal_places';
  static const _kThousandsSep = 'pref_thousands_sep';
  static const _kSupabaseUrl = 'pref_supabase_url';
  static const _kSupabaseKey = 'pref_supabase_key';
  static const _kLastBackup = 'pref_last_backup';
  static const _kRuc = 'pref_store_ruc';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeAddressCtrl.dispose();
    _storePhoneCtrl.dispose();
    _storeRucCtrl.dispose();
    _printerIpCtrl.dispose();
    _printerPortCtrl.dispose();
    _taxNameCtrl.dispose();
    _taxRateCtrl.dispose();
    _currencySymbolCtrl.dispose();
    _supabaseUrlCtrl.dispose();
    _supabaseKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeNameCtrl.text = prefs.getString(AppConstants.prefStoreName) ?? 'MERCADOS';
      _storeAddressCtrl.text = prefs.getString(AppConstants.prefStoreAddress) ?? '';
      _storePhoneCtrl.text = prefs.getString(AppConstants.prefStorePhone) ?? '';
      _storeRucCtrl.text = prefs.getString(_kRuc) ?? '';

      _printerIpCtrl.text = prefs.getString(_kPrinterIp) ?? '';
      _printerPortCtrl.text = prefs.getString(_kPrinterPort) ?? '9100';
      _paperSize = prefs.getString(_kPaperSize) ?? '80mm';

      _taxNameCtrl.text = prefs.getString(_kTaxName) ?? 'IVA';
      final storedRate = prefs.getDouble(AppConstants.prefTaxRate);
      _taxRate = storedRate != null ? storedRate * 100 : 16.0;
      _taxRateCtrl.text = _taxRate.toStringAsFixed(1);

      _currencySymbolCtrl.text =
          prefs.getString(AppConstants.prefCurrencySymbol) ?? r'$';
      _decimalPlaces = prefs.getInt(_kDecimalPlaces) ?? 2;
      _thousandsSep = prefs.getString(_kThousandsSep) ?? ',';

      _supabaseUrlCtrl.text = prefs.getString(_kSupabaseUrl) ?? '';
      _supabaseKeyCtrl.text = prefs.getString(_kSupabaseKey) ?? '';

      _lastBackupDate = prefs.getString(_kLastBackup);
      _loading = false;
    });
  }

  // ── Save helpers ──────────────────────────────────────────────────────────

  Future<void> _saveNegocio() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefStoreName, _storeNameCtrl.text.trim());
    await prefs.setString(AppConstants.prefStoreAddress, _storeAddressCtrl.text.trim());
    await prefs.setString(AppConstants.prefStorePhone, _storePhoneCtrl.text.trim());
    await prefs.setString(_kRuc, _storeRucCtrl.text.trim());
    _showSavedSnack('Negocio guardado');
  }

  Future<void> _savePrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrinterIp, _printerIpCtrl.text.trim());
    await prefs.setString(_kPrinterPort, _printerPortCtrl.text.trim());
    await prefs.setString(_kPaperSize, _paperSize);
    _showSavedSnack('Configuración de impresora guardada');
  }

  Future<void> _saveTax() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTaxName, _taxNameCtrl.text.trim());
    await prefs.setDouble(AppConstants.prefTaxRate, _taxRate / 100);
    _showSavedSnack('Configuración de impuestos guardada');
  }

  Future<void> _saveCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefCurrencySymbol, _currencySymbolCtrl.text.trim());
    await prefs.setInt(_kDecimalPlaces, _decimalPlaces);
    await prefs.setString(_kThousandsSep, _thousandsSep);
    _showSavedSnack('Moneda guardada');
  }

  Future<void> _saveSupabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSupabaseUrl, _supabaseUrlCtrl.text.trim());
    await prefs.setString(_kSupabaseKey, _supabaseKeyCtrl.text.trim());
    _showSavedSnack('Configuración de Supabase guardada');
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _testPrint() async {
    final ip = _printerIpCtrl.text.trim();
    if (ip.isEmpty) {
      _showSavedSnack('Ingresa la IP de la impresora');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviando prueba a $ip:${_printerPortCtrl.text}...'),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() => _connectionStatus = _ConnectionStatus.testing);
    try {
      final url = _supabaseUrlCtrl.text.trim();
      final key = _supabaseKeyCtrl.text.trim();
      if (url.isEmpty || key.isEmpty) {
        setState(() => _connectionStatus = _ConnectionStatus.error);
        return;
      }
      // Quick check: try a lightweight REST call against the health endpoint.
      final client = Supabase.instance.client;
      await client.from('products').select('id').limit(1);
      setState(() => _connectionStatus = _ConnectionStatus.ok);
    } catch (_) {
      setState(() => _connectionStatus = _ConnectionStatus.error);
    }
  }

  Future<void> _exportBackup() async {
    // In production this would serialize data to JSON and share the file.
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}'
        ' ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_kLastBackup, dateStr);
    setState(() => _lastBackupDate = dateStr);
    _showSavedSnack('Respaldo exportado correctamente');
  }

  Future<void> _importBackup() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Importar respaldo'),
        content: const Text(
          'Esta acción reemplazará los datos actuales con los del archivo de respaldo. '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showSavedSnack('Función de importación próximamente');
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _showSavedSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Ayuda',
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _SectionHeader(icon: Icons.store_rounded, label: 'Negocio'),
                _NegocioSection(
                  storeNameCtrl: _storeNameCtrl,
                  addressCtrl: _storeAddressCtrl,
                  phoneCtrl: _storePhoneCtrl,
                  rucCtrl: _storeRucCtrl,
                  onSave: _saveNegocio,
                ),
                const SizedBox(height: 8),

                _SectionHeader(
                    icon: Icons.print_rounded, label: 'Impresora de Tickets'),
                _PrinterSection(
                  ipCtrl: _printerIpCtrl,
                  portCtrl: _printerPortCtrl,
                  paperSize: _paperSize,
                  onPaperSizeChanged: (v) => setState(() => _paperSize = v ?? '80mm'),
                  onSave: _savePrinter,
                  onTestPrint: _testPrint,
                ),
                const SizedBox(height: 8),

                _SectionHeader(
                    icon: Icons.percent_rounded, label: 'Impuestos'),
                _TaxSection(
                  taxNameCtrl: _taxNameCtrl,
                  taxRate: _taxRate,
                  taxRateCtrl: _taxRateCtrl,
                  onRateSliderChanged: (v) {
                    setState(() {
                      _taxRate = v;
                      _taxRateCtrl.text = v.toStringAsFixed(1);
                    });
                  },
                  onRateTextChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null) setState(() => _taxRate = parsed.clamp(0, 100));
                  },
                  onSave: _saveTax,
                ),
                const SizedBox(height: 8),

                _SectionHeader(
                    icon: Icons.attach_money_rounded, label: 'Moneda'),
                _CurrencySection(
                  symbolCtrl: _currencySymbolCtrl,
                  decimalPlaces: _decimalPlaces,
                  thousandsSep: _thousandsSep,
                  onDecimalChanged: (v) => setState(() => _decimalPlaces = v),
                  onThousandsChanged: (v) => setState(() => _thousandsSep = v),
                  onSave: _saveCurrency,
                ),
                const SizedBox(height: 8),

                _SectionHeader(
                    icon: Icons.cloud_rounded, label: 'Supabase'),
                _SupabaseSection(
                  urlCtrl: _supabaseUrlCtrl,
                  keyCtrl: _supabaseKeyCtrl,
                  keyObscured: _supabaseKeyObscured,
                  onToggleObscure: () =>
                      setState(() => _supabaseKeyObscured = !_supabaseKeyObscured),
                  connectionStatus: _connectionStatus,
                  onTest: _testConnection,
                  onSave: _saveSupabase,
                ),
                const SizedBox(height: 8),

                _SectionHeader(
                    icon: Icons.backup_rounded, label: 'Respaldo'),
                _BackupSection(
                  lastBackupDate: _lastBackupDate,
                  onExport: _exportBackup,
                  onImport: _importBackup,
                ),
                const SizedBox(height: 8),

                _SectionHeader(
                    icon: Icons.info_outline_rounded, label: 'Acerca de'),
                _AboutSection(cs: cs),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Negocio section
// ---------------------------------------------------------------------------

class _NegocioSection extends StatelessWidget {
  const _NegocioSection({
    required this.storeNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.rucCtrl,
    required this.onSave,
  });

  final TextEditingController storeNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController rucCtrl;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo placeholder
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00695C).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00695C).withAlpha(51),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      size: 28, color: Color(0xFF00695C)),
                  const SizedBox(height: 4),
                  Text('Logo',
                      style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF00695C).withAlpha(178))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: storeNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del negocio',
              prefixIcon: Icon(Icons.store_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: rucCtrl,
            decoration: const InputDecoration(
              labelText: 'RUC / NIT',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          _SaveButton(onPressed: onSave),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Printer section
// ---------------------------------------------------------------------------

class _PrinterSection extends StatelessWidget {
  const _PrinterSection({
    required this.ipCtrl,
    required this.portCtrl,
    required this.paperSize,
    required this.onPaperSizeChanged,
    required this.onSave,
    required this.onTestPrint,
  });

  final TextEditingController ipCtrl;
  final TextEditingController portCtrl;
  final String paperSize;
  final ValueChanged<String?> onPaperSizeChanged;
  final VoidCallback onSave;
  final VoidCallback onTestPrint;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: ipCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Dirección IP',
                    prefixIcon: Icon(Icons.lan_outlined),
                    hintText: '192.168.1.100',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: portCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Puerto'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: paperSize,
            decoration: const InputDecoration(
              labelText: 'Tamaño de papel',
              prefixIcon: Icon(Icons.receipt_long_outlined),
            ),
            items: const [
              DropdownMenuItem(value: '58mm', child: Text('58 mm')),
              DropdownMenuItem(value: '80mm', child: Text('80 mm')),
            ],
            onChanged: onPaperSizeChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _SaveButton(onPressed: onSave)),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onTestPrint,
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Prueba'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax section
// ---------------------------------------------------------------------------

class _TaxSection extends StatelessWidget {
  const _TaxSection({
    required this.taxNameCtrl,
    required this.taxRate,
    required this.taxRateCtrl,
    required this.onRateSliderChanged,
    required this.onRateTextChanged,
    required this.onSave,
  });

  final TextEditingController taxNameCtrl;
  final double taxRate;
  final TextEditingController taxRateCtrl;
  final ValueChanged<double> onRateSliderChanged;
  final ValueChanged<String> onRateTextChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: taxNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del impuesto',
              prefixIcon: Icon(Icons.label_outline),
              hintText: 'IVA',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasa de impuesto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Slider(
                      value: taxRate.clamp(0, 100),
                      min: 0,
                      max: 30,
                      divisions: 60,
                      label: '${taxRate.toStringAsFixed(1)}%',
                      onChanged: onRateSliderChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextFormField(
                  controller: taxRateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: onRateTextChanged,
                  decoration: const InputDecoration(
                    suffixText: '%',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SaveButton(onPressed: onSave),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Currency section
// ---------------------------------------------------------------------------

class _CurrencySection extends StatelessWidget {
  const _CurrencySection({
    required this.symbolCtrl,
    required this.decimalPlaces,
    required this.thousandsSep,
    required this.onDecimalChanged,
    required this.onThousandsChanged,
    required this.onSave,
  });

  final TextEditingController symbolCtrl;
  final int decimalPlaces;
  final String thousandsSep;
  final ValueChanged<int> onDecimalChanged;
  final ValueChanged<String> onThousandsChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: symbolCtrl,
            decoration: const InputDecoration(
              labelText: 'Símbolo de moneda',
              prefixIcon: Icon(Icons.currency_exchange_rounded),
              hintText: r'$',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decimales',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('0')),
                        ButtonSegment(value: 2, label: Text('2')),
                      ],
                      selected: {decimalPlaces},
                      onSelectionChanged: (s) => onDecimalChanged(s.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Separador de miles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: ',', label: Text('1,000')),
                        ButtonSegment(value: '.', label: Text('1.000')),
                      ],
                      selected: {thousandsSep},
                      onSelectionChanged: (s) => onThousandsChanged(s.first),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Vista previa: ${symbolCtrl.text}${_formatPreview(decimalPlaces, thousandsSep)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _SaveButton(onPressed: onSave),
        ],
      ),
    );
  }

  String _formatPreview(int dec, String sep) {
    if (sep == ',') {
      return dec == 0 ? '1,250' : '1,250.${List.filled(dec, '0').join()}';
    } else {
      return dec == 0 ? '1.250' : '1.250,${List.filled(dec, '0').join()}';
    }
  }
}

// ---------------------------------------------------------------------------
// Supabase section
// ---------------------------------------------------------------------------

enum _ConnectionStatus { idle, testing, ok, error }

class _SupabaseSection extends StatelessWidget {
  const _SupabaseSection({
    required this.urlCtrl,
    required this.keyCtrl,
    required this.keyObscured,
    required this.onToggleObscure,
    required this.connectionStatus,
    required this.onTest,
    required this.onSave,
  });

  final TextEditingController urlCtrl;
  final TextEditingController keyCtrl;
  final bool keyObscured;
  final VoidCallback onToggleObscure;
  final _ConnectionStatus connectionStatus;
  final VoidCallback onTest;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: urlCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL del proyecto',
              prefixIcon: Icon(Icons.link_rounded),
              hintText: 'https://xxxx.supabase.co',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: keyCtrl,
            obscureText: keyObscured,
            decoration: InputDecoration(
              labelText: 'Anon Key',
              prefixIcon: const Icon(Icons.key_rounded),
              suffixIcon: IconButton(
                icon: Icon(keyObscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: onToggleObscure,
                tooltip: keyObscured ? 'Mostrar' : 'Ocultar',
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Connection status indicator
          if (connectionStatus != _ConnectionStatus.idle) ...[
            AnimatedContainer(
              duration: AppConstants.animationNormal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: connectionStatus == _ConnectionStatus.ok
                    ? AppTheme.successColor.withAlpha(26)
                    : connectionStatus == _ConnectionStatus.error
                        ? cs.errorContainer
                        : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (connectionStatus == _ConnectionStatus.testing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      connectionStatus == _ConnectionStatus.ok
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      size: 18,
                      color: connectionStatus == _ConnectionStatus.ok
                          ? AppTheme.successColor
                          : cs.error,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    connectionStatus == _ConnectionStatus.testing
                        ? 'Probando conexión...'
                        : connectionStatus == _ConnectionStatus.ok
                            ? 'Conexión exitosa'
                            : 'Error de conexión. Verifica los datos.',
                    style: TextStyle(
                      fontSize: 13,
                      color: connectionStatus == _ConnectionStatus.ok
                          ? AppTheme.successColor
                          : connectionStatus == _ConnectionStatus.error
                              ? cs.onErrorContainer
                              : cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(child: _SaveButton(onPressed: onSave)),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: connectionStatus == _ConnectionStatus.testing
                    ? null
                    : onTest,
                icon: const Icon(Icons.wifi_tethering_rounded, size: 18),
                label: const Text('Probar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backup section
// ---------------------------------------------------------------------------

class _BackupSection extends StatelessWidget {
  const _BackupSection({
    required this.lastBackupDate,
    required this.onExport,
    required this.onImport,
  });

  final String? lastBackupDate;
  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lastBackupDate != null) ...[
            Row(
              children: [
                Icon(Icons.history_rounded,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Último respaldo: $lastBackupDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else ...[
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Ningún respaldo registrado',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Exportar respaldo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Importar respaldo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About section
// ---------------------------------------------------------------------------

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00695C), Color(0xFF004D40)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.store_rounded,
                size: 34, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.appName.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              color: Color(0xFF00695C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versión ${AppConstants.appVersion}',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _AboutRow(label: 'Desarrollador', value: 'Equipo Mercados'),
          _AboutRow(label: 'Plataforma', value: 'Flutter · Material 3'),
          _AboutRow(label: 'Backend', value: 'Supabase'),
          _AboutRow(label: 'Soporte', value: 'soporte@mercados.app'),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save_rounded, size: 18),
        label: const Text('Guardar'),
      ),
    );
  }
}
