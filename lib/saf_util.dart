import 'saf_util_platform_interface.dart';

class SafUtil {
  Future<String?> openDirectory() {
    return SafUtilPlatform.instance.openDirectory();
  }

  Future<List<SafDocumentFile>> list(String uri) {
    return SafUtilPlatform.instance.list(uri);
  }

  Future<SafDocumentFile> documentFileFromUri(String uri, bool isDir) {
    return SafUtilPlatform.instance.documentFileFromUri(uri, isDir);
  }

  Future<bool> exists(String uri, bool isDir) {
    return SafUtilPlatform.instance.exists(uri, isDir);
  }

  Future<void> delete(String uri, bool isDir) {
    return SafUtilPlatform.instance.delete(uri, isDir);
  }

  Future<SafUriInfo> mkdirp(String uri, List<String> path) {
    return SafUtilPlatform.instance.mkdirp(uri, path);
  }

  Future<SafDocumentFile?> child(String uri, String name) {
    return SafUtilPlatform.instance.child(uri, name);
  }

  Future<SafUriInfo?> childUri(String uri, String name) {
    return SafUtilPlatform.instance.childUri(uri, name);
  }

  Future<SafUriInfo> rename(String uri, bool isDir, String newName) {
    return SafUtilPlatform.instance.rename(uri, isDir, newName);
  }

  Future<String> moveTo(String uri, String parentUri, String newParentUri) {
    return SafUtilPlatform.instance.moveTo(uri, parentUri, newParentUri);
  }

  Future<String> copyTo(String uri, String newParentUri) {
    return SafUtilPlatform.instance.copyTo(uri, newParentUri);
  }
}
