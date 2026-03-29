import 'dart:math';

import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final int trigger; // Biến lắng nghe: Mỗi lần con số này thay đổi, nó sẽ rung

  const ShakeWidget({super.key, required this.child, required this.trigger});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Cài đặt thời gian rung là 400 mili-giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu biến trigger thay đổi (nghĩa là có lỗi mới), tiến hành rung
    if (widget.trigger != oldWidget.trigger && widget.trigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Công thức toán học (Sine Wave) để tạo hiệu ứng lắc qua lắc lại 3 vòng
        final sineValue = sin(6 * pi * _animation.value);
        return Transform.translate(
          offset: Offset(sineValue * 8, 0), // Lắc biên độ 8 pixel sang hai bên
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
