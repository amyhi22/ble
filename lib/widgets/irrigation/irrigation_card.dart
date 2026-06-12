import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../ai/irrigation/irrigation_service.dart';
import '../../ai/irrigation/irrigation_result.dart';
import '../shared/app_colors.dart';

class IrrigationCard extends StatefulWidget {
  final String diseaseName;

  const IrrigationCard({
    super.key,
    required this.diseaseName,
  });

  @override
  State<IrrigationCard> createState() => _IrrigationCardState();
}

class _IrrigationCardState extends State<IrrigationCard>
    with SingleTickerProviderStateMixin {
  late Future<IrrigationRecommendation> _future;
  late AnimationController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _load();
  }

  void _load() {
    _future = _fetchRecommendation();
  }

  Future<IrrigationRecommendation> _fetchRecommendation() async {
    try {
      final result = await IrrigationService().getRecommendation(
        diseaseName: widget.diseaseName,
        useCache: true,
      );
      _controller.forward(from: 0);
      return result;
    } catch (e) {
      debugPrint('❌ IrrigationCard Error: $e');
      setState(() => _error = e.toString());
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // ✅ FIX: Translate waterVolumeCategory key → localized string
  // The engine stores keys like 'low', 'moderate', 'high', 'critical'
  // ─────────────────────────────────────────────────────────
  String _translateCategory(String categoryKey) {
    final key = 'irrigation_engine.categories.${categoryKey.toLowerCase()}';
    final translated = key.tr();
    // If key not found, EasyLocalization returns the key itself — fallback to original
    return translated == key ? categoryKey : translated;
  }

  // ─────────────────────────────────────────────────────────
  // ✅ FIX: Translate irrigationFrequency key → localized string
  // The engine stores keys like 'every_3_4_days', 'every_2_3_days', etc.
  // ─────────────────────────────────────────────────────────
  String _translateFrequency(String frequencyKey) {
    final key = 'irrigation_engine.frequency.${frequencyKey.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')}';
    final translated = key.tr();
    return translated == key ? frequencyKey : translated;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<IrrigationRecommendation>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(context);
        }
        if (snapshot.hasError) return _buildErrorCard(context);
        if (!snapshot.hasData) return _buildEmptyCard(context);
        return _buildSuccessCard(context, snapshot.data!);
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9F5), Color(0xFFF5F5F0)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E4DC)),
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              context.tr('irrigation.loading'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3F3), Color(0xFFFFECEC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.error_outline, color: Colors.red),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.tr('irrigation.load_failed'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? context.tr('common.unknown_error'),
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('common.retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey.shade100,
      ),
      child: Center(
        child: Text(
          context.tr('common.no_data'),
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSuccessCard(BuildContext context, IrrigationRecommendation r) {
    final intensity = r.finalWaterIntensity.clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brownGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBrown,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.greenWithOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildBody(context, r, intensity),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.whiteWithOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.whiteWithOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('irrigation.smart_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('irrigation.smart_subtitle'),
                  style: const TextStyle(
                    color: Color(0xFFD8E6D0),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'AI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    IrrigationRecommendation r,
    double intensity,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Intensity bar ──────────────────────────────────
          Text(
            context.tr('irrigation.intensity'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: intensity,
              minHeight: 14,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getIntensityColor(intensity),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(intensity * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ✅ FIX: waterVolumeCategory is now a key → translated here
              Text(
                _translateCategory(r.waterVolumeCategory),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── Weather boxes ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _weatherBox(
                  icon: Icons.thermostat,
                  title: context.tr('irrigation.temperature'),
                  value: '${r.weatherData.temperature.toStringAsFixed(1)}°C',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _weatherBox(
                  icon: Icons.water,
                  title: context.tr('irrigation.humidity'),
                  value: '${r.weatherData.humidity.toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _weatherBox(
                  icon: Icons.air,
                  title: context.tr('irrigation.wind'),
                  value: '${r.weatherData.windSpeed.toStringAsFixed(1)}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ✅ FIX: irrigationFrequency is now a key → translated here
          _infoTile(
            icon: Icons.schedule,
            title: context.tr('irrigation.frequency'),
            value: _translateFrequency(r.irrigationFrequency),
          ),

          const SizedBox(height: 18),

          // ── Suggested actions ──────────────────────────────
          Text(
            context.tr('irrigation.suggested_actions'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          // ✅ actionItems already translated in irrigation_engine.dart
          ...r.actionItems.map((e) => _actionItem(e)),
        ],
      ),
    );
  }

  Widget _weatherBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 10, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFEDEDED),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(double value) {
    if (value < 0.3) return Colors.greenAccent;
    if (value < 0.7) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}