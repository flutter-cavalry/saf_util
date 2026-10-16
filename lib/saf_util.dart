import 'saf_util_platform_interface.dart';

export 'saf_util_platform_interface.dart' show SafDocumentFile;

/// Utilities for picking and managing documents through Android's Storage
/// Access Framework (SAF).
class SafUtil {
  /// Opens a folder picker and returns the selected folder.
  ///
  /// Returns `null` if the user cancels. [initialUri] optionally selects the
  /// initial location. [writePermission] requests write access, and
  /// [persistablePermission] requests access that can be retained.
  Future<SafDocumentFile?> pickDirectory({
    String? initialUri,
    bool? writePermission,
    bool? persistablePermission,
  }) {
    return SafUtilPlatform.instance.pickDirectory(
      initialUri: initialUri,
      writePermission: writePermission,
      persistablePermission: persistablePermission,
    );
  }

  /// Opens a file picker and returns the selected file.
  ///
  /// Returns `null` if the user cancels. [initialUri] optionally selects the
  /// initial location. [mimeTypes] optionally restricts the selectable files.
  Future<SafDocumentFile?> pickFile({
    String? initialUri,
    List<String>? mimeTypes,
  }) {
    return SafUtilPlatform.instance.pickFile(
      initialUri: initialUri,
      mimeTypes: mimeTypes,
    );
  }

  /// Opens a file picker and returns the selected files.
  ///
  /// Returns `null` if the user cancels. [initialUri] optionally selects the
  /// initial location. [mimeTypes] optionally restricts the selectable files.
  /// Set [multiple] to `false` to allow only one selection.
  Future<List<SafDocumentFile>?> pickFiles({
    String? initialUri,
    List<String>? mimeTypes,
    bool multiple = true,
  }) {
    return SafUtilPlatform.instance.pickFiles(
      initialUri: initialUri,
      mimeTypes: mimeTypes,
      multiple: multiple,
    );
  }

  /// Opens Android's system photo picker and returns the selected media.
  ///
  /// Returns `null` if the user cancels. This API requires Android 13 (API 33)
  /// or later. Set [multiple] to `false` to allow only one selection. [mode]
  /// must be `photo`, `video`, or `all`.
  Future<List<SafDocumentFile>?> pickMedia({
    bool multiple = true,
    String mode = 'all',
  }) {
    return SafUtilPlatform.instance.pickMedia(multiple: multiple, mode: mode);
  }

  /// Lists the immediate contents of the directory identified by [uri].
  Future<List<SafDocumentFile>> list(String uri) {
    return SafUtilPlatform.instance.list(uri);
  }

  /// Creates a [SafDocumentFile] for [uri].
  ///
  /// Set [isDir] to indicate whether [uri] identifies a directory. If it is
  /// `null`, the type is detected automatically.
  Future<SafDocumentFile?> documentFileFromUri(String uri, bool? isDir) {
    return SafUtilPlatform.instance.documentFileFromUri(uri, isDir);
  }

  /// Returns a [SafDocumentFile] for [uri], or `null` if it does not exist.
  ///
  /// Set [isDir] to indicate whether [uri] identifies a directory. If it is
  /// `null`, the type is detected automatically. When [throws] is `true`, an
  /// exception is thrown if the URI does not exist or cannot be accessed.
  Future<SafDocumentFile?> stat(String uri, bool? isDir, {bool? throws}) {
    return SafUtilPlatform.instance.stat(uri, isDir, throws: throws);
  }

  /// Checks whether the file or directory identified by [uri] exists.
  ///
  /// Set [isDir] to `true` if [uri] identifies a directory.
  Future<bool> exists(String uri, bool isDir) {
    return SafUtilPlatform.instance.exists(uri, isDir);
  }

  /// Deletes the file or directory identified by [uri].
  ///
  /// Set [isDir] to `true` if [uri] identifies a directory.
  Future<void> delete(String uri, bool isDir) {
    return SafUtilPlatform.instance.delete(uri, isDir);
  }

  /// Creates the directory path described by [names] under [uri].
  ///
  /// Returns the final directory in the path.
  Future<SafDocumentFile> mkdirp(String uri, List<String> names) {
    return SafUtilPlatform.instance.mkdirp(uri, names);
  }

  /// Finds a child file or directory by traversing [names] under [uri].
  ///
  /// Returns `null` if the child path does not exist. An empty [names] list
  /// returns the document identified by [uri].
  Future<SafDocumentFile?> child(String uri, List<String> names) {
    return SafUtilPlatform.instance.child(uri, names);
  }

  /// Renames the file or directory identified by [uri] to [newName].
  ///
  /// Returns the renamed document. Set [isDir] to `true` if [uri] identifies a
  /// directory.
  Future<SafDocumentFile> rename(String uri, bool isDir, String newName) {
    return SafUtilPlatform.instance.rename(uri, isDir, newName);
  }

  /// Moves a document to a different parent directory.
  ///
  /// Returns the moved document. [parentUri] identifies its current parent and
  /// [newParentUri] identifies the destination parent. Set [isDir] to `true`
  /// if [uri] identifies a directory.
  Future<SafDocumentFile> moveTo(
    String uri,
    bool isDir,
    String parentUri,
    String newParentUri,
  ) {
    return SafUtilPlatform.instance.moveTo(uri, isDir, parentUri, newParentUri);
  }

  /// Copies a document to a different parent directory.
  ///
  /// Returns the copied document. Set [isDir] to `true` if [uri] identifies a
  /// directory.
  Future<SafDocumentFile> copyTo(String uri, bool isDir, String newParentUri) {
    return SafUtilPlatform.instance.copyTo(uri, isDir, newParentUri);
  }

  /// Saves an image or video thumbnail for [uri] to [destPath].
  ///
  /// Returns `true` if a thumbnail was saved, or `false` if none was available.
  /// [width] and [height] set the maximum dimensions. [format] can be `jpeg`
  /// (the default) or `png`. [quality] defaults to 80 for JPEG and 100 for PNG.
  Future<bool> saveThumbnailToFile({
    required String uri,
    required int width,
    required int height,
    required String destPath,
    String? format,
    int? quality,
  }) {
    return SafUtilPlatform.instance.saveThumbnailToFile(
      uri: uri,
      width: width,
      height: height,
      destPath: destPath,
      format: format,
      quality: quality,
    );
  }

  /// Deprecated URI-returning picker methods. Use the corresponding `pick*`
  /// methods instead.

  /// Opens a folder picker and returns the selected folder URI.
  ///
  /// [initialUri] optionally selects the initial location. [writePermission]
  /// requests write access, and [persistablePermission] requests retainable
  /// access.
  @Deprecated('Use [pickDirectory] instead, which returns a [SafDocumentFile].')
  Future<String?> openDirectory({
    String? initialUri,
    bool? writePermission,
    bool? persistablePermission,
  }) {
    return SafUtilPlatform.instance.openDirectory(
      initialUri: initialUri,
      writePermission: writePermission,
      persistablePermission: persistablePermission,
    );
  }

  /// Shows a file picker dialog and returns the selected file URI.
  /// This calls [openFiles] with [multiple] set to false.
  ///
  /// [initialUri] is the initial URI to show in the dialog.
  /// [mimeTypes] is a list of MIME types to filter the files.
  @Deprecated('Use [pickFile] instead, which returns a [SafDocumentFile].')
  Future<String?> openFile({String? initialUri, List<String>? mimeTypes}) {
    return SafUtilPlatform.instance.openFile(
      initialUri: initialUri,
      mimeTypes: mimeTypes,
    );
  }

  /// Shows a file picker dialog and returns a list of selected file URIs.
  ///
  /// [initialUri] is the initial URI to show in the dialog.
  /// [mimeTypes] is a list of MIME types to filter the files.
  @Deprecated('Use [pickFiles] instead, which returns a [SafDocumentFile].')
  Future<List<String>?> openFiles({
    String? initialUri,
    List<String>? mimeTypes,
    bool multiple = true,
  }) {
    return SafUtilPlatform.instance.openFiles(
      initialUri: initialUri,
      mimeTypes: mimeTypes,
      multiple: multiple,
    );
  }

  /// Opens [uri] for reading and returns its file descriptor.
  ///
  /// Close the descriptor with [closeFileDescriptor] when it is no longer
  /// needed.
  Future<int> getFileDescriptor(String uri) {
    return SafUtilPlatform.instance.getFileDescriptor(uri);
  }

  /// Closes the file descriptor returned by [getFileDescriptor].
  Future<void> closeFileDescriptor(int fd) {
    return SafUtilPlatform.instance.closeFileDescriptor(fd);
  }

  /// Checks whether this app has persisted access to [uri].
  ///
  /// [checkRead] controls whether read access is checked (default `true`);
  /// [checkWrite] controls whether write access is checked (default `false`).
  Future<bool> hasPersistedPermission(
    String uri, {
    bool checkRead = true,
    bool checkWrite = false,
  }) {
    return SafUtilPlatform.instance.hasPersistedPermission(
      uri,
      checkRead: checkRead,
      checkWrite: checkWrite,
    );
  }

  /// Releases persisted access to [uri].
  ///
  /// [read] controls whether read access is released (default `true`); [write]
  /// controls whether write access is released (default `false`).
  Future<void> releasePersistedPermission(
    String uri, {
    bool read = true,
    bool write = false,
  }) async {
    return SafUtilPlatform.instance.releasePersistedPermission(
      uri,
      read: read,
      write: write,
    );
  }
}
