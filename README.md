# saf_util

[![pub package](https://img.shields.io/pub/v/saf_util.svg)](https://pub.dev/packages/saf_util)

Util functions for SAF (Storage Access Framework). Note that this package doesn't provide any read / write functions (go to [saf_stream](https://github.com/flutter-cavalry/saf_stream) for that).

## Usage

```dart
class SafUtil {
  /// Shows a folder picker dialog and returns the selected folder URI.
  ///
  /// [initialUri] is the initial URI to show in the dialog.
  /// [writePermission] is true if the folder should have write permission.
  /// [persistablePermission] is true if the permission should be persistable.
  Future<String?> openDirectory(
      {String? initialUri,
      bool? writePermission,
      bool? persistablePermission});

  /// Lists the contents of the specified directory URI.
  /// Returns a list of [SafDocumentFile] objects.
  ///
  /// [uri] is the URI of the directory.
  Future<List<SafDocumentFile>> list(String uri);

  /// Gets a [SafDocumentFile] object from the specified URI.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<SafDocumentFile?> documentFileFromUri(String uri, bool isDir);

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
  /// Returns the created directory as a [SafDocumentFile] object.
  ///
  /// [uri] is the URI of the directory to create.
  /// [names] is a list of directory names to create.
  Future<SafDocumentFile> mkdirp(String uri, List<String> names);

  /// Gets the child file or directory with the specified name.
  ///
  /// [uri] is the URI of the parent directory.
  /// [names] is a list of directory names to traverse.
  Future<SafDocumentFile?> child(String uri, List<String> names);

  /// Renames the specified file or directory.
  /// Returns the renamed file or directory as a [SafDocumentFile] object.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  /// [newName] is the new name of the file or directory.
  Future<SafDocumentFile> rename(String uri, bool isDir, String newName);

  /// Moves the specified file or directory to a new parent directory.
  /// Returns the moved file or directory as a [SafDocumentFile] object.
  ///
  /// [uri] is the URI of the file or directory.
  /// [parentUri] is the URI of the current parent directory.
  /// [newParentUri] is the URI of the new parent directory.
  Future<SafDocumentFile> moveTo(
      String uri, bool isDir, String parentUri, String newParentUri);

  /// Copies the specified file or directory to a new parent directory.
  /// Returns the copied file or directory as a [SafDocumentFile] object.
  ///
  /// [uri] is the URI of the file or directory.
  /// [newParentUri] is the URI of the new parent directory.
  Future<SafDocumentFile> copyTo(String uri, bool isDir, String newParentUri);

  /// Saves the thumbnail of the specified document [uri] to a local file [destPath].
  /// Image and video thumbnails are supported.
  /// Returns true if the thumbnail is saved successfully.
  ///
  /// [uri] is the URI of the document.
  /// [destPath] is the destination path to save the thumbnail.
  /// [width] is the width of the thumbnail.
  /// [height] is the height of the thumbnail.
  /// [format] is the format of the thumbnail file, default is 'jpeg'.
  /// Supported formats are 'jpeg' and 'png'.
  /// [quality] is the quality of the thumbnail file,
  /// defaults to 80 for 'jpeg' and 100 for 'png'.
  Future<bool> saveThumbnailToFile({
    required String uri,
    required double width,
    required double height,
    required String destPath,
    String? format,
    int? quality,
  });
}
```
