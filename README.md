# Smart Notes — Local AI (Ollama + Tesseract OCR)

A local-first Flutter desktop app: scan a document/receipt with OCR, then
summarize it, extract action items, or ask questions about it — all
powered by a locally-running LLM. No cloud API keys, no data leaving your
machine.

## Why this project

- **Ollama** — talks to a local LLM over its REST API, with real streaming
  token-by-token responses (not just await-and-print).
- **Tesseract OCR** — extracts text from images via the system binary,
  keeping the whole pipeline offline.
- **Clean Architecture** — domain/data/presentation layering, so business
  logic is fully decoupled from Flutter and from which OCR/LLM provider
  is used underneath.
- **Riverpod** — used for both dependency injection (composition root)
  and state management (StateNotifiers).

## Setup

### 1. Install Ollama
Download from https://ollama.com, then:
```bash
ollama pull llama3.2
ollama serve
```

### 2. Install Tesseract
```bash
# macOS
brew install tesseract

# Linux (Debian/Ubuntu)
sudo apt install tesseract-ocr

# Windows
choco install tesseract
# or use the official installer: https://github.com/UB-Mannheim/tesseract/wiki
```

### 3. Run the app
```bash
flutter pub get
flutter run -d macos   # or -d windows / -d linux
```

The app checks both services on startup and shows a warning banner if
either isn't reachable.

## How it works

1. **Scan** — pick an image file; it's passed to the local `tesseract`
   binary via `Process.run`, which writes extracted text to a temp file
   that's read back into the app.
2. **Edit** — the extracted text lands in an editable text box (OCR is
   never perfect — this lets you fix it before sending to the LLM).
3. **Process** — choose Summarize / Extract Action Items / Ask a Question,
   which builds a prompt and streams it to Ollama's `/api/generate`
   endpoint, rendering tokens as they arrive.

## Architecture — Clean Architecture + Riverpod

```
lib/
  core/errors/               Shared exception types (OcrException, LlmException)

  domain/                    Pure Dart. No Flutter, no http, no dart:io.
    entities/                  OcrExtraction, PromptMode
    repositories/              Abstract contracts (OcrRepository, LlmRepository)
    usecases/                  One class per action:
                                  ExtractTextFromImage, GenerateText, BuildPrompt

  data/                      Implements the domain contracts
    datasources/                TesseractDataSource (Process calls)
                                 OllamaDataSource (HTTP + streaming)
    repositories/                OcrRepositoryImpl, LlmRepositoryImpl
                                 (thin adapters: datasource -> domain entity)

  presentation/              Flutter + Riverpod
    providers/
      injection.dart            Composition root — wires datasources ->
                                 repositories -> usecases via Riverpod Providers
      ocr_notifier.dart         StateNotifier depending only on ExtractTextFromImage
      generation_notifier.dart  StateNotifier depending only on GenerateText/BuildPrompt
    widgets/                   StatusBanner, PromptModeSelector
    screens/                   HomeScreen
```

**The dependency rule:** arrows only point inward. `domain/` never
imports from `data/` or `presentation/`. Both `data/` and
`presentation/` depend on `domain/`'s abstractions, never on each other
directly.

**Why this matters in practice:** `OcrNotifier` and `GenerationNotifier`
have zero knowledge that Tesseract or Ollama exist — they only see the
use cases `ExtractTextFromImage` and `GenerateText`. Swap Tesseract for
a cloud OCR API, or Ollama for OpenAI: rewrite one file in `data/` and
change one line in `injection.dart`. Nothing in `presentation/` changes.
Each layer is also independently unit-testable — `BuildPrompt` or
`OcrRepositoryImpl` can be tested with zero Flutter widgets involved.

## Possible extensions
- Save extracted notes to local storage (Drift/Isar) for a history view
- Support multiple Ollama models via a dropdown
- Batch OCR for multi-page documents
- Package Tesseract detection into a proper first-run setup wizard
- Add unit tests for each domain use case (this architecture makes that easy)

## Cross-platform support (Web, Android, iOS, Desktop)

### OCR — three engines behind one interface

`OcrEngineDataSource` is implemented three ways, selected at **compile
time** via conditional imports (`ocr_engine_selector.dart`):

| Platform | Engine | Notes |
|---|---|---|
| Windows/macOS/Linux | `DesktopOcrDataSource` | Shells out to system Tesseract |
| Android/iOS | `MobileOcrDataSource` | Google ML Kit, on-device, ships with the app |
| Web | `UnsupportedOcrDataSource` | No engine available; reports unavailable with a clear message |

This uses Dart's `dart.library.io` conditional export, because `dart:io`
cannot even be *imported* in a web build — a runtime `if (kIsWeb)` isn't
enough, the file itself has to be swapped at compile time.

### Ollama — configurable server URL

`localhost` only works when Ollama runs on the same device as the app —
true for desktop, false for a phone or a browser on another machine.
The server URL is now user-configurable (gear icon in the app bar),
persisted via `shared_preferences`, with platform-aware defaults in
`settings_notifier.dart`.

For mobile/web to reach Ollama on your PC:
```bash
OLLAMA_HOST=0.0.0.0 ollama serve
```
Then set the app's server URL to your PC's LAN IP, e.g.
`http://192.168.1.42:11434`. Phone and PC must be on the same network.

### Setting up mobile

```bash
flutter run -d android   # or -d ios (requires macOS + Xcode)
```

ML Kit's text recognizer is bundled automatically via the
`google_mlkit_text_recognition` package — no extra native setup beyond
standard Android/iOS permissions for file/camera access if you extend
image picking to use the camera.

### Setting up web

```bash
flutter run -d chrome
```

OCR will show as unavailable (by design). Ollama needs
`OLLAMA_HOST=0.0.0.0` and the browser's CORS behavior may also require
`OLLAMA_ORIGINS=*` when starting Ollama, since browsers enforce CORS in
a way desktop/mobile HTTP clients don't.
