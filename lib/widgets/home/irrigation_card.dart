import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class IrrigationCard extends StatelessWidget {
  const IrrigationCard({super.key});

  bool shouldIrrigate({
    required double temperature,
    required double humidity,
  }) {
    return temperature > 30 && humidity < 45;
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final temperature = 26 + random.nextInt(10);
    final humidity = 40 + random.nextInt(30);

    final irrigationNeeded = shouldIrrigate(
      temperature: temperature.toDouble(),
      humidity: humidity.toDouble(),
    );

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.95, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF768E2E).withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF768E2E).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.water_drop_outlined,
                          color: Color(0xFF768E2E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'irrigation.recommendation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002319),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        title: 'irrigation.temperature',
                        value: '$temperature°C',
                        icon: Icons.thermostat,
                      ),
                      _InfoChip(
                        title: 'irrigation.humidity',
                        value: '$humidity%',
                        icon: Icons.water_drop,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: irrigationNeeded
                          ? const Color(0xFF768E2E).withOpacity(0.10)
                          : const Color(0xFF594020).withOpacity(0.08),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          irrigationNeeded
                              ? Icons.check_circle_outline
                              : Icons.info_outline,
                          color: irrigationNeeded
                              ? const Color(0xFF768E2E)
                              : const Color(0xFF594020),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            irrigationNeeded
                                ? 'irrigation.recommended_message'
                                : 'irrigation.no_need_message',
                            style: const TextStyle(
                              color: Color(0xFF002319),
                              fontWeight: FontWeight.w600,
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
            const SizedBox(width: 14),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.9, end: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/wheat.png',
                height: 110,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF768E2E).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF768E2E),
          ),
          const SizedBox(width: 8),
          Text(
            '${title.tr()}: $value',
            style: const TextStyle(
              color: Color(0xFF002319),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}