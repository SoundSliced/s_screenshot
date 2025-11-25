import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
part 'tools.dart';

class ScreenshotMaker {
  /// Captures a widget screenshot using the provided [key].
  ///
  /// Returns String (base64), Uint8List (bytes), or File based on [config].
  /// Throws [ScreenshotException] on failure.
  static Future<dynamic> capture(
    GlobalKey key, {
    ScreenshotConfig config = const ScreenshotConfig(),
  }) async {
    try {
      if (config.resultType == ScreenshotResultType.file &&
          (config.filePath == null || config.filePath!.isEmpty)) {
        throw ScreenshotException(
            'filePath is required when resultType is file');
      }

      // Get render object before any async operations to avoid BuildContext issues
      final context = key.currentContext;
      if (context == null) {
        throw ScreenshotException(
            'Widget is not yet rendered. Make sure the GlobalKey is attached to a widget in the tree.');
      }

      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        throw ScreenshotException(
            'RenderObject not found. Make sure the widget is visible.');
      }

      if (renderObject is! RenderRepaintBoundary) {
        throw ScreenshotException(
            'The widget must be wrapped in a RepaintBoundary.');
      }

      if (config.captureDelay != null) {
        await Future.delayed(config.captureDelay!);
      }

      // Capture the rendered widget as an image
      final boundary = renderObject;
      await Future.microtask(() {}); // Ensure rendering pipeline completes
      final image = await boundary.toImage(pixelRatio: config.pixelRatio);
      final byteData = await image.toByteData(
          format: config.format == ScreenshotFormat.png
              ? ui.ImageByteFormat.png
              : ui.ImageByteFormat.rawRgba);

      if (byteData == null) {
        throw ScreenshotException('Failed to convert image to byte data');
      }

      final buffer = byteData.buffer.asUint8List();

      if (kDebugMode && config.shouldShowDebugLogs) {
        debugPrint('Screenshot captured: ${buffer.length} bytes');
      }
      switch (config.resultType) {
        case ScreenshotResultType.base64:
          final base64String = base64Encode(buffer);
          if (kDebugMode && config.shouldShowDebugLogs) {
            debugPrint('Base64 length: ${base64String.length}');
          }
          return base64String;

        case ScreenshotResultType.bytes:
          return buffer;

        case ScreenshotResultType.file:
          final file = File(config.filePath!);
          await file.writeAsBytes(buffer);
          if (kDebugMode && config.shouldShowDebugLogs) {
            debugPrint('Screenshot saved to: ${file.path}');
          }
          return file;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Screenshot capture failed: $e');
      }
      if (e is ScreenshotException) {
        rethrow;
      }
      throw ScreenshotException('Failed to capture screenshot', e);
    }
  }
}
