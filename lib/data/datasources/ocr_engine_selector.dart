/// Public entry point for OCR engine selection. The conditional export
/// below picks whichever implementation file actually compiles for the
/// current target:
///   - dart.library.io available  -> desktop or mobile (decided at runtime)
///   - dart.library.io unavailable (web) -> the unsupported stub
///
/// This is resolved at COMPILE time, not runtime -- which is why it has
/// to be a file-level conditional import/export rather than a plain
/// if/else using kIsWeb. dart:io cannot be imported at all in a web
/// build, so any file that imports it (like desktop_ocr_datasource.dart)
/// must be conditionally excluded from the web build entirely.
export 'ocr_engine_selector_stub.dart'
    if (dart.library.io) 'ocr_engine_selector_io.dart';
