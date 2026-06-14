import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wheat/services/disease_alert_sheet.dart';
import 'package:wheat/services/disease_risk_engine.dart';

import '../services/weather_service.dart';
import '../models/daily_weather.dart';
import '../widgets/home/weather_irrigation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<WeatherData> _weatherFuture;

  int _alertCount = 0;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService.getWeather();
    _loadAlertCount();
  }

  // ── Alert count ────────────────────────────────────────────────
  Future<void> _loadAlertCount() async {
    try {
      final forecast = await WeatherService.get7DaysForecast();

      final alerts = DiseaseRiskEngine.getAlerts(
        forecast,
        context.locale,
      );

      if (mounted) {
        setState(() => _alertCount = alerts.length);
      }
    } catch (_) {}
  }

  // ── Weather refresh ────────────────────────────────────────────
  void _refreshWeather() {
    setState(() {
      _weatherFuture = WeatherService.getWeather(
        locale: context.locale,
      );
    });

    _loadAlertCount();
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshWeather();
          },
          color: const Color(0xFF768E2E),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),

                // ── Weather card ──
                FutureBuilder<WeatherData>(
                  future: _weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Column(
                        children: [
                          Text(
                            'home.weather_load_error'.tr(),
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _refreshWeather,
                            child: Text(
                              'general.retry'.tr(),
                            ),
                          ),
                        ],
                      );
                    }

                    final weather = snapshot.data!;

                    return WeatherIrrigationCard(
                      temperature: weather.temperature.toInt(),
                      humidity: weather.humidity.toInt(),
                      weatherCondition: weather.condition,
                    );
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF594020),
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logohelf.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 10),
          Text(
            'general.app_name'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // ── Disease alert bell with badge ──
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              tooltip: 'home.alert_tooltip'.tr(),
              onPressed: () => DiseaseAlertSheet.show(context),
            ),
            if (_alertCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 200, 47, 16),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_alertCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // ── Refresh ──
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          onPressed: _refreshWeather,
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home.greeting'.tr(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'home.title'.tr(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002319),
          ),
        ),
      ],
    );
  }
}