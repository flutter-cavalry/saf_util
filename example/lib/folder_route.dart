import 'package:fc_quick_dialog/fc_quick_dialog.dart';
import 'package:flutter/material.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

class FolderRoute extends StatefulWidget {
  final String folder;

  const FolderRoute({super.key, required this.folder});

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
        title: Text('Folder: ${widget.folder}'),
      ),
      body: Padding(padding: const EdgeInsets.all(8), child: _buildBody()),
    );
  }

  Future<void> _reload() async {
    try {
      final contents = await _safUtilPlugin.list(widget.folder);
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
      children: [
        Text('Folder: ${widget.folder}'),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: _reload,
              child: const Text('Reload'),
            ),
            const SizedBox(width: 20),
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
                  final child = await _safUtilPlugin.child(
                      widget.folder, names.split('/'));
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
            const SizedBox(width: 20),
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
                      await _safUtilPlugin.mkdirp(widget.folder, components);
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
        const SizedBox(height: 20),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildItemView(SafDocumentFile df) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        df.isDir
            ? Row(
                children: [
                  const Icon(Icons.folder),
                  const SizedBox(width: 10),
                  Text(df.name),
                  const SizedBox(width: 10),
                  IconButton(
                      onPressed: () {
                        final folderRoute = FolderRoute(folder: df.uri);
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(builder: (context) => folderRoute),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward)),
                ],
              )
            : Text(df.name),
        const SizedBox(height: 10),
        Text(df.uri),
        if (df.lastModified != 0) ...[
          const SizedBox(height: 10),
          Text(
              'Last modified: ${DateTime.fromMillisecondsSinceEpoch(df.lastModified)}'),
        ],
        const SizedBox(height: 10),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
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
            const SizedBox(width: 10),
            OutlinedButton(
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
            const SizedBox(width: 10),
            OutlinedButton(
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
                child: const Text('Rename'))
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
