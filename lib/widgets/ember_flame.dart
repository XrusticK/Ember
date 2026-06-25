import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Живой огонёк: иконка пламени с мягким «дышащим» свечением.
/// Уважает системную настройку «уменьшить движение».
class EmberFlame extends StatefulWidget {
  const EmberFlame({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  State<EmberFlame> createState() => _EmberFlameState();
}

class _EmberFlameState extends State<EmberFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? EmberColors.ember;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) return _flame(color, 0.5);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => _flame(color, _c.value),
    );
  }

  Widget _flame(Color color, double t) {
    final glow = 0.35 + 0.35 * t; // 0.35..0.70
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: glow * 0.6),
            blurRadius: widget.size * (0.4 + 0.25 * t),
            spreadRadius: widget.size * 0.05,
          ),
        ],
      ),
      child: Icon(
        Icons.local_fire_department,
        size: widget.size,
        color: Color.lerp(color, EmberColors.emberSoft, t * 0.5),
      ),
    );
  }
}
