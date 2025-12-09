import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ReflectiveGlassBall extends StatefulWidget {
  final double size;
  final double reflectionIntensity; // 0.0 to 1.0
  final Offset reflectionPosition; // 0.0-1.0 coords (TopLeft=0,0)
  final double rimIntensity; // 0.0 to 1.0
  final Color ballColor;
  final double smoothness; // 0.0 to 1.0

  const ReflectiveGlassBall({
    Key? key,
    required this.size,
    this.reflectionIntensity = 0.8,
    this.reflectionPosition = const Offset(0.3, 0.3),
    this.rimIntensity = 0.6,
    this.ballColor = const Color(0xFFADD8E6), // Light Blue default
    this.smoothness = 0.5,
  }) : super(key: key);

  @override
  State<ReflectiveGlassBall> createState() => _ReflectiveGlassBallState();
}

class _ReflectiveGlassBallState extends State<ReflectiveGlassBall> {
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  void _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/reflective_ball.frag',
      );
      setState(() {
        _program = program;
      });
    } catch (e) {
      debugPrint('Error loading reflective ball shader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: ReflectiveBallPainter(
        shaderProgram: _program!,
        reflectionIntensity: widget.reflectionIntensity,
        reflectionPosition: widget.reflectionPosition,
        rimIntensity: widget.rimIntensity,
        ballColor: widget.ballColor,
        smoothness: widget.smoothness,
      ),
    );
  }
}

class ReflectiveBallPainter extends CustomPainter {
  final ui.FragmentProgram shaderProgram;
  final double reflectionIntensity;
  final Offset reflectionPosition;
  final double rimIntensity;
  final Color ballColor;
  final double smoothness;

  ReflectiveBallPainter({
    required this.shaderProgram,
    required this.reflectionIntensity,
    required this.reflectionPosition,
    required this.rimIntensity,
    required this.ballColor,
    required this.smoothness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = shaderProgram.fragmentShader();

    // 0: uResolution (vec2)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // 2: uReflectionIntensity (float)
    shader.setFloat(2, reflectionIntensity);

    // 3: uReflectionPos (vec2)
    shader.setFloat(3, reflectionPosition.dx);
    shader.setFloat(4, reflectionPosition.dy);

    // 5: uRimIntensity (float)
    shader.setFloat(5, rimIntensity);

    // 6: uBallColor (vec3)
    shader.setFloat(6, ballColor.r);
    shader.setFloat(7, ballColor.g);
    shader.setFloat(8, ballColor.b);

    // 9: uSmoothness (float)
    shader.setFloat(9, smoothness);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant ReflectiveBallPainter oldDelegate) {
    return oldDelegate.reflectionIntensity != reflectionIntensity ||
        oldDelegate.reflectionPosition != reflectionPosition ||
        oldDelegate.rimIntensity != rimIntensity ||
        oldDelegate.ballColor != ballColor ||
        oldDelegate.smoothness != smoothness;
  }
}
