part of 'screenshot_maker.dart';

/// Exception for screenshot capture failures.
class ScreenshotException implements Exception {
  final String message;
  final dynamic originalError;

  ScreenshotException(this.message, [this.originalError]);

  @override
  String toString() =>
      'ScreenshotException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Image format for the screenshot.
enum ScreenshotFormat {
  png,
  rawRgba,
}

/// Output type for captured screenshot.
enum ScreenshotResultType {
  /// Returns base64 encoded string
  base64,

  /// Returns Uint8List bytes
  bytes,

  /// Returns File (requires path parameter)
  file,
}

/// Configuration options for screenshot capture.
class ScreenshotConfig {
  /// Pixel ratio (higher = better quality, larger size).
  final double pixelRatio;

  /// Image format.
  final ScreenshotFormat format;

  /// Output type.
  final ScreenshotResultType resultType;

  /// File path (required for file output).
  final String? filePath;

  /// Enable debug logging.
  final bool shouldShowDebugLogs;

  /// Delay before capture (allows animations to complete).
  final Duration? captureDelay;

  const ScreenshotConfig({
    this.pixelRatio = 3.0,
    this.format = ScreenshotFormat.png,
    this.resultType = ScreenshotResultType.base64,
    this.filePath,
    this.shouldShowDebugLogs = false,
    this.captureDelay,
  });
}
