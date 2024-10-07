# saf_util

[![pub package](https://img.shields.io/pub/v/saf_util.svg)](https://pub.dev/packages/saf_util)

Util functions for SAF (Storage Access Framework). Note that this package doesn't provide any read / write functions (go to [saf_stream](https://github.com/flutter-cavalry/saf_stream) for that).

## Usage

```dart
class SafUtil {
  /// Shows a folder picker dialog and returns the selected folder URI.
  Future<String?> openDirectory({String? initialUri});

  /// Lists the contents of the specified directory URI.
  ///
  /// [uri] is the URI of the directory.
  Future<List<SafDocumentFile>> list(String uri);

  /// Gets a [SafDocumentFile] object from the specified URI.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<SafDocumentFile> documentFileFromUri(String uri, bool isDir);

  /// Checks if the specified file or directory exists.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<bool> exists(String uri, bool isDir);

  /// Deletes the specified file or directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<void> delete(String uri, bool isDir);

  /// Creates a directory and all its parent directories.
  ///
  /// [uri] is the URI of the directory to create.
  /// [path] is the list of parent directory names.
  Future<SafDocumentFile> mkdirp(String uri, List<String> names);

  /// Gets the child file or directory with the specified name.
  ///
  /// [uri] is the URI of the parent directory.
  /// [name] is the name of the child file or directory.
  Future<SafDocumentFile?>child(String uri, List<String> names);

  /// Renames the specified file or directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  /// [newName] is the new name of the file or directory.
  Future<SafDocumentFile> rename(String uri, bool isDir, String newName);

  /// Moves the specified file or directory to a new parent directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [parentUri] is the URI of the current parent directory.
  /// [newParentUri] is the URI of the new parent directory.
  Future<SafDocumentFile> moveTo(String uri, String parentUri, String newParentUri);

  /// Copies the specified file or directory to a new parent directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [newParentUri] is the URI of the new parent directory.
  Future<SafDocumentFile> copyTo(String uri, bool isDir, String newParentUri);
}
```
