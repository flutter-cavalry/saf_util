import 'saf_util_platform_interface.dart';

class SafUtil {
  /// Shows a folder picker dialog and returns the selected folder URI.
  Future<String?> openDirectory(
      {String? initialUri,
      bool? writePermission,
      bool? persistablePermission}) {
    return SafUtilPlatform.instance.openDirectory(
        initialUri: initialUri,
        writePermission: writePermission,
        persistablePermission: persistablePermission);
  }

  /// Lists the contents of the specified directory URI.
  ///
  /// [uri] is the URI of the directory.
  Future<List<SafDocumentFile>> list(String uri) {
    return SafUtilPlatform.instance.list(uri);
  }

  /// Gets a [SafDocumentFile] object from the specified URI.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<SafDocumentFile?> documentFileFromUri(String uri, bool isDir) {
    return SafUtilPlatform.instance.documentFileFromUri(uri, isDir);
  }

  /// Checks if the specified file or directory exists.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<bool> exists(String uri, bool isDir) {
    return SafUtilPlatform.instance.exists(uri, isDir);
  }

  /// Deletes the specified file or directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  Future<void> delete(String uri, bool isDir) {
    return SafUtilPlatform.instance.delete(uri, isDir);
  }

  /// Creates a directory and all its parent directories.
  ///
  /// [uri] is the URI of the directory to create.
  /// [path] is the list of parent directory names.
  Future<SafDocumentFile> mkdirp(String uri, List<String> names) {
    return SafUtilPlatform.instance.mkdirp(uri, names);
  }

  /// Gets the child file or directory with the specified name.
  ///
  /// [uri] is the URI of the parent directory.
  /// [name] is the name of the child file or directory.
  Future<SafDocumentFile?> child(String uri, List<String> names) {
    return SafUtilPlatform.instance.child(uri, names);
  }

  /// Renames the specified file or directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [isDir] is true if the URI is a directory.
  /// [newName] is the new name of the file or directory.
  Future<SafDocumentFile> rename(String uri, bool isDir, String newName) {
    return SafUtilPlatform.instance.rename(uri, isDir, newName);
  }

  /// Moves the specified file or directory to a new parent directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [parentUri] is the URI of the current parent directory.
  /// [newParentUri] is the URI of the new parent directory.
  Future<SafDocumentFile> moveTo(
      String uri, bool isDir, String parentUri, String newParentUri) {
    return SafUtilPlatform.instance.moveTo(uri, isDir, parentUri, newParentUri);
  }

  /// Copies the specified file or directory to a new parent directory.
  ///
  /// [uri] is the URI of the file or directory.
  /// [newParentUri] is the URI of the new parent directory.
  Future<SafDocumentFile> copyTo(String uri, bool isDir, String newParentUri) {
    return SafUtilPlatform.instance.copyTo(uri, isDir, newParentUri);
  }
}
