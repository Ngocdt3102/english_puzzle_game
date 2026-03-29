import 'package:flutter/material.dart';

class BreathingGlowWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final bool isEnabled; // Biến để tắt lóe sáng khi hết gợi ý

  const BreathingGlowWidget({
    super.key,
    required this.child,
    required this.glowColor,
    this.isEnabled = true,
  });

  @override
  State<BreathingGlowWidget> createState() => _BreathingGlowWidgetState();
}

class _BreathingGlowWidgetState extends State<BreathingGlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Chạy một chu kỳ mất 1.2 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Độ tỏa sáng (BlurRadius) dao động từ 4 đến 15 pixel
    _glowAnimation = Tween<double>(
      begin: 4.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isEnabled) {
      _controller.repeat(
        reverse: true,
      ); // Lặp lại liên tục (bật ra rồi thụt vào)
    }
  }

  @override
  void didUpdateWidget(covariant BreathingGlowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Xử lý bật/tắt animation khi số gợi ý thay đổi
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
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
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: widget.isEnabled
                ? [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.6), // Màu hào quang
                      blurRadius: _glowAnimation.value, // Độ nhòe động
                      spreadRadius: _glowAnimation.value / 4, // Độ lan tỏa động
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
