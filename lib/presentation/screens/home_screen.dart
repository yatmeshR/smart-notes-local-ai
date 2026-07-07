import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/image_source.dart' as domain;
import '../../domain/entities/prompt_mode.dart';
import '../providers/generation_notifier.dart';
import '../providers/ocr_notifier.dart';
import '../widgets/prompt_mode_selector.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/status_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _textController = TextEditingController();
  final _questionController = TextEditingController();
  PromptMode _mode = PromptMode.summarize;

  @override
  void dispose() {
    _textController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScanImage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // web has no file path; we need raw bytes instead
    );
    final file = picked?.files.single;
    if (file == null) return;

    final domain.ImageSource source = kIsWeb
        ? domain.ImageSource(bytes: file.bytes as Uint8List?)
        : domain.ImageSource(path: file.path);

    await ref.read(ocrNotifierProvider.notifier).extractFromImage(source);

    final ocrState = ref.read(ocrNotifierProvider);
    if (ocrState.status == OcrStatus.done && ocrState.extraction != null) {
      setState(() => _textController.text = ocrState.extraction!.text);
    }
  }

  void _runGeneration() {
    ref.read(generationNotifierProvider.notifier).run(
          mode: _mode,
          sourceText: _textController.text,
          question: _questionController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrNotifierProvider);
    final generation = ref.watch(generationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Notes — Local AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ollama server settings',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const SettingsDialog(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusBanner(),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: ocrState.status == OcrStatus.extracting
                      ? null
                      : _pickAndScanImage,
                  icon: const Icon(Icons.image_search),
                  label: Text(
                    ocrState.status == OcrStatus.extracting
                        ? 'Scanning...'
                        : 'Scan Image (OCR)',
                  ),
                ),
                if (ocrState.status == OcrStatus.error) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ocrState.errorMessage ?? 'OCR failed',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste text here, or scan an image above...',
                ),
              ),
            ),
            const SizedBox(height: 12),
            PromptModeSelector(
              selected: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
            ),
            if (_mode == PromptMode.ask) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Your question about the text above...',
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: generation.status == GenerationStatus.streaming
                  ? null
                  : _runGeneration,
              child: Text(
                generation.status == GenerationStatus.streaming
                    ? 'Generating...'
                    : 'Run',
              ),
            ),
            const SizedBox(height: 12),
            if (generation.text.isNotEmpty ||
                generation.status == GenerationStatus.error)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  generation.status == GenerationStatus.error
                      ? 'Error: ${generation.errorMessage}'
                      : generation.text,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
