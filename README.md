# saf_util

[![pub package](https://img.shields.io/pub/v/saf_util.svg)](https://pub.dev/packages/saf_util)

Utilities for Android's Storage Access Framework (SAF). This package helps you
pick and manage documents, but it does not read or write file contents. For
streaming file data, see [saf_stream](https://github.com/flutter-cavalry/saf_stream).

## Usage

See the [API documentation](https://pub.dev/documentation/saf_util/latest/saf_util/SafUtil-class.html).

## API Summary

- Pickers
  - `pickDirectory`, `pickFile`, and `pickFiles` open the system document picker.
  - `pickMedia` opens the system photo picker (Android 13 / API 33 and later).
- Document operations
  - `documentFileFromUri` and `stat` create a `SafDocumentFile` from a content URI.
  - `list`, `child`, and `exists` inspect documents and directories.
  - `mkdirp`, `rename`, `moveTo`, `copyTo`, and `delete` manage documents.
  - `saveThumbnailToFile` saves an image or video thumbnail to a local file.
- Permissions and descriptors
  - `hasPersistedPermission` and `releasePersistedPermission` manage persisted URI access.
  - `getFileDescriptor` opens a document for reading; close it with `closeFileDescriptor`.

`SafDocumentFile` provides a document's content URI, display name, directory
status, size, and last-modified time. Its `length` is `-1` when the size is
unknown.
