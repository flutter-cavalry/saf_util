import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'saf_util_method_channel.dart';

class SafDocumentFile {
  final String uri;
  final String name;
  final bool isDir;
  final int length;
  final int lastModified;

  SafDocumentFile({
    required this.uri,
    required this.name,
    required this.isDir,
    required this.length,
    required this.lastModified,
  });

  static SafDocumentFile fromMap(Map<dynamic, dynamic> map) {
    return SafDocumentFile(
      uri: map['uri'],
      name: map['name'],
      isDir: map['isDir'] ?? false,
      length: map['length'] ?? 0,
      lastModified: map['lastModified'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'SafDocumentFile{uri: $uri, name: $name, isDir: $isDir, length: $length, lastModified: $lastModified}';
  }
}

class SafUriInfo {
  final String uri;
  final String name;
  final bool isDir;

  SafUriInfo({
    required this.uri,
    required this.name,
    required this.isDir,
  });

  static SafUriInfo fromMap(Map<String, dynamic> map) {
    return SafUriInfo(
      uri: map['uri'],
      name: map['name'],
      isDir: map['isDir'],
    );
  }

  @override
  String toString() {
    return 'SafUriInfo{uri: $uri, name: $name, isDir: $isDir}';
  }
}

abstract class SafUtilPlatform extends PlatformInterface {
  /// Constructs a SafUtilPlatform.
  SafUtilPlatform() : super(token: _token);

  static final Object _token = Object();

  static SafUtilPlatform _instance = MethodChannelSafUtil();

  /// The default instance of [SafUtilPlatform] to use.
  ///
  /// Defaults to [MethodChannelSafUtil].
  static SafUtilPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SafUtilPlatform] when
  /// they register themselves.
  static set instance(SafUtilPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> openDirectory() {
    throw UnimplementedError('openDirectory() has not been implemented.');
  }

  Future<List<SafDocumentFile>> list(String uri) {
    throw UnimplementedError('list() has not been implemented.');
  }

  Future<SafDocumentFile> documentFileFromUri(String uri, bool isDir) {
    throw UnimplementedError('documentFileFromUri() has not been implemented.');
  }

  Future<bool> exists(String uri, bool isDir) {
    throw UnimplementedError('exists() has not been implemented.');
  }

  Future<void> delete(String uri, bool isDir) {
    throw UnimplementedError('delete() has not been implemented.');
  }

  Future<SafUriInfo> mkdirp(String uri, List<String> path) {
    throw UnimplementedError('mkdirp() has not been implemented.');
  }

  Future<SafDocumentFile?> child(String uri, String name) {
    throw UnimplementedError('child() has not been implemented.');
  }

  Future<SafUriInfo?> childUri(String uri, String name) {
    throw UnimplementedError('childUri() has not been implemented.');
  }

  Future<SafUriInfo> rename(String uri, bool isDir, String newName) {
    throw UnimplementedError('rename() has not been implemented.');
  }

  Future<String> moveTo(String uri, String parentUri, String newParentUri) {
    throw UnimplementedError('moveTo() has not been implemented.');
  }

  Future<String> copyTo(String uri, String newParentUri) {
    throw UnimplementedError('copyTo() has not been implemented.');
  }
}
