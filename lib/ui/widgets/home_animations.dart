import 'package:flutter/material.dart';

// --- 1. WIDGET LƠ LỬNG (DÀNH CHO TÊN GAME / LOGO) ---
class FloatingWidget extends StatefulWidget {
  final Widget child;
  const FloatingWidget({super.key, required this.child});

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation kéo dài 2 giây, lặp đi lặp lại mượt mà
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          // Trôi lên trôi xuống biên độ 12 pixel
          offset: Offset(0, 12 * _controller.value - 6),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// --- 2. WIDGET NHỊP THỞ (DÀNH CHO NÚT PLAY / SELECT LEVEL) ---
class PulseWidget extends StatefulWidget {
  final Widget child;
  const PulseWidget({super.key, required this.child});

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Nhịp thở nhanh hơn một chút: 1 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          // Phóng to lên 4% (1.04) rồi thu về bình thường
          scale: 1.0 + (0.04 * _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
