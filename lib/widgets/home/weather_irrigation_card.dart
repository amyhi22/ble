import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WeatherIrrigationCard extends StatelessWidget {
  final int temperature;
  final int humidity;
  final String weatherCondition;

  const WeatherIrrigationCard({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.weatherCondition,
  });

  static const primary = Color(0xFF002319);
  static const accent = Color(0xFF768E2E);
  static const secondary = Color(0xFF594020);

  bool get irrigationNeeded => temperature >= 30 && humidity < 45;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('irrigation.title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.thermostat, "$temperature°C"),
                const SizedBox(height: 8),
                _infoRow(Icons.water_drop, "$humidity%"),
                const SizedBox(height: 8),
                _infoRow(Icons.wb_sunny, weatherCondition),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: irrigationNeeded
                        ? accent.withOpacity(0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        irrigationNeeded
                            ? Icons.check_circle
                            : Icons.info_outline,
                        size: 18,
                        color: irrigationNeeded ? accent : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          irrigationNeeded
                              ? context.tr('irrigation.recommended')
                              : context.tr('irrigation.not_needed'),
                          style: const TextStyle(
                            fontSize: 12.8,
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
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      ],
    );
  }
}