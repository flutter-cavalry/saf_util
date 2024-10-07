import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'saf_util_platform_interface.dart';

/// An implementation of [SafUtilPlatform] that uses method channels.
class MethodChannelSafUtil extends SafUtilPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('saf_util');

  @override
  Future<String?> openDirectory({String? initialUri}) async {
    return methodChannel.invokeMethod<String>('openDirectory', {
      'initialUri': initialUri,
    });
  }

  @override
  Future<List<SafDocumentFile>> list(String uri) async {
    final maps = await methodChannel
        .invokeListMethod<Map<dynamic, dynamic>>('list', {'uri': uri});
    return (maps ?? []).map((map) => SafDocumentFile.fromMap(map)).toList();
  }

  @override
  Future<SafDocumentFile> documentFileFromUri(String uri, bool isDir) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'documentFileFromUri',
      {'uri': uri, 'isDir': isDir},
    );
    if (map == null) {
      throw Exception('Failed to get document file from uri: $uri');
    }
    return SafDocumentFile.fromMap(map);
  }

  @override
  Future<bool> exists(String uri, bool isDir) async {
    final res = await methodChannel.invokeMethod<bool>(
      'exists',
      {'uri': uri, 'isDir': isDir},
    );
    if (res == null) {
      throw Exception('Failed to check if file exists: $uri');
    }
    return res;
  }

  @override
  Future<void> delete(String uri, bool isDir) async {
    final res = await methodChannel.invokeMethod<bool>(
      'delete',
      {'uri': uri, 'isDir': isDir},
    );
    if (res != true) {
      throw Exception('Failed to delete file: $uri');
    }
  }

  @override
  Future<SafUriInfo> mkdirp(String uri, List<String> names) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'mkdirp',
      {'uri': uri, 'names': names},
    );
    if (map == null) {
      throw Exception('Failed to create directory: $uri');
    }
    return SafUriInfo.fromMap(map);
  }

  @override
  Future<SafDocumentFile?> child(String uri, List<String> names) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'child',
      {'uri': uri, 'names': names},
    );
    if (map == null) {
      return null;
    }
    return SafDocumentFile.fromMap(map);
  }

  @override
  Future<SafUriInfo?> childUri(String uri, String name) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'childUri',
      {'uri': uri, 'name': name},
    );
    if (map == null) {
      return null;
    }
    return SafUriInfo.fromMap(map);
  }

  @override
  Future<SafUriInfo> rename(String uri, bool isDir, String newName) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'rename',
      {'uri': uri, 'isDir': isDir, 'newName': newName},
    );
    if (map == null) {
      throw Exception('Failed to rename: $uri');
    }
    return SafUriInfo.fromMap(map);
  }

  @override
  Future<SafDocumentFile> moveTo(
      String uri, bool isDir, String parentUri, String newParentUri) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'moveTo',
      {
        'uri': uri,
        'isDir': isDir,
        'parentUri': parentUri,
        'newParentUri': newParentUri
      },
    );
    if (map == null) {
      throw Exception('Failed to move: $uri');
    }
    return SafDocumentFile.fromMap(map);
  }

  @override
  Future<SafDocumentFile> copyTo(
      String uri, bool isDir, String newParentUri) async {
    final map = await methodChannel.invokeMapMethod<String, dynamic>(
      'copyTo',
      {'uri': uri, 'isDir': isDir, 'newParentUri': newParentUri},
    );
    if (map == null) {
      throw Exception('Failed to copy: $uri');
    }
    return SafDocumentFile.fromMap(map);
  }
}
