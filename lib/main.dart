import 'package:flutter/material.dart';
import 'reflective_glass_ball.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glass Ball Shader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GlassBallPreview(),
    );
  }
}

class GlassBallPreview extends StatefulWidget {
  const GlassBallPreview({super.key});

  @override
  State<GlassBallPreview> createState() => _GlassBallPreviewState();
}

class _GlassBallPreviewState extends State<GlassBallPreview> {
  // Configurable parameters with initial values to match a generic glass ball
  // User can tune these to match the image exactly.
  double reflectionIntensity = 0.83;
  Offset reflectionPos = const Offset(1, 1);
  double rimIntensity = 2.218;
  double smoothness = -0.17629;

  void _logParams() {
    debugPrint('--- Shader Parameters ---');
    debugPrint('Reflection Pos: ${reflectionPos.dx}, ${reflectionPos.dy}');
    debugPrint('Reflection Intensity: ${reflectionIntensity}');
    debugPrint('Rim Intensity: ${rimIntensity}');
    debugPrint('Smoothness: ${smoothness}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[850], // Dark background to contrast transparency
      appBar: AppBar(title: const Text('Reflective Glass Ball Tuner')),
      body: Row(
        children: [
          // Left: The Shader Preview
          Expanded(
            child: Stack(
              children: [
                // Checkerboard pattern to prove transparency
                Positioned.fill(
                  child: CustomPaint(painter: CheckerboardPainter()),
                ),
                Center(
                  child: ReflectiveGlassBall(
                    size: 400,
                    reflectionIntensity: reflectionIntensity,
                    reflectionPosition: reflectionPos,
                    rimIntensity: rimIntensity,
                    smoothness: smoothness,
                    ballColor: const Color(0xFFE0F7FA), // Very light cyan/white
                  ),
                ),
              ],
            ),
          ),
          // Right: Controls
          Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Reflection Position',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('X Axis'),
                Slider(
                  value: reflectionPos.dx,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) {
                    setState(() => reflectionPos = Offset(v, reflectionPos.dy));
                    _logParams();
                  },
                ),
                const Text('Y Axis'),
                Slider(
                  value: reflectionPos.dy,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) {
                    setState(() => reflectionPos = Offset(reflectionPos.dx, v));
                    _logParams();
                  },
                ),
                const Divider(),
                const Text(
                  'Light & Material',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Reflection Intensity'),
                Slider(
                  value: reflectionIntensity,
                  min: 0.0,
                  max: 2.0, // Allow overdriving
                  onChanged: (v) {
                    setState(() => reflectionIntensity = v);
                    _logParams();
                  },
                ),
                const Text('Rim (Fresnel) Intensity'),
                Slider(
                  value: rimIntensity,
                  min: 0.5,
                  max: 3.0,
                  onChanged: (v) {
                    setState(() => rimIntensity = v);
                    _logParams();
                  },
                ),
                const Text('Smoothness'),
                Slider(
                  value: smoothness,
                  min: -1.0,
                  max: 0.6,
                  onChanged: (v) {
                    setState(() => smoothness = v);
                    _logParams();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple painter to draw a checkerboard background
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.grey[800]!;
    double cellSize = 20;
    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        if (((x / cellSize).floor() + (y / cellSize).floor()) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
