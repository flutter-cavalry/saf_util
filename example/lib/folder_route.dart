import 'dart:io';

import 'package:fc_quick_dialog/fc_quick_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:tmp_path/tmp_path.dart';

class FolderRoute extends StatefulWidget {
  final String uri;
  final String name;

  const FolderRoute({super.key, required this.uri, required this.name});

  @override
  State<FolderRoute> createState() => _FolderRouteState();
}

class _FolderRouteState extends State<FolderRoute> {
  final _safUtilPlugin = SafUtil();

  List<SafDocumentFile> _contents = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(padding: const EdgeInsets.all(8), child: _buildBody()),
    );
  }

  Future<void> _reload() async {
    try {
      final contents = await _safUtilPlugin.list(widget.uri);
      contents.sort((a, b) {
        if (a.isDir && !b.isDir) {
          return -1;
        }
        if (!a.isDir && b.isDir) {
          return 1;
        }
        return a.name.compareTo(b.name);
      });
      setState(() {
        _contents = contents;
      });
    } catch (err) {
      if (!mounted) {
        return;
      }
      await FcQuickDialog.error(context,
          title: 'Error', error: err, okText: 'OK');
    }
  }

  Widget _buildBody() {
    return Column(
      spacing: 10,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(widget.uri),
            ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.uri));
                  if (!mounted) {
                    return;
                  }
                  await FcQuickDialog.info(context,
                      title: 'URI copied', content: widget.uri, okText: 'OK');
                },
                child: const Text('Copy URI')),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: _reload,
              child: const Text('Reload'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final names = await FcQuickDialog.textInput(context,
                      title: 'Enter names, e.g. a/b/c',
                      okText: 'OK',
                      cancelText: 'Cancel');
                  if (names == null) {
                    return;
                  }
                  final child =
                      await _safUtilPlugin.child(widget.uri, names.split('/'));
                  if (!mounted) {
                    return;
                  }
                  if (child == null) {
                    await FcQuickDialog.error(context,
                        title: 'Not found',
                        error: 'Child not found',
                        okText: 'OK');
                  } else {
                    await FcQuickDialog.info(context,
                        title: 'Child found',
                        content: child.toString(),
                        okText: 'OK');
                  }
                } catch (err) {
                  if (!mounted) {
                    return;
                  }
                  await FcQuickDialog.error(context,
                      title: 'Error', error: err, okText: 'OK');
                }
              },
              child: const Text('Find child'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final path = await FcQuickDialog.textInput(context,
                      title: 'Enter a path (e.g. a/b/c)',
                      okText: 'OK',
                      cancelText: 'Cancel');
                  if (path == null) {
                    return;
                  }
                  final components = path.split('/');
                  final uriInfo =
                      await _safUtilPlugin.mkdirp(widget.uri, components);
                  if (!mounted) {
                    return;
                  }
                  await FcQuickDialog.info(context,
                      title: 'Directories created',
                      content: uriInfo.toString(),
                      okText: 'OK');
                  await _reload();
                } catch (err) {
                  if (!mounted) {
                    return;
                  }
                  await FcQuickDialog.error(context,
                      title: 'Error', error: err, okText: 'OK');
                }
              },
              child: const Text('mkdir -p'),
            ),
          ],
        ),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildItemView(SafDocumentFile df) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        df.isDir
            ? Row(
                spacing: 8,
                children: [
                  const Icon(Icons.folder),
                  Text(df.name),
                  IconButton(
                      onPressed: () {
                        final folderRoute = FolderRoute(
                          uri: df.uri,
                          name: df.name,
                        );
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(builder: (context) => folderRoute),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward)),
                ],
              )
            : Text(df.name),
        Text(df.uri),
        if (df.lastModified != 0) ...[
          Text(
              'Last modified: ${DateTime.fromMillisecondsSinceEpoch(df.lastModified)}'),
        ],
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  try {
                    if (await FcQuickDialog.confirm(context,
                            title: 'Are you sure you want to delete this item?',
                            yesText: 'Yes',
                            noText: 'No') !=
                        true) {
                      return;
                    }
                    await _safUtilPlugin.delete(df.uri, df.isDir);
                    await _reload();
                  } catch (err) {
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.error(context,
                        title: 'Error', error: err, okText: 'OK');
                  }
                },
                child: const Text('Delete')),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final isTree = await _safUtilPlugin.documentFileFromUri(
                        df.uri, df.isDir);
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.info(context,
                        title: 'documentFileFromUri',
                        content: isTree.toString(),
                        okText: 'OK');
                  } catch (err) {
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.error(context,
                        title: 'Error', error: err, okText: 'OK');
                  }
                },
                child: const Text('documentFileFromUri')),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final isTree =
                        await _safUtilPlugin.documentFileFromUri(df.uri, null);
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.info(context,
                        title: 'documentFileFromUri',
                        content: isTree.toString(),
                        okText: 'OK');
                  } catch (err) {
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.error(context,
                        title: 'Error', error: err, okText: 'OK');
                  }
                },
                child: const Text('documentFileFromUri (auto-detect isDir)')),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final newName = await FcQuickDialog.textInput(context,
                        title: 'Enter a new name',
                        okText: 'OK',
                        cancelText: 'Cancel');
                    if (newName == null) {
                      return;
                    }
                    if (!mounted) {
                      return;
                    }
                    final res =
                        await _safUtilPlugin.rename(df.uri, df.isDir, newName);
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.info(context,
                        title: 'Renamed',
                        content: res.toString(),
                        okText: 'OK');
                    await _reload();
                  } catch (err) {
                    if (!mounted) {
                      return;
                    }
                    await FcQuickDialog.error(context,
                        title: 'Error', error: err, okText: 'OK');
                  }
                },
                child: const Text('Rename')),
            if (!df.isDir) ...[
              ElevatedButton(
                  onPressed: () async {
                    try {
                      final thumbnailPath = tmpPath();
                      final saved = await _safUtilPlugin.saveThumbnailToFile(
                          uri: df.uri,
                          width: 256,
                          height: 256,
                          destPath: thumbnailPath);
                      final contentWidget = saved
                          ? Image.file(File(thumbnailPath))
                          : const Text('No thumbnail available for this file');
                      if (!mounted) {
                        return;
                      }
                      await FcQuickDialog.info(context,
                          title: 'Result',
                          contentWidget: contentWidget,
                          okText: 'OK');
                      await _reload();
                    } catch (err) {
                      if (!mounted) {
                        return;
                      }
                      await FcQuickDialog.error(context,
                          title: 'Error', error: err, okText: 'OK');
                    }
                  },
                  child: const Text('Get thumbnail')),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      final fd = await _safUtilPlugin.getFileDescriptor(df.uri);
                      if (!mounted) {
                        return;
                      }
                      await FcQuickDialog.info(context,
                          title: 'Result',
                          content: 'File descriptor: $fd',
                          okText: 'OK');
                      await _safUtilPlugin.closeFileDescriptor(fd);
                    } catch (err) {
                      if (!mounted) {
                        return;
                      }
                      await FcQuickDialog.error(context,
                          title: 'Error', error: err, okText: 'OK');
                    }
                  },
                  child: const Text('Get file descriptor')),
            ]
          ],
        )
      ],
    );
  }

  Widget _buildList() {
    return SingleChildScrollView(
      child: Column(
        children: _contents
            .map((df) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildItemView(df)))
            .toList(),
      ),
    );
  }
}
