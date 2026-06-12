import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:easy_localization/easy_localization.dart';

import 'treatment_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Interpreter? _interpreter;

  final List<String> labels = [
    'Aphid',
    'Black Rust',
    'Blast',
    'Brown Rust',
    'Common Root Rot',
    'Fusarium Head Blight',
    'Healthy',
    'Leaf Blight',
    'Mildew',
    'Mite',
    'Septoria',
    'Smut',
    'Stem fly',
    'Tan spot',
    'Yellow Rust',
  ];

  String prediction = "";
  double confidence = 0;
  bool modelLoaded = false;
  bool isAnalyzing = false;

  static const int _modelInputSize = 300;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions()..threads = 4;
    _interpreter = await Interpreter.fromAsset(
      'assets/models/model_preprocessing.tflite',
      options: options,
    );
    setState(() => modelLoaded = true);
  }

  Future<void> _takePhoto() async {
    if (!modelLoaded || isAnalyzing) return;
    if (_controller != null && _controller!.value.isInitialized) {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _image = File(file.path);
        prediction = "";
        confidence = 0;
      });
      await _runModel(File(file.path));
    }
  }

  Future<void> _pickImage() async {
    if (!modelLoaded || isAnalyzing) return;
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        prediction = "";
        confidence = 0;
      });
      await _runModel(File(picked.path));
    }
  }

  Future<void> _runModel(File imageFile) async {
    if (_interpreter == null) return;
    setState(() => isAnalyzing = true);

    try {
      final bytes = await imageFile.readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) {
        setState(() => isAnalyzing = false);
        return;
      }

      final img.Image resized = img.copyResize(
        decoded,
        width: _modelInputSize,
        height: _modelInputSize,
        interpolation: img.Interpolation.linear,
      );

      final input = List.generate(
        1,
        (_) => List.generate(
          _modelInputSize,
          (y) => List.generate(
            _modelInputSize,
            (x) {
              final p = resized.getPixel(x, y);
              return [
                p.r.toDouble(),
                p.g.toDouble(),
                p.b.toDouble(),
              ];
            },
          ),
        ),
      );

      final output = [List.filled(labels.length, 0.0)];
      _interpreter!.run(input, output);

      final probs = output[0];
      for (int i = 0; i < probs.length; i++) {
        debugPrint('${labels[i]}: ${(probs[i] * 100).toStringAsFixed(2)}%');
      }

      double maxProb = -1.0;
      int bestIndex = 0;
      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > maxProb) {
          maxProb = probs[i];
          bestIndex = i;
        }
      }

      setState(() {
        prediction = labels[bestIndex];
        confidence = maxProb;
        isAnalyzing = false;
      });
    } catch (e) {
      debugPrint('❌ خطأ في الموديل: $e');
      setState(() => isAnalyzing = false);
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      prediction = "";
      confidence = 0;
      isAnalyzing = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF594020),
            padding: EdgeInsets.only(
              top: topPadding + 8,
              bottom: 12,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('camera.scanner'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('camera.gallery'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : (_controller != null && _controller!.value.isInitialized)
                      ? CameraPreview(_controller!)
                      : const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white),
                        ),
            ),
          ),
          if (isAnalyzing)
            Container(
              color: const Color(0xFF002319),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('camera.analyzing'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (prediction.isNotEmpty && !isAnalyzing)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: confidence > 0.7
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          confidence > 0.7
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          color: confidence > 0.7
                              ? const Color(0xFF002319)
                              : Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prediction,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF002319),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr(
                                'camera.confidence',
                                namedArgs: {
                                  'percent':
                                      '${(confidence * 100).toStringAsFixed(1)}',
                                },
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: confidence,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      color: confidence > 0.7 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TreatmentScreen(diseaseName: prediction),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: Text(context.tr('camera.treatment_details')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002319),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              top: 16,
              bottom: bottomPadding + 16,
              left: 40,
              right: 40,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.refresh,
                        color: Colors.white, size: 26),
                  ),
                ),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: (modelLoaded && !isAnalyzing)
                          ? Colors.white
                          : Colors.white30,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.6), width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: (modelLoaded && !isAnalyzing)
                          ? const Color(0xFF002319)
                          : Colors.white38,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 52, height: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}