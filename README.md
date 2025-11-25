# screenshot_maker

A powerful and flexible Flutter package for capturing high-quality screenshots of widgets with multiple output formats and configuration options.

## Features

✨ **Multiple Output Formats**
- Base64 encoded string
- Raw bytes (Uint8List)
- Direct file save

🎨 **Configurable Options**
- Custom pixel ratio for quality control
- PNG or raw RGBA format support
- Optional capture delay for animations
- Debug logging

🛡️ **Robust Error Handling**
- Type-safe exceptions with detailed error messages
- Widget validation before capture
- Clear error reporting

🔧 **Easy to Use**
- Simple API with sensible defaults
- Backward compatible legacy method
- Comprehensive example app

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  screenshot_maker: ^1.0.0
```

## Usage

### Basic Usage (Base64)

```dart
import 'package:flutter/material.dart';
import 'package:screenshot_maker/screenshot_maker.dart';

class MyWidget extends StatelessWidget {
  final GlobalKey _screenshotKey = GlobalKey();

  Future<void> captureScreenshot() async {
    try {
      final base64String = await ScreenshotMaker.captureScreenshot(
        _screenshotKey,
        config: const ScreenshotConfig(
          resultType: ScreenshotResultType.base64,
        ),
      );
      
      print('Screenshot captured: ${base64String.length} characters');
    } on ScreenshotException catch (e) {
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _screenshotKey,
      child: Container(
        // Your widget content here
      ),
    );
  }
}
```

### Capture as Bytes

```dart
final bytes = await ScreenshotMaker.captureScreenshot(
  _screenshotKey,
  config: const ScreenshotConfig(
    resultType: ScreenshotResultType.bytes,
    pixelRatio: 2.0,
  ),
) as Uint8List;

// Use the bytes directly
await someApi.uploadImage(bytes);
```

### Save Directly to File

```dart
final file = await ScreenshotMaker.captureScreenshot(
  _screenshotKey,
  config: ScreenshotConfig(
    resultType: ScreenshotResultType.file,
    filePath: '/path/to/screenshot.png',
    pixelRatio: 3.0,
  ),
) as File;

print('Saved to: ${file.path}');
```

### Capture with Delay

Useful for waiting for animations to complete:

```dart
final screenshot = await ScreenshotMaker.captureScreenshot(
  _screenshotKey,
  config: const ScreenshotConfig(
    captureDelay: Duration(milliseconds: 500),
    resultType: ScreenshotResultType.base64,
  ),
);
```

### Custom Configuration

```dart
final screenshot = await ScreenshotMaker.captureScreenshot(
  _screenshotKey,
  config: const ScreenshotConfig(
    pixelRatio: 4.0,              // Higher quality
    format: ScreenshotFormat.png,  // PNG or rawRgba
    resultType: ScreenshotResultType.bytes,
    shouldShowDebugLogs: true,     // Enable logging
    captureDelay: Duration(seconds: 1),
  ),
);
```

## Configuration Options

### ScreenshotConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pixelRatio` | `double` | `3.0` | Pixel ratio for screenshot quality (higher = better quality but larger size) |
| `format` | `ScreenshotFormat` | `png` | Image format: `png` or `rawRgba` |
| `resultType` | `ScreenshotResultType` | `base64` | Output format: `base64`, `bytes`, or `file` |
| `filePath` | `String?` | `null` | File path (required when `resultType` is `file`) |
| `shouldShowDebugLogs` | `bool` | `false` | Enable debug logging |
| `captureDelay` | `Duration?` | `null` | Delay before capturing (useful for animations) |

### Result Types

- **`ScreenshotResultType.base64`**: Returns a `String` with base64-encoded image
- **`ScreenshotResultType.bytes`**: Returns `Uint8List` with raw image bytes
- **`ScreenshotResultType.file`**: Returns `File` object after saving to disk

## Error Handling

The package throws `ScreenshotException` with detailed error messages:

```dart
try {
  final screenshot = await ScreenshotMaker.captureScreenshot(_key);
} on ScreenshotException catch (e) {
  print('Screenshot failed: ${e.message}');
  if (e.originalError != null) {
    print('Original error: ${e.originalError}');
  }
}
```

Common errors:
- Widget not yet rendered
- Widget not wrapped in `RepaintBoundary`
- Missing file path when using `file` result type
- Failed to convert image to byte data

## Important Notes

1. **RepaintBoundary Required**: Always wrap the widget you want to capture in a `RepaintBoundary`:

```dart
RepaintBoundary(
  key: _screenshotKey,
  child: YourWidget(),
)
```

2. **Widget Must Be Rendered**: Ensure the widget is visible and rendered before capturing:

```dart
await tester.pumpAndSettle(); // In tests
await Future.delayed(Duration(milliseconds: 100)); // In production if needed
```

3. **Pixel Ratio Impact**: Higher pixel ratios produce better quality but larger file sizes:
   - `1.0`: Low quality, small size
   - `2.0`: Medium quality
   - `3.0`: High quality (default)
   - `4.0+`: Very high quality, large size

## Example

Check out the [example](example/) directory for a complete working app demonstrating all features.

To run the example:

```bash
cd example
flutter pub get
flutter run
```

## Testing

The package includes comprehensive tests. Run them with:

```bash
flutter test
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License - feel free to use this package in your projects.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Repository

https://github.com/SoundSliced/screenshot_maker
