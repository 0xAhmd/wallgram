import 'dart:io';

void main() {
  final directory = Directory.current;

  // File extension to scan (Dart files)
  final dartFiles =
      directory
          .listSync(recursive: true)
          .where(
            (f) =>
                f is File &&
                f.path.endsWith('.dart') &&
                !f.path.contains('/.dart_tool/') &&
                !f.path.contains('/build/') &&
                !f.path.contains('/.pub-cache/'),
          )
          .cast<File>();

  for (final file in dartFiles) {
    final originalContent = file.readAsStringSync();

    // RegExp to match print(...) including multiline and nested quotes
    final modifiedContent = originalContent.replaceAllMapped(
      RegExp(r'^\s*print\s*\((.|\s)*?\);\s*$', multiLine: true),
      (match) => '',
    );

    // Save the file if changed
    if (originalContent != modifiedContent) {
      file.writeAsStringSync(modifiedContent);
    }
  }
}
