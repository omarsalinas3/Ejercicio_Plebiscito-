import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiAnimado extends StatefulWidget {
  const ConfettiAnimado({super.key});

  @override
  State<ConfettiAnimado> createState() => _ConfettiAnimadoState();
}

class _ConfettiAnimadoState extends State<ConfettiAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ParticulaConfeti> _particulas = [];
  final Random _rnd = Random();

  final List<Color> _colores = const [
    Colors.amber,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    for (int i = 0; i < 65; i++) {
      _particulas.add(
        _ParticulaConfeti(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble() * -0.5,
          ancho: 8 + _rnd.nextDouble() * 6,
          alto: 5 + _rnd.nextDouble() * 5,
          color: _colores[_rnd.nextInt(_colores.length)],
          velocidad: 0.25 + _rnd.nextDouble() * 0.45,
          anguloRotacion: _rnd.nextDouble() * 2 * pi,
          velocidadRotacion: (_rnd.nextDouble() - 0.5) * 8,
          desplazamientoX: (_rnd.nextDouble() - 0.5) * 0.2,
        ),
      );
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
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfetiPainter(
            particulas: _particulas,
            progreso: _controller.value,
          ),
        );
      },
    );
  }
}

class _ParticulaConfeti {
  final double x;
  final double y;
  final double ancho;
  final double alto;
  final Color color;
  final double velocidad;
  final double anguloRotacion;
  final double velocidadRotacion;
  final double desplazamientoX;

  _ParticulaConfeti({
    required this.x,
    required this.y,
    required this.ancho,
    required this.alto,
    required this.color,
    required this.velocidad,
    required this.anguloRotacion,
    required this.velocidadRotacion,
    required this.desplazamientoX,
  });
}

class _ConfetiPainter extends CustomPainter {
  final List<_ParticulaConfeti> particulas;
  final double progreso;

  _ConfetiPainter({required this.particulas, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particulas) {
      final double posY = ((p.y + progreso * p.velocidad * 2.2) % 1.2) * size.height;
      final double posX = ((p.x + sin(progreso * 2 * pi + p.x * 10) * p.desplazamientoX) % 1.0) * size.width;
      final double rotacion = p.anguloRotacion + progreso * p.velocidadRotacion * 2 * pi;

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(rotacion);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.ancho,
          height: p.alto,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfetiPainter oldDelegate) => true;
}
