import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Button variant enum
// ---------------------------------------------------------------------------

/// Visual style variants for [CustomButton].
enum ButtonVariant {
  /// Filled primary-colour button (default action).
  primary,

  /// Filled secondary/surface-tinted button (secondary action).
  secondary,

  /// Filled red/error-colour button (destructive action).
  danger,

  /// Outlined transparent button (tertiary / cancel action).
  outlined,

  /// Ghost / text-only button (subtle action).
  ghost,
}

// ---------------------------------------------------------------------------
// CustomButton
// ---------------------------------------------------------------------------

/// A consistent, accessible button widget used throughout the Mercados app.
///
/// Supports five [ButtonVariant]s, optional leading/trailing [icon], a loading
/// state that disables interaction and shows a [CircularProgressIndicator], and
/// full-width mode.
///
/// ```dart
/// CustomButton(
///   label: 'Guardar producto',
///   icon: Icons.save_rounded,
///   onPressed: _save,
///   isLoading: _saving,
/// )
///
/// CustomButton.danger(
///   label: 'Eliminar',
///   icon: Icons.delete_rounded,
///   onPressed: _delete,
/// )
/// ```
class CustomButton extends StatelessWidget {
  // ── Standard constructor ─────────────────────────────────────────────────

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.size = ButtonSize.medium,
  });

  // ── Named constructors ───────────────────────────────────────────────────

  /// Shortcut for [ButtonVariant.secondary].
  const CustomButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.medium,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          icon: icon,
          trailingIcon: trailingIcon,
          variant: ButtonVariant.secondary,
          isLoading: isLoading,
          fullWidth: fullWidth,
          size: size,
        );

  /// Shortcut for [ButtonVariant.danger].
  const CustomButton.danger({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.medium,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          icon: icon,
          trailingIcon: trailingIcon,
          variant: ButtonVariant.danger,
          isLoading: isLoading,
          fullWidth: fullWidth,
          size: size,
        );

  /// Shortcut for [ButtonVariant.outlined].
  const CustomButton.outlined({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.medium,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          icon: icon,
          trailingIcon: trailingIcon,
          variant: ButtonVariant.outlined,
          isLoading: isLoading,
          fullWidth: fullWidth,
          size: size,
        );

  /// Shortcut for [ButtonVariant.ghost].
  const CustomButton.ghost({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.medium,
  }) : this(
          key: key,
          label: label,
          onPressed: onPressed,
          icon: icon,
          trailingIcon: trailingIcon,
          variant: ButtonVariant.ghost,
          isLoading: isLoading,
          fullWidth: fullWidth,
          size: size,
        );

  // ── Properties ───────────────────────────────────────────────────────────

  /// Text displayed on the button.
  final String label;

  /// Callback invoked on press. When `null` the button is disabled.
  final VoidCallback? onPressed;

  /// Optional icon shown to the left of [label].
  final IconData? icon;

  /// Optional icon shown to the right of [label].
  final IconData? trailingIcon;

  /// Visual style variant. Defaults to [ButtonVariant.primary].
  final ButtonVariant variant;

  /// When `true` a [CircularProgressIndicator] replaces the button content and
  /// [onPressed] is ignored.
  final bool isLoading;

  /// When `true` the button stretches to fill its parent's width.
  final bool fullWidth;

  /// Controls internal padding / font size. Defaults to [ButtonSize.medium].
  final ButtonSize size;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveCallback = isLoading ? null : onPressed;
    final dims = _ButtonDimensions.of(size);

    final Widget buttonWidget = switch (variant) {
      ButtonVariant.primary => _buildFilled(
          context: context,
          cs: cs,
          dims: dims,
          background: cs.primary,
          foreground: cs.onPrimary,
          callback: effectiveCallback,
        ),
      ButtonVariant.secondary => _buildFilled(
          context: context,
          cs: cs,
          dims: dims,
          background: cs.secondaryContainer,
          foreground: cs.onSecondaryContainer,
          callback: effectiveCallback,
        ),
      ButtonVariant.danger => _buildFilled(
          context: context,
          cs: cs,
          dims: dims,
          background: cs.error,
          foreground: cs.onError,
          callback: effectiveCallback,
        ),
      ButtonVariant.outlined => _buildOutlined(
          context: context,
          cs: cs,
          dims: dims,
          callback: effectiveCallback,
        ),
      ButtonVariant.ghost => _buildGhost(
          context: context,
          cs: cs,
          dims: dims,
          callback: effectiveCallback,
        ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }

  // ── Filled variant ───────────────────────────────────────────────────────

  Widget _buildFilled({
    required BuildContext context,
    required ColorScheme cs,
    required _ButtonDimensions dims,
    required Color background,
    required Color foreground,
    required VoidCallback? callback,
  }) {
    return FilledButton(
      onPressed: callback,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: cs.onSurface.withAlpha(31),
        disabledForegroundColor: cs.onSurface.withAlpha(97),
        padding: dims.padding,
        minimumSize: Size(0, dims.height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: dims.fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      child: _buildContent(foreground: foreground, dims: dims),
    );
  }

  // ── Outlined variant ─────────────────────────────────────────────────────

  Widget _buildOutlined({
    required BuildContext context,
    required ColorScheme cs,
    required _ButtonDimensions dims,
    required VoidCallback? callback,
  }) {
    return OutlinedButton(
      onPressed: callback,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        disabledForegroundColor: cs.onSurface.withAlpha(97),
        side: BorderSide(
          color: callback == null
              ? cs.onSurface.withAlpha(31)
              : cs.outline,
          width: 1.5,
        ),
        padding: dims.padding,
        minimumSize: Size(0, dims.height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: dims.fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      child: _buildContent(foreground: cs.primary, dims: dims),
    );
  }

  // ── Ghost variant ────────────────────────────────────────────────────────

  Widget _buildGhost({
    required BuildContext context,
    required ColorScheme cs,
    required _ButtonDimensions dims,
    required VoidCallback? callback,
  }) {
    return TextButton(
      onPressed: callback,
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        disabledForegroundColor: cs.onSurface.withAlpha(97),
        padding: dims.padding,
        minimumSize: Size(0, dims.height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontSize: dims.fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      child: _buildContent(foreground: cs.primary, dims: dims),
    );
  }

  // ── Content builder ──────────────────────────────────────────────────────

  Widget _buildContent({
    required Color foreground,
    required _ButtonDimensions dims,
  }) {
    if (isLoading) {
      return SizedBox(
        width: dims.loaderSize,
        height: dims.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    }

    if (icon == null && trailingIcon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: dims.iconSize, color: foreground),
          SizedBox(width: dims.iconSpacing),
        ],
        Text(label),
        if (trailingIcon != null) ...[
          SizedBox(width: dims.iconSpacing),
          Icon(trailingIcon, size: dims.iconSize, color: foreground),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Button size enum & dimensions
// ---------------------------------------------------------------------------

/// Controls the size of [CustomButton].
enum ButtonSize {
  /// Compact variant for toolbars and tight spaces.
  small,

  /// Default size for most use-cases.
  medium,

  /// Large variant for prominent CTAs.
  large,
}

/// Internal dimensions for a given [ButtonSize].
class _ButtonDimensions {
  const _ButtonDimensions({
    required this.padding,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.loaderSize,
  });

  final EdgeInsetsGeometry padding;
  final double height;
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final double loaderSize;

  static _ButtonDimensions of(ButtonSize size) => switch (size) {
        ButtonSize.small => const _ButtonDimensions(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            height: 36,
            fontSize: 13,
            iconSize: 16,
            iconSpacing: 6,
            loaderSize: 16,
          ),
        ButtonSize.medium => const _ButtonDimensions(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            height: 44,
            fontSize: 15,
            iconSize: 18,
            iconSpacing: 8,
            loaderSize: 18,
          ),
        ButtonSize.large => const _ButtonDimensions(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            height: 54,
            fontSize: 17,
            iconSize: 22,
            iconSpacing: 10,
            loaderSize: 22,
          ),
      };
}

// ---------------------------------------------------------------------------
// IconCustomButton – icon-only circular button
// ---------------------------------------------------------------------------

/// A compact icon-only button backed by [IconButton.filled],
/// [IconButton.filledTonal], or [IconButton.outlined] depending on [variant].
///
/// Useful for action columns in data tables and toolbars.
class IconCustomButton extends StatelessWidget {
  const IconCustomButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final ButtonVariant variant;
  final bool isLoading;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveCallback = isLoading ? null : onPressed;

    final loaderWidget = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          variant == ButtonVariant.outlined ? cs.primary : cs.onPrimary,
        ),
      ),
    );

    final child = isLoading ? loaderWidget : Icon(icon, size: size * 0.5);

    final button = switch (variant) {
      ButtonVariant.primary || ButtonVariant.secondary => IconButton.filled(
          onPressed: effectiveCallback,
          icon: child,
          style: IconButton.styleFrom(
            backgroundColor: variant == ButtonVariant.danger
                ? cs.error
                : cs.primary,
            foregroundColor: variant == ButtonVariant.danger
                ? cs.onError
                : cs.onPrimary,
            minimumSize: Size(size, size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ButtonVariant.danger => IconButton.filled(
          onPressed: effectiveCallback,
          icon: child,
          style: IconButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            minimumSize: Size(size, size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ButtonVariant.outlined => IconButton.outlined(
          onPressed: effectiveCallback,
          icon: child,
          style: IconButton.styleFrom(
            foregroundColor: cs.primary,
            side: BorderSide(color: cs.outline),
            minimumSize: Size(size, size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ButtonVariant.ghost => IconButton(
          onPressed: effectiveCallback,
          icon: child,
          style: IconButton.styleFrom(
            foregroundColor: cs.primary,
            minimumSize: Size(size, size),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
    };

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
