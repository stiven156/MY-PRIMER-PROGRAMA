import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// StatCard
// ---------------------------------------------------------------------------

/// A reusable metric summary card for dashboards and report screens.
///
/// Displays an [icon], a large [value], a [title] label, an optional
/// [subtitle] line, and an optional [trend] badge (up/down arrow + label).
///
/// ```dart
/// StatCard(
///   title: 'Ventas hoy',
///   value: r'$ 12,450.00',
///   icon: Icons.attach_money_rounded,
///   trend: '+8.3%',
///   trendPositive: true,
///   color: Colors.teal,
///   onTap: () => context.go(AppConstants.routeReports),
/// )
/// ```
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.trendPositive = true,
    this.color,
    this.onTap,
    this.isLoading = false,
  });

  /// Short label shown below the value, e.g. `'Ventas hoy'`.
  final String title;

  /// Primary display value, e.g. `'$ 12,450.00'` or `'238 uds'`.
  final String value;

  /// Icon shown in the coloured badge at the top-left.
  final IconData icon;

  /// Optional second line below [title] for context, e.g. `'vs ayer'`.
  final String? subtitle;

  /// Trend label shown in the top-right pill, e.g. `'+8.3%'` or `'-3 uds'`.
  /// Hidden when `null`.
  final String? trend;

  /// `true` → green upward trend. `false` → red downward trend.
  final bool trendPositive;

  /// Accent colour for the icon background and icon itself.
  /// Falls back to [ColorScheme.primary] when `null`.
  final Color? color;

  /// Called when the card is tapped. Adds a ripple effect when non-null.
  final VoidCallback? onTap;

  /// When `true` a shimmer-style loading placeholder replaces the content.
  final bool isLoading;

  // Semantic colours
  static const Color _green = Color(0xFF2E7D32);
  static const Color _red = Color(0xFFB00020);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _LoadingStatCard();

    final cs = Theme.of(context).colorScheme;
    final accent = color ?? cs.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top row: icon badge + trend pill ───────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(icon: icon, color: accent),
                  const Spacer(),
                  if (trend != null)
                    _TrendPill(
                      label: trend!,
                      positive: trendPositive,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Value ──────────────────────────────────────────────────
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // ── Title ──────────────────────────────────────────────────
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Subtitle ───────────────────────────────────────────────
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withAlpha(178),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _IconBadge
// ---------------------------------------------------------------------------

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ---------------------------------------------------------------------------
// _TrendPill
// ---------------------------------------------------------------------------

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.label, required this.positive});

  final String label;
  final bool positive;

  static const Color _green = Color(0xFF2E7D32);
  static const Color _red = Color(0xFFB00020);

  @override
  Widget build(BuildContext context) {
    final color = positive ? _green : _red;
    final icon =
        positive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LoadingStatCard – skeleton placeholder
// ---------------------------------------------------------------------------

class _LoadingStatCard extends StatefulWidget {
  @override
  State<_LoadingStatCard> createState() => _LoadingStatCardState();
}

class _LoadingStatCardState extends State<_LoadingStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: _shimmer,
          builder: (context, _) {
            final base = cs.surfaceContainerHighest;
            final highlight = cs.surfaceContainerHighest.withAlpha(
              (255 * (0.4 + 0.6 * _shimmer.value)).round(),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _SkeletonBox(
                      width: 42,
                      height: 42,
                      radius: 12,
                      color: highlight,
                    ),
                    const Spacer(),
                    _SkeletonBox(
                      width: 56,
                      height: 22,
                      radius: 20,
                      color: base,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SkeletonBox(width: 120, height: 28, color: highlight),
                const SizedBox(height: 8),
                _SkeletonBox(width: 80, height: 14, color: base),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 6,
    required this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// StatCardGrid – convenience responsive grid wrapper
// ---------------------------------------------------------------------------

/// A responsive grid of [StatCard] widgets that adapts to screen width.
///
/// Renders 1 column below 480 px, 2 columns up to 900 px, and 4 columns above.
class StatCardGrid extends StatelessWidget {
  const StatCardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 480
        ? 1
        : width < 900
            ? 2
            : 4;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: children,
    );
  }
}
