
## 3.2.0
- **`s_screenshot` performance improvements**:
  - Fixed `ui.Image` memory leak — native GPU resources are now properly disposed after byte extraction
  - Base64 encoding is now offloaded to a separate isolate via `compute()` on native platforms to avoid blocking the UI thread (falls back to main thread on web where isolates aren't available)
  - Replaced `Future.microtask(() {})` with `WidgetsBinding.instance.endOfFrame` for more reliable rendering pipeline synchronization
  - Fixed `ByteData` buffer view to use precise `offsetInBytes`/`lengthInBytes` instead of unbounded `asUint8List()`
  - Added `_chunkedBase64Encode()` method for chunked base64 encoding on web — processes in 192KB chunks with event loop yields to keep animations running


## 3.1.0
- `s_packages` dependency upgraded to ^1.3.0
- Fixed `ui.Image` memory leak — native GPU resources are now properly disposed after byte extraction
- Base64 encoding is now offloaded to a separate isolate via `compute()` on native platforms to avoid blocking the UI thread (falls back to main thread on web where isolates aren't available)
- Replaced `Future.microtask(() {})` with `WidgetsBinding.instance.endOfFrame` for more reliable rendering pipeline synchronization
- Fixed `ByteData` buffer view to use precise `offsetInBytes`/`lengthInBytes` instead of unbounded `asUint8List()`

## 3.0.0
- package no longer holds the source code for it, but exports/exposes the `s_packages` package instead, which will hold this package's latest source code.
- The only future changes to this package will be made via `s_packages` package dependency upgrades, in order to bring the new fixes or changes to this package
- dependent on `s_packages`: ^1.1.2



## 2.0.0 - Breaking: Unified Cross-Platform File Saving Release

### ⚠️ BREAKING CHANGES

**This is a major breaking release.** Carefully review the migration guide below before upgrading.

#### Removed APIs
- **Removed**: `ScreenshotResultType.file` enum value
- **Removed**: `ScreenshotConfig.filePath` parameter

These were the methods to directly save files to disk using `path_provider`. All file operations now use the unified download mechanism with callbacks.

#### Migration Required for File Operations

If you were using the `file` result type in v1.0.0:

**v1.0.0 (Old - No longer works):**
```dart
final file = await SScreenshot.capture(
  _key,
  config: ScreenshotConfig(
    resultType: ScreenshotResultType.file,
    filePath: '/path/to/screenshot.png',
  ),
) as File;
```

**v2.0.0 (New - Required):**
```dart
await SScreenshot.captureAndDownload(
  _key,
  fileName: 'screenshot.png',
  fileSaverCallback: kIsWeb ? (bytes, name) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      mimeType: MimeType.png,
    );
  } : null,
  pathProviderCallback: !kIsWeb ? (bytes, name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  } : null,
);
```

### 🎉 New Features

- **Unified Cross-Platform API**: Single callback-based approach for all platforms (web, mobile, desktop)
- **New Methods**:
  - `downloadScreenshot()`: Download screenshot bytes cross-platform using callbacks
  - `captureAndDownload()`: Convenience method combining capture + download in one step
- **New Result Type**: `ScreenshotResultType.download` as primary file-saving approach
- **Callback-Based Architecture**: Flexible platform handling without package updates
- **Better Separation of Concerns**: Package handles capture, callbacks handle platform details

### 📦 Dependencies

- `universal_io: ^2.2.2`: Unified File API across platforms
- `file_saver: ^0.3.1`: Cross-platform file downloads
- `path_provider: ^2.1.0`: Native file directory access (optional, for native callbacks)

These are re-exported from the main package for convenience.

### 📖 Documentation

- Updated README with breaking changes and migration guide
- Added [IOS_MACOS_SETUP.md](IOS_MACOS_SETUP.md) guide for platform configuration
- Comprehensive examples for callback-based approach
- Platform-specific error messages with guidance

### 🧪 Testing

- Updated all tests to use new API
- New tests for download methods
- Tests verify callback requirements
- All tests passing on web, iOS, Android, Windows, macOS, and Linux

### Why This Breaking Change?

1. **Single API**: One way to save files across all platforms instead of platform-specific code
2. **Better Flexibility**: Callbacks allow custom implementations without package updates
3. **Cleaner Code**: No conditional imports or platform-specific logic in user code
4. **Consistent UX**: Web and native have identical file download experience
5. **Reduced Complexity**: Removed confusing mix of direct file saves and downloads

### Unaffected APIs

The following v1.0.0 APIs remain **unchanged and fully compatible**:

```dart
// Base64 capture still works exactly the same
final base64 = await SScreenshot.capture(_key);

// Bytes capture still works exactly the same
final bytes = await SScreenshot.capture(
  _key,
  config: const ScreenshotConfig(
    resultType: ScreenshotResultType.bytes,
  ),
);

// All configuration options for capture still work
final screenshot = await SScreenshot.capture(
  _key,
  config: ScreenshotConfig(
    pixelRatio: 3.0,
    captureDelay: Duration(milliseconds: 500),
  ),
);
```

---

## 1.0.0 - Initial Release

* Capture widgets as screenshots with multiple output formats (base64, bytes, file)
* Configurable pixel ratio for quality control
* Support for PNG and raw RGBA formats
* Optional capture delay for animations
* Robust error handling with ScreenshotException
* Widget validation before capture
* Comprehensive example app and tests
* MIT License
