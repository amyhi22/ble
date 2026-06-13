import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherIrrigationCard extends StatelessWidget {
  final int temperature;
  final int humidity;
  final String weatherCondition;

  // Optional parameters for new premium stats (defaults provided to prevent breaking changes)
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

  bool get irrigationNeeded => temperature >= 30 && humidity < 45;

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
        const SizedBox(height: 20),
        _PremiumIrrigationSection(
          temperature: temperature.toDouble(),
          humidity: humidity.toDouble(),
          irrigationNeeded: irrigationNeeded,
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
            // FIX: Replaced the broken extension with native .withOpacity()
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFFFF),
                const Color(0xFF2D6A4F).withOpacity(0.08), // Subtle green tint
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
              // Floating Particles Background
              Positioned.fill(child: _FloatingParticles()),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'irrigation.title'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B4332), // Dark Green
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

                  // Temperature and Icon
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
                      // Animated Weather Icon
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

                  // Mini Stats
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
                        color: const Color(0xFF8D6E63), // Brown
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
// 2. PREMIUM IRRIGATION SECTION
// ==========================================
class _PremiumIrrigationSection extends StatelessWidget {
  final double temperature;
  final double humidity;
  final bool irrigationNeeded;

  const _PremiumIrrigationSection({
    required this.temperature,
    required this.humidity,
    required this.irrigationNeeded,
  });

  double get soilMoisture => irrigationNeeded ? 0.3 : 0.85;

  // Dynamic Colors based on status
  Color get primaryColor => irrigationNeeded
      ? const Color(0xFF8D6E63) // Brown
      : const Color(0xFF2D6A4F); // Green

  Color get lightColor => irrigationNeeded
      ? const Color(0xFFBCAAA4)
      : const Color(0xFF95D5B2);

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
                primaryColor.withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Irrigation Status',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B4332),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          irrigationNeeded ? 'Needs Water' : 'Optimal',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Center: Circular Progress + Water Wave
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular Progress
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: soilMoisture),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return CustomPaint(
                          size: const Size(160, 160),
                          painter: _CircleProgressPainter(
                            progress: value,
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                    // Water Wave
                    ClipOval(
                      child: Container(
                        width: 130,
                        height: 130,
                        color: Colors.white,
                        child: _WaterWave(
                          waterLevel: soilMoisture,
                          color: primaryColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                    // Center Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(soilMoisture * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B4332),
                          ),
                        ),
                        Text(
                          'Soil Moisture',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      irrigationNeeded ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        irrigationNeeded
                            ? 'irrigation.recommended'.tr()
                            : 'irrigation.not_needed'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1B4332),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. REUSABLE WIDGETS & PAINTERS
// ==========================================

// Interactive Wrapper for Micro-interactions
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

// Mini Stat Widget for Weather
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

// Floating Particles Background
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

// Water Wave Animation
class _WaterWave extends StatefulWidget {
  final double waterLevel;
  final Color color;

  const _WaterWave({required this.waterLevel, required this.color});

  @override
  State<_WaterWave> createState() => _WaterWaveState();
}

class _WaterWaveState extends State<_WaterWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
          painter: _WavePainter(
            waterLevel: widget.waterLevel,
            animationValue: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double waterLevel;
  final double animationValue;
  final Color color;

  _WavePainter({
    required this.waterLevel,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = size.height * 0.05;
    final y = size.height * (1 - waterLevel);

    // First wave (back)
    final path1 = Path();
    path1.moveTo(0, y);
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        y + sin((i / size.width * 2 * pi) + (animationValue * 2 * pi)) * waveHeight,
      );
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    final paint1 = Paint()..color = color.withOpacity(0.5);
    canvas.drawPath(path1, paint1);

    // Second wave (front)
    final path2 = Path();
    path2.moveTo(0, y + 5);
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        y + 5 + sin((i / size.width * 2 * pi) + (animationValue * 2 * pi) + pi) * waveHeight * 0.8,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    final paint2 = Paint()..color = color;
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.waterLevel != waterLevel;
  }
}

// Circular Progress Indicator
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}