/// Model for a single day's weather forecast
class DailyWeather {
  final String date;       // "2025-06-05"
  final double temp;       // max temperature °C
  final double minTemp;    // min temperature °C
  final double humidity;   // max relative humidity %
  final double windSpeed;  // max wind speed km/h

  DailyWeather({
    required this.date,
    required this.temp,
    required this.minTemp,
    required this.humidity,
    required this.windSpeed,
  });

  /// Average temperature for the day
  double get avgTemp => (temp + minTemp) / 2;

  @override
  String toString() =>
      'DailyWeather($date: ${temp.toStringAsFixed(1)}°C, '
      'hum: ${humidity.toStringAsFixed(0)}%, '
      'wind: ${windSpeed.toStringAsFixed(1)}km/h)';
}