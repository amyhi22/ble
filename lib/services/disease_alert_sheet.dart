import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wheat/services/disease_risk_engine.dart';
import '../models/daily_weather.dart';
import '../services/weather_service.dart';

/// Shows a bottom sheet with disease risk alerts based on 7-day forecast.
class DiseaseAlertSheet extends StatefulWidget {
  const DiseaseAlertSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DiseaseAlertSheet(),
    );
  }

  @override
  State<DiseaseAlertSheet> createState() => _DiseaseAlertSheetState();
}

class _DiseaseAlertSheetState extends State<DiseaseAlertSheet> {
  List<DiseaseRisk>? _risks;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRisks();
  }
Future<void> _loadRisks() async {
    try {
      final forecast = await WeatherService.get7DaysForecast();
      final risks = DiseaseRiskEngine.getAlerts(forecast, context.locale);
      if (mounted) setState(() { _risks = risks; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFF9800), size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('alerts.title'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002319),
                            ),
                          ),
                          Text(
                            context.tr('alerts.subtitle'),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(
                        color: Color(0xFF768E2E)))
                    : _error != null
                        ? _buildError()
                        : _risks == null || _risks!.isEmpty
                            ? _buildNoAlerts()
                            : _buildRiskList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoAlerts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF4CAF50), size: 64),
            const SizedBox(height: 16),
            Text(
              context.tr('alerts.no_risks_title'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002319)),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('alerts.no_risks_body'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              context.tr('alerts.weather_error'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _loading = true; _error = null; });
                _loadRisks();
              },
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('alerts.retry')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF768E2E)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskList(ScrollController scrollController) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _risks!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _RiskCard(risk: _risks![i]),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Risk card widget
// ─────────────────────────────────────────────────────────
class _RiskCard extends StatefulWidget {
  final DiseaseRisk risk;
  const _RiskCard({required this.risk});

  @override
  State<_RiskCard> createState() => _RiskCardState();
}

class _RiskCardState extends State<_RiskCard> {
  bool _expanded = false;

  Color get _riskColor => _hexColor(widget.risk.riskColor);

  Color _hexColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final risk = widget.risk;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _riskColor.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _riskColor.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _riskColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${risk.riskPercent.toInt()}%',
                        style: TextStyle(
                          color: _riskColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // diseaseName is already localised by DiseaseRiskEngine
                          risk.diseaseName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _riskColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                // riskLevel is already localised by DiseaseRiskEngine
                                risk.riskLevel,
                                style: TextStyle(
                                  color: _riskColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: risk.riskPercent / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: _riskColor,
                      minHeight: 6,
                    ),
                  ),

                  if (risk.triggers.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      context.tr('alerts.triggers_label'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...risk.triggers.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle, size: 6, color: _riskColor),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(t,
                                      style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                  ],

                  if (risk.prevention.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      context.tr('alerts.prevention_label'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...risk.prevention.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 14, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(p,
                                      style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
