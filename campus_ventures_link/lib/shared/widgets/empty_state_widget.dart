import 'package:flutter/material.dart';

/// Reusable, centered empty-state used across list/stream screens whenever
/// there is no data to show — replaces raw `[]`, `null`, or
/// `Instance of ...` text with a friendly layered illustration, a gentle
/// float animation, a message, and an optional action.
class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;
  final Widget? customAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
    this.customAction,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showButton = widget.buttonText != null && widget.onPressed != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _float.value),
                child: child,
              ),
              child: _LayeredIllustration(
                icon: widget.icon,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (widget.customAction != null) ...[
              const SizedBox(height: 24),
              widget.customAction!,
            ] else if (showButton) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: widget.onPressed,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(widget.buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Three concentric, decreasingly-transparent circles behind the icon —
/// a lightweight "illustration" built from shapes instead of a shipped
/// image asset, so it needs no extra files and stays crisp at any size.
class _LayeredIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _LayeredIllustration({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
          ),
          Icon(icon, size: 34, color: color),
        ],
      ),
    );
  }
}
