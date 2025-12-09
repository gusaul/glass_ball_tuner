import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WaterBubble extends StatefulWidget {
  final double size;
  final ui.Image backgroundTexture;

  const WaterBubble({
    Key? key,
    required this.size,
    required this.backgroundTexture,
  }) : super(key: key);

  @override
  State<WaterBubble> createState() => _WaterBubbleState();
}

class _WaterBubbleState extends State<WaterBubble>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slow rotation/movement
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/water_bubble.frag',
      );
      setState(() {
        _program = program;
      });
    } catch (e) {
      debugPrint('Error loading water shader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) return Container();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WaterBubblePainter(
            shaderProgram: _program!,
            texture: widget.backgroundTexture,
            time: _controller.value * 10.0, // Scale time
          ),
        );
      },
    );
  }
}

class WaterBubblePainter extends CustomPainter {
  final ui.FragmentProgram shaderProgram;
  final ui.Image texture;
  final double time;

  WaterBubblePainter({
    required this.shaderProgram,
    required this.texture,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = shaderProgram.fragmentShader();

    // 0: uResolution (vec2)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // 2: uTime (float)
    shader.setFloat(2, time);

    // 3: uBackgroundTexture (sampler2D)
    shader.setImageSampler(0, texture);

    final paint = Paint()..shader = shader;

    // Draw the rect.
    // Note: The shader assumes UVs cover the bubble area.
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant WaterBubblePainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.texture != texture;
  }
}
