class OcrExtraction {
  final String text;

  const OcrExtraction({required this.text});

  bool get isEmpty => text.trim().isEmpty;
}
