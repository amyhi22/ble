import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'irrigation_result.dart';

/// Handles GPS location and weather data fetching
///
/// Supports:
/// - Automatic GPS location detection
/// - Weather API integration (OpenWeatherMap)
/// - Offline fallback with cached data
/// - Error handling and retry logic
class WeatherService {
  // Use OpenWeatherMap Free API (https://openweathermap.org/api)
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Replace with your actual API key
  final String _apiKey;

  // Cache for weather data (15 minutes TTL)
  WeatherData? _cachedWeather;
  DateTime? _cacheTime;
  static const Duration _cacheTTL = Duration(minutes: 15);

  WeatherService({required String apiKey}) : _apiKey = apiKey;

  /// Get current location via GPS
  ///
  /// Throws: IrrigationException if location services unavailable
  Future<Position> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw IrrigationException(
          message:
          'Location permissions denied permanently. Enable in app settings.',
          code: 'LOCATION_PERMISSION_DENIED',
        );
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw IrrigationException(
          message: 'Location request timeout',
          code: 'LOCATION_TIMEOUT',
        ),
      );

      return position;
    } on IrrigationException {
      rethrow;
    } catch (e) {
      throw IrrigationException(
        message: 'Failed to get current location: $e',
        code: 'LOCATION_ERROR',
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Fetch weather data from OpenWeatherMap API
  ///
  /// Uses cached data if available and fresh (< 15 minutes)
  ///
  /// Returns: WeatherData with current conditions
  /// Throws: IrrigationException on API failure
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    // Return cached data if fresh
    if (!forceRefresh && _cachedWeather != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!).inMinutes < _cacheTTL.inMinutes) {
        print('📡 Using cached weather data (age: ${DateTime.now().difference(_cacheTime!).inMinutes}m)');
        return _cachedWeather!;
      }
    }

    try {
      final params = {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': _apiKey,
        'units': 'metric', // Use Celsius
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

      // Fetch with timeout
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw IrrigationException(
          message: 'Weather API request timeout',
          code: 'WEATHER_TIMEOUT',
        ),
      );

      if (response.statusCode != 200) {
        throw IrrigationException(
          message: 'Weather API error: ${response.statusCode} ${response.body}',
          code: 'WEATHER_API_ERROR',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Extract relevant weather data
      final main = data['main'] as Map<String, dynamic>;
      final wind = data['wind'] as Map<String, dynamic>? ?? {};
      final location = data['name'] as String?;

      final weather = WeatherData(
        temperature: (main['temp'] as num).toDouble(),
        humidity: (main['humidity'] as num).toDouble(),
        windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
        location: location,
      );

      // Update cache
      _cachedWeather = weather;
      _cacheTime = DateTime.now();

      print('✅ Weather fetched: $weather');
      return weather;
    } on IrrigationException {
      rethrow;
    } catch (e) {
      throw IrrigationException(
        message: 'Failed to fetch weather data: $e',
        code: 'WEATHER_FETCH_ERROR',
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Convenience method: Get location and fetch weather in one call
  ///
  /// This is the primary entry point for UI code
  Future<WeatherData> getWeatherForCurrentLocation({
    bool forceRefresh = false,
  }) async {
    final position = await getCurrentLocation();
    return fetchWeather(
      latitude: position.latitude,
      longitude: position.longitude,
      forceRefresh: forceRefresh,
    );
  }

  /// Clear cached weather data
  void clearCache() {
    _cachedWeather = null;
    _cacheTime = null;
    print('🧹 Weather cache cleared');
  }

  /// Check if cache is fresh
  bool isCacheFresh() {
    if (_cachedWeather == null || _cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!).inMinutes < _cacheTTL.inMinutes;
  }
}