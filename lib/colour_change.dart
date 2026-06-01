import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;

class ColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy);

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const int segments = 180;
    final double sweepAngle = 2 * math.pi / segments;

    for (int i = 0; i < segments; i++) {
      final double startAngle = i * sweepAngle;

      final List<Color> colors = [];
      final List<double> stops = [];

      final Color outerColor =
      HSVColor.fromAHSV(1.0, i * 360 / segments, 1.0, 1.0).toColor();
      const Color innerColor = Colors.white;

      colors.add(innerColor);
      colors.add(outerColor);
      stops.add(0.0);
      stops.add(1.0);

      final Paint paint = Paint()
        ..shader = RadialGradient(
          colors: colors,
          stops: stops,
          center: Alignment.center,
          radius: 1.0,
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ColourChange extends StatefulWidget {
  const ColourChange({super.key});

  @override
  State<ColourChange> createState() => _ColourChangeState();
}

class _ColourChangeState extends State<ColourChange> {
  Color selectedColor = Colors.red;
  double hue = 0.0;
  double saturation = 1.0;
  double value = 1.0;
  Timer? _debounce;

  int get red => selectedColor.red;
  int get green => selectedColor.green;
  int get blue => selectedColor.blue;
  String get colorCode =>
      '#${(selectedColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().child("light").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          selectedColor = Color.fromRGBO(
            data["r"] ?? 255,
            data["g"] ?? 0,
            data["b"] ?? 0,
            1.0,
          );
          final hsv = HSVColor.fromColor(selectedColor);
          hue = hsv.hue;
          saturation = hsv.saturation;
          value = hsv.value;
        });
      }
    });
  }

  void _updateColorFromPosition(Offset position) {
    final center = const Offset(140, 140);
    final offset = position - center;
    final double r = offset.distance;
    final double wheelRadius = 140;

    if (r <= wheelRadius) {
      final double theta = math.atan2(offset.dy, offset.dx);
      double hue = (theta * 180.0 / math.pi);
      if (hue < 0) hue += 360.0;
      final double saturation = (r / wheelRadius).clamp(0.0, 1.0);

      setState(() {
        this.hue = hue;
        this.saturation = saturation;
        selectedColor =
            HSVColor.fromAHSV(1.0, this.hue, this.saturation, value)
                .toColor();
      });
      _updateColorInFirebase(selectedColor);
    }
  }

  Future<void> _updateColorInFirebase(Color color) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        developer.log(
            "🔴 R: ${color.red}, 🟢 G: ${color.green}, 🔵 B: ${color.blue}");
        final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child("light");
        await dbRef.set({
          "status": true,
          "r": color.red,
          "g": color.green,
          "b": color.blue,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        });
        developer.log(
            "✅ Updated Realtime DB with: R:${color.red}, G:${color.green}, B:${color.blue}");
      } catch (e) {
        developer.log("❌ Realtime DB update error: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to update color: $e")));
      }
    });
  }

  Widget _buildColorValue(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LIGHT COLOR",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Color wheel
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CustomPaint(
                      painter: ColorWheelPainter(),
                    ),
                  ),
                  GestureDetector(
                    onPanDown: (details) =>
                        _updateColorFromPosition(details.localPosition),
                    onPanUpdate: (details) =>
                        _updateColorFromPosition(details.localPosition),
                    child: Container(
                      width: 280,
                      height: 280,
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    left: 140 + saturation * 140 * math.cos((hue * math.pi) / 180),
                    top: 140 + saturation * 140 * math.sin((hue * math.pi) / 180),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Brightness slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Brightness',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: "${(value * 100).round()}%",
                    onChanged: (newValue) {
                      setState(() {
                        value = newValue;
                        selectedColor = HSVColor.fromAHSV(
                            1.0, hue, saturation, value)
                            .toColor();
                      });
                      _updateColorInFirebase(selectedColor);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Color preview and RGB values
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildColorValue('R', red, Colors.red),
                          _buildColorValue('G', green, Colors.green),
                          _buildColorValue('B', blue, Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Color Code: $colorCode',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Back button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('BACK'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
