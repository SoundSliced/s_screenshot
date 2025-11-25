import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Maker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScreenshotDemo(),
    );
  }
}

class ScreenshotDemo extends StatefulWidget {
  const ScreenshotDemo({super.key});

  @override
  State<ScreenshotDemo> createState() => _ScreenshotDemoState();
}

class _ScreenshotDemoState extends State<ScreenshotDemo> {
  final GlobalKey _screenshotKey = GlobalKey();
  String _status = 'Ready to capture';
  String? _base64Result;
  File? _savedFile;
  bool _isCapturing = false;

  Future<void> _captureAsBase64() async {
    setState(() {
      _isCapturing = true;
      _status = 'Capturing as base64...';
      _base64Result = null;
      _savedFile = null;
    });

    try {
      final result = await ScreenshotMaker.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          pixelRatio: 3.0,
          resultType: ScreenshotResultType.base64,
          shouldShowDebugLogs: true,
        ),
      );

      setState(() {
        _base64Result = result as String;
        _status = 'Captured! Base64 length: ${_base64Result!.length}';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _captureAsBytes() async {
    setState(() {
      _isCapturing = true;
      _status = 'Capturing as bytes...';
      _base64Result = null;
      _savedFile = null;
    });

    try {
      final result = await ScreenshotMaker.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          pixelRatio: 2.0,
          resultType: ScreenshotResultType.bytes,
          shouldShowDebugLogs: true,
        ),
      );

      final bytes = result as List<int>;
      setState(() {
        _status = 'Captured! Bytes length: ${bytes.length}';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _captureAsFile() async {
    setState(() {
      _isCapturing = true;
      _status = 'Capturing and saving to file...';
      _base64Result = null;
      _savedFile = null;
    });

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await ScreenshotMaker.capture(
        _screenshotKey,
        config: ScreenshotConfig(
          pixelRatio: 3.0,
          resultType: ScreenshotResultType.file,
          filePath: filePath,
          shouldShowDebugLogs: true,
        ),
      );

      final file = result as File;
      setState(() {
        _savedFile = file;
        _status = 'Saved to: ${file.path}';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _captureWithDelay() async {
    setState(() {
      _isCapturing = true;
      _status = 'Waiting 2 seconds before capture...';
      _base64Result = null;
      _savedFile = null;
    });

    try {
      final result = await ScreenshotMaker.capture(
        _screenshotKey,
        config: const ScreenshotConfig(
          pixelRatio: 3.0,
          resultType: ScreenshotResultType.base64,
          captureDelay: Duration(seconds: 2),
          shouldShowDebugLogs: true,
        ),
      );

      setState(() {
        _base64Result = result as String;
        _status =
            'Captured with delay! Base64 length: ${_base64Result!.length}';
      });
    } on ScreenshotException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Screenshot Maker Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget to capture
            RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Capture This Widget!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateTime.now().toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Capture buttons
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureAsBase64,
              icon: const Icon(Icons.text_fields),
              label: const Text('Capture as Base64'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureAsBytes,
              icon: const Icon(Icons.memory),
              label: const Text('Capture as Bytes'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureAsFile,
              icon: const Icon(Icons.save),
              label: const Text('Capture and Save to File'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureWithDelay,
              icon: const Icon(Icons.timer),
              label: const Text('Capture with 2s Delay'),
            ),
            const SizedBox(height: 24),

            // Preview
            if (_base64Result != null) ...[
              const Text(
                'Preview (Base64):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uri.parse('data:image/png;base64,$_base64Result')
                        .data!
                        .contentAsBytes(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
            if (_savedFile != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Saved File Preview:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _savedFile!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
