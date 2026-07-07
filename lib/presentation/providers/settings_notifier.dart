import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ollamaUrlKey = 'ollama_base_url';

/// Sensible starting point per platform. All of these are *guesses* the
/// user can override in Settings -- only the desktop default is likely to
/// work out of the box, since Ollama typically runs on the same machine.
/// Mobile/web need Ollama reachable over the network (e.g. your PC's LAN
/// IP), which only the user knows.
String _defaultOllamaUrl() {
  if (kIsWeb) return 'http://localhost:11434';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // 10.0.2.2 is the Android emulator's alias for the host machine's
      // localhost. Real devices will need a LAN IP instead.
      return 'http://10.0.2.2:11434';
    default:
      return 'http://localhost:11434';
  }
}

class SettingsState {
  final String ollamaBaseUrl;
  final bool loaded;

  const SettingsState({required this.ollamaBaseUrl, this.loaded = false});
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(ollamaBaseUrl: _defaultOllamaUrl())) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_ollamaUrlKey);
    state = SettingsState(
      ollamaBaseUrl: saved ?? _defaultOllamaUrl(),
      loaded: true,
    );
  }

  Future<void> updateOllamaBaseUrl(String url) async {
    final trimmed = url.trim();
    state = SettingsState(ollamaBaseUrl: trimmed, loaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ollamaUrlKey, trimmed);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
