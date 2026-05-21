# saf_util

[![pub package](https://img.shields.io/pub/v/saf_util.svg)](https://pub.dev/packages/saf_util)

Util functions for SAF (Storage Access Framework). Note that this package doesn't provide any read / write functions (go to [saf_stream](https://github.com/flutter-cavalry/saf_stream) for that).

## Usage

[Documentation](https://pub.dev/documentation/saf_util/latest/saf_util/)

## API Summary

- Pickers
  - `pickDirectory` opens a directory picker.
  - `pickFiles` opens a file picker.
  - `pickMedia` opens a media picker.
- `DocumentFile` wrappers
  - `list` lists directory contents.
  - `stat` gets file/folder stats.
  - `exists` checks if a file/folder exists.
  - `delete` deletes a file/folder.
  - `mkdirp` creates a directory and all its parent directories if they don't exist.
  - `child` gets a child `DocumentFile` by name.
  - `rename` renames a file/folder.
  - `moveTo` moves a file/folder to another directory.
  - `copyTo` copies a file/folder to another directory.
  - `saveThumbnailToFile` saves a thumbnail of a file to a specified file.
- File descriptor utils
  - `getFileDescriptor` gets a file descriptor for a file.
  - `closeFileDescriptor` closes a file descriptor.
- Permission utils
  - `hasPersistedPermission` checks if the app has persisted permission for a `Uri`.
  - `releasePersistedPermission` releases persisted permission for a `Uri`.
- Other utils
  - `documentFileFromUri` creates a `DocumentFile` from a `Uri`.
