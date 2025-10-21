import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable Background widget with scratched dark texture
class CustomBackground extends StatelessWidget {
  final Widget child;

  const CustomBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scratched texture background
        Positioned.fill(
          child: CustomPaint(
            painter: ScratchedTexturePainter(),
          ),
        ),
        // Your content
        child,
      ],
    );
  }
}

class ScratchedTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistency
    
    // Draw dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0A0A),
    );
    
    // Add subtle noise texture
    _drawNoiseTexture(canvas, size, random);
    
    // Draw scratches - multiple layers for depth
    _drawScratches(canvas, size, random, 150, 0.15, 0.5); // Thin scratches
    _drawScratches(canvas, size, random, 80, 0.3, 1.0);   // Medium scratches
    _drawScratches(canvas, size, random, 40, 0.5, 1.5);   // Thick scratches
    
    // Add some diagonal emphasis scratches
    _drawDiagonalScratches(canvas, size, random);
  }
  
  void _drawNoiseTexture(Canvas canvas, Size size, math.Random random) {
    final paint = Paint()..blendMode = BlendMode.overlay;
    
    for (int i = 0; i < 2000; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * 0.1;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }
  
  void _drawScratches(Canvas canvas, Size size, math.Random random, 
                      int count, double opacityBase, double strokeWidth) {
    for (int i = 0; i < count; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacityBase * (0.3 + random.nextDouble() * 0.7))
        ..strokeWidth = strokeWidth * (0.5 + random.nextDouble() * 0.5)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      // Random start position
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      
      // Create path with multiple segments for natural scratches
      final path = Path();
      path.moveTo(startX, startY);
      
      final segments = 2 + random.nextInt(4);
      var currentX = startX;
      var currentY = startY;
      
      // Random angle with preference for certain directions
      var angle = random.nextDouble() * math.pi * 2;
      
      for (int j = 0; j < segments; j++) {
        // Length varies
        final length = 20 + random.nextDouble() * 80;
        
        // Slight angle variation for natural look
        angle += (random.nextDouble() - 0.5) * 0.5;
        
        currentX += math.cos(angle) * length;
        currentY += math.sin(angle) * length;
        
        // Keep within bounds (mostly)
        currentX = currentX.clamp(-50.0, size.width + 50);
        currentY = currentY.clamp(-50.0, size.height + 50);
        
        path.lineTo(currentX, currentY);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawDiagonalScratches(Canvas canvas, Size size, math.Random random) {
    // Add some prominent diagonal scratches like in the image
    for (int i = 0; i < 20; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.2 + random.nextDouble() * 0.3)
        ..strokeWidth = 0.5 + random.nextDouble() * 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      
      // Prefer diagonal angles
      final angle = (random.nextBool() ? 0.25 : -0.25) * math.pi + 
                    (random.nextDouble() - 0.5) * 0.3;
      final length = 100 + random.nextDouble() * 200;
      
      final endX = startX + math.cos(angle) * length;
      final endY = startY + math.sin(angle) * length;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}