import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tp3_v2/utils/plate.dart';

typedef OnPlateFound = void Function(String plate);

class PlateOcrCamera extends StatefulWidget {
  final OnPlateFound onPlateFound;
  const PlateOcrCamera({super.key, required this.onPlateFound});

  @override
  State<PlateOcrCamera> createState() => _PlateOcrCameraState();
}

class _PlateOcrCameraState extends State<PlateOcrCamera> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _initializing = true;
  bool _busy = false;
  final _recognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recognizer.close();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final back = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
      _controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _initializing = false);
    } catch (e) {
      setState(() => _initializing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo inicializar la cámara: $e')),
      );
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _controller!.takePicture();
      final input = InputImage.fromFilePath(file.path);
      final result = await _recognizer.processImage(input);

      // Unimos todo el texto detectado y buscamos una patente válida
      final buffer = StringBuffer();
      for (final block in result.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }
      final allText = PlateValidator.normalize(buffer.toString());
      final plate = _extractPlate(allText);

      if (plate != null) {
        widget.onPlateFound(plate);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se detectó una patente válida. Intentá otra vez.')),
          );
        }
      }

      // Limpieza opcional del archivo temporal
      try { File(file.path).deleteSync(); } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de OCR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Busca la primera coincidencia de una patente válida dentro del string
  String? _extractPlate(String text) {
    // tokens primero para mayor precisión
    final tokens = text.split(RegExp(r'[^A-Z0-9]')).where((t) => t.isNotEmpty);
    for (final t in tokens) {
      if (PlateValidator.isValid(t)) return PlateValidator.normalize(t);
    }
    // fallback regex
    final newer = RegExp(r'[A-Z]{2}\d{3}[A-Z]{2}'); // AB123CD
    final old = RegExp(r'[A-Z]{3}\d{3}');          // ABC123
    final m1 = newer.firstMatch(text);
    if (m1 != null) return m1.group(0);
    final m2 = old.firstMatch(text);
    if (m2 != null) return m2.group(0);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Cámara no disponible'));
    }
    return Stack(
      children: [
        CameraPreview(_controller!),
        // Overlay indicativo
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.45),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Alineá la patente y tocá "Detectar"',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        // Botón capturar
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _busy ? null : _captureAndRecognize,
              icon: const Icon(Icons.camera),
              label: Text(_busy ? 'Procesando...' : 'Detectar patente'),
            ),
          ),
        ),
      ],
    );
  }
}