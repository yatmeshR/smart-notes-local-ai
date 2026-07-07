import 'dart:typed_data';

/// Represents a picked image in whichever form the current platform
/// actually provides. Desktop and mobile file pickers give a real file
/// [path]; the web file picker gives raw [bytes] instead (browsers don't
/// expose a filesystem path for security reasons). Exactly one of the
/// two should be set for a given platform, but both are nullable so this
/// one type works everywhere instead of branching at every call site.
class ImageSource {
  final String? path;
  final Uint8List? bytes;

  const ImageSource({this.path, this.bytes});

  bool get hasPath => path != null;
  bool get hasBytes => bytes != null;
}
