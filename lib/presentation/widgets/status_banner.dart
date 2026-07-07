import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/injection.dart';

class StatusBanner extends ConsumerWidget {
  const StatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llmAvailable = ref.watch(llmAvailableProvider);
    final ocrAvailable = ref.watch(ocrAvailableProvider);

    final issues = <String>[];
    llmAvailable.whenData((ok) {
      if (!ok) issues.add('Ollama is not reachable — run "ollama serve".');
    });
    ocrAvailable.whenData((ok) {
      if (!ok) {
        issues.add(
          'OCR is unavailable — on desktop, install Tesseract and ensure '
          "it's on PATH; in the browser, check that Tesseract.js loaded "
          '(see console for errors).',
        );
      }
    });

    if (issues.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: issues.map((i) => Text('⚠ $i')).toList(),
      ),
    );
  }
}
