import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlassBallShader extends StatefulWidget {
  final Color color;
  final double size;

  const GlassBallShader({Key? key, required this.color, required this.size})
    : super(key: key);

  @override
  State<GlassBallShader> createState() => _GlassBallShaderState();
}

class _GlassBallShaderState extends State<GlassBallShader> {
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  void _loadShader() async {
    // Load the compiled shader from assets
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/glass_ball.frag',
      );
      setState(() {
        _program = program;
      });
    } catch (e) {
      debugPrint('Error loading shader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) return Container(); // Loading state

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: ShaderPainter(shaderProgram: _program!, color: widget.color),
    );
  }
}

class ShaderPainter extends CustomPainter {
  final ui.FragmentProgram shaderProgram;
  final Color color;

  ShaderPainter({required this.shaderProgram, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Pass variables to the shader
    final shader = shaderProgram.fragmentShader();

    // uResolution (Input 0 & 1)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // uColor (Input 2, 3, 4) - Convert Flutter Color to RGB (0.0 - 1.0)
    shader.setFloat(2, color.red / 255);
    shader.setFloat(3, color.green / 255);
    shader.setFloat(4, color.blue / 255);

    // uTime (Input 5) - Set to 0 for static, or pass animation value
    shader.setFloat(5, 0.0);

    final paint = Paint()..shader = shader;

    // Draw a rect that the shader will fill
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Change to true if animating
}
