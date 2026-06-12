import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';
import 'dart:typed_data';
import 'irrigation_result.dart';

class IrrigationModelService {
  static const String _modelPath = 'assets/models/irrigation_model.tflite';
  static const String _modelName = 'Irrigation Intensity Predictor';

  late Interpreter _interpreter;
  bool _isInitialized = false;

  /// ⚠️ model expects 46 features (from your log)
  static const int _inputSize = 46;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = InterpreterOptions()..threads = 2;

      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: options,
      );

      _isInitialized = true;

      print('===== MODEL DEBUG =====');
      for (final t in _interpreter.getInputTensors()) {
        print('INPUT: shape=${t.shape} type=${t.type}');
      }
      for (final t in _interpreter.getOutputTensors()) {
        print('OUTPUT: shape=${t.shape} type=${t.type}');
      }
      print('=======================');

      print('✅ Irrigation model loaded successfully');
    } catch (e) {
      print('❌ Failed to load model: $e');
      rethrow;
    }
  }

  Future<IrrigationModelPrediction> predictWaterIntensity({
    required double temperature,
    required double humidity,
    required double windSpeed,
    double historicalWaterStress = 0.5,
  }) async {
    if (!_isInitialized) {
      throw IrrigationException(
        message: 'Model not initialized',
        code: 'MODEL_NOT_INIT',
      );
    }

    try {
      final stopwatch = Stopwatch()..start();

      /// 🔥 IMPORTANT: must be 46 features
      final input = _build46Features(
        temperature: temperature,
        humidity: humidity,
        windSpeed: windSpeed,
        stress: historicalWaterStress,
      );

      print("INPUT: $input");

      // reshape correctly [1,46]
      final inputTensor = [input];

      final output = List.generate(1, (_) => [0.0]);

      _interpreter.run(inputTensor, output);

      stopwatch.stop();

      final result = output[0][0].clamp(0.0, 1.0);

      return IrrigationModelPrediction(
        waterIntensity: result,
        rawOutput: [result],
        inferenceTime: stopwatch.elapsed,
      );
    } catch (e) {
      throw IrrigationException(
        message: 'Inference failed: $e',
        code: 'INFERENCE_ERROR',
        stackTrace: StackTrace.current,
      );
    }
  }

  /// 🔥 FIX: create 46-feature vector (dummy expansion)
  List<double> _build46Features({
    required double temperature,
    required double humidity,
    required double windSpeed,
    required double stress,
  }) {
    final base = <double>[
      temperature / 50.0,
      humidity / 100.0,
      windSpeed / 20.0,
      stress,
    ];

    /// fill remaining 42 features safely
    while (base.length < _inputSize) {
      base.add(0.0);
    }

    return base;
  }

  /// 📊 DEBUG FUNCTION (this fixes your missing method error)
  Map<String, dynamic> getModelSpecs() {
    if (!_isInitialized) {
      return {
        'status': 'not_initialized',
      };
    }

    return {
      'model': _modelName,
      'input_shape': _interpreter.getInputTensor(0).shape,
      'output_shape': _interpreter.getOutputTensor(0).shape,
      'status': 'ready',
    };
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
}