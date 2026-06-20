import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherIrrigationCard extends StatelessWidget {
  final int temperature;
  final int humidity;
  final String weatherCondition;

  final double? windSpeed;
  final double? rainfall;

  const WeatherIrrigationCard({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.weatherCondition,
    this.windSpeed,
    this.rainfall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PremiumWeatherSection(
          temperature: temperature,
          humidity: humidity,
          weatherCondition: weatherCondition,
          windSpeed: windSpeed,
          rainfall: rainfall,
        ),
      ],
    );
  }
}

// ==========================================
// 1. PREMIUM WEATHER SECTION
// ==========================================
class _PremiumWeatherSection extends StatelessWidget {
  final int temperature;
  final int humidity;
  final String weatherCondition;
  final double? windSpeed;
  final double? rainfall;

  const _PremiumWeatherSection({
    required this.temperature,
    required this.humidity,
    required this.weatherCondition,
    this.windSpeed,
    this.rainfall,
  });

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
      case 'partly cloudy':
        return Icons.cloud_rounded;
      case 'rainy':
      case 'rain':
        return Icons.water_drop_rounded;
      case 'stormy':
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InteractiveCard(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFFFF),
                const Color(0xFF2D6A4F).withOpacity(0.08),
              ],
              stops: const [0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B4332).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 24,
                offset: Offset(-8, -8),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _FloatingParticles()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'irrigation.title'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B4332),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF2D6A4F),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$temperature°',
                            style: GoogleFonts.poppins(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B4332),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weatherCondition,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2D6A4F),
                            ),
                          ),
                        ],
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 4),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, sin(value * pi * 2) * 8),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2D6A4F).withOpacity(0.1),
                          ),
                          child: Icon(
                            _getWeatherIcon(weatherCondition),
                            size: 48,
                            color: const Color(0xFF2D6A4F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MiniStat(
                        icon: Icons.water_drop_outlined,
                        label: 'Humidity',
                        value: '$humidity%',
                        color: const Color(0xFF2D6A4F),
                      ),
                      _MiniStat(
                        icon: Icons.air_outlined,
                        label: 'Wind',
                        value: '${windSpeed?.toStringAsFixed(1) ?? '5.0'} km/h',
                        color: const Color(0xFF1B4332),
                      ),
                      _MiniStat(
                        icon: Icons.umbrella_outlined,
                        label: 'Rain',
                        value: '${rainfall?.toStringAsFixed(1) ?? '0.0'} mm',
                        color: const Color(0xFF8D6E63),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. REUSABLE WIDGETS & PAINTERS
// ==========================================

class _InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _InteractiveCard({required this.child, this.onTap});

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingParticles extends StatefulWidget {
  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
          painter: _ParticlePainter(progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2D6A4F).withOpacity(0.08);

    for (int i = 0; i < 5; i++) {
      final x = (size.width * (0.2 + i * 0.15)) + sin(progress * pi * 2 + i) * 10;
      final y = (size.height * (0.3 + (i % 2) * 0.4)) + cos(progress * pi * 2 + i) * 15;
      final radius = 10.0 + i * 5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}