import 'dart:convert';
import 'dart:ui' show Locale;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/daily_weather.dart';

/// Current weather snapshot — used by HomeScreen & WeatherIrrigationCard
class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String? location;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    this.location,
    required this.timestamp,
  });
}

class WeatherService {
  static WeatherData? _cachedWeather;
  static DateTime? _cacheTime;

  // ─────────────────────────────────────────
  //  GPS HELPER
  // ─────────────────────────────────────────
  static Future<Position> _getPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception("GPS OFF");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permission denied forever");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ─────────────────────────────────────────
  //  CURRENT WEATHER
  // ─────────────────────────────────────────
  static Future<WeatherData> getWeather({
    bool forceRefresh = false,
    Locale locale = const Locale('ar'),
  }) async {
    if (!forceRefresh &&
        _cachedWeather != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 15) {
      return _cachedWeather!;
    }

    final pos = await _getPosition();

    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=${pos.latitude}"
      "&longitude=${pos.longitude}"
      "&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code"
      "&timezone=auto",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Weather API error: ${res.statusCode}");
    }

    final data    = jsonDecode(res.body) as Map<String, dynamic>;
    final current = data['current']      as Map<String, dynamic>;

    final weather = WeatherData(
      temperature: (current['temperature_2m']       as num).toDouble(),
      humidity:    (current['relative_humidity_2m'] as num).toDouble(),
      windSpeed:   (current['wind_speed_10m']        as num).toDouble(),
      condition:   _wmoToCondition(current['weather_code'] as int, locale),
      timestamp:   DateTime.now(),
    );

    _cachedWeather = weather;
    _cacheTime     = DateTime.now();
    return weather;
  }

  // ─────────────────────────────────────────
  //  7-DAY FORECAST
  // ─────────────────────────────────────────
  static Future<List<DailyWeather>> get7DaysForecast() async {
    final pos = await _getPosition();

    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=${pos.latitude}"
      "&longitude=${pos.longitude}"
      "&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,relative_humidity_2m_max"
      "&forecast_days=7"
      "&timezone=auto",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Weather forecast API error: ${res.statusCode}");
    }

    final data  = jsonDecode(res.body) as Map<String, dynamic>;
    final daily = data['daily']         as Map<String, dynamic>;

    final dates    = daily['time']                     as List;
    final tMax     = daily['temperature_2m_max']       as List;
    final tMin     = daily['temperature_2m_min']       as List;
    final wind     = daily['wind_speed_10m_max']       as List;
    final humidity = daily['relative_humidity_2m_max'] as List;

    return List.generate(dates.length, (i) {
      return DailyWeather(
        date:      dates[i]     as String,
        temp:      (tMax[i]     as num).toDouble(),
        minTemp:   (tMin[i]     as num).toDouble(),
        humidity:  (humidity[i] as num).toDouble(),
        windSpeed: (wind[i]     as num).toDouble(),
      );
    });
  }

  // ─────────────────────────────────────────
  //  WMO code → localised condition string
  // ─────────────────────────────────────────
  static String _wmoToCondition(int code, Locale locale) {
    final bool ar = locale.languageCode == 'ar';
    final bool fr = locale.languageCode == 'fr';

    if (code == 0)  return ar ? 'صافٍ'            : fr ? 'Dégagé'              : 'Clear';
    if (code <= 2)  return ar ? 'غائم جزئياً'     : fr ? 'Partiellement nuageux' : 'Partly Cloudy';
    if (code == 3)  return ar ? 'غائم'            : fr ? 'Nuageux'             : 'Cloudy';
    if (code <= 49) return ar ? 'ضبابي'           : fr ? 'Brouillard'          : 'Foggy';
    if (code <= 59) return ar ? 'رذاذ'            : fr ? 'Bruine'              : 'Drizzle';
    if (code <= 69) return ar ? 'ممطر'            : fr ? 'Pluvieux'            : 'Rainy';
    if (code <= 79) return ar ? 'ثلجي'            : fr ? 'Neigeux'             : 'Snowy';
    if (code <= 82) return ar ? 'أمطار غزيرة'    : fr ? 'Pluies abondantes'   : 'Heavy Rain';
    if (code <= 86) return ar ? 'عواصف ثلجية'    : fr ? 'Tempête de neige'    : 'Snowstorm';
    if (code <= 99) return ar ? 'عواصف رعدية'    : fr ? 'Orage'               : 'Thunderstorm';
    return           ar ? 'غير معروف'             : fr ? 'Inconnu'             : 'Unknown';
  }
}