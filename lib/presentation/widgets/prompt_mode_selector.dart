import 'package:flutter/material.dart';
import '../../domain/entities/prompt_mode.dart';

class PromptModeSelector extends StatelessWidget {
  final PromptMode selected;
  final ValueChanged<PromptMode> onChanged;

  const PromptModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Summarize'),
          selected: selected == PromptMode.summarize,
          onSelected: (_) => onChanged(PromptMode.summarize),
        ),
        ChoiceChip(
          label: const Text('Action Items'),
          selected: selected == PromptMode.actionItems,
          onSelected: (_) => onChanged(PromptMode.actionItems),
        ),
        ChoiceChip(
          label: const Text('Ask a Question'),
          selected: selected == PromptMode.ask,
          onSelected: (_) => onChanged(PromptMode.ask),
        ),
      ],
    );
  }
}
