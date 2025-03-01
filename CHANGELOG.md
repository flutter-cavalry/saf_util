## 0.7.0

- Add file descriptor support.

## 0.6.2

- Fix length overflow.

## 0.6.1

- Update docs.

## 0.6.0

- Add `pickFiles` and `pickDirectory` to replace `openFile` and `openDirectory`. The new methods return [DocumentFile] instead of Uri string.

## 0.5.0

- Add `openFile` and `openFiles` to open file picker dialog.
- Make sure read permission is always set when write permission is on.

## 0.4.0

- Relax minimum Dart and Flutter versions (Fixes #2).

## 0.3.0

- `saveThumbnailToFile` width and height params should be int.

## 0.2.0

- Add `saveThumbnailToFile`, which supports extracting image and video thumbnails from an SAF [DocumentFile].

## 0.1.0

- Add `writePermission` and `persistablePermission` to openDirectory
- Support renaming on file `DocumentFile`

## 0.0.1

- Initial release.
