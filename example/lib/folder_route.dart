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
                  final name = await FcQuickDialog.textInput(context,
                      title: 'Enter name', okText: 'OK', cancelText: 'Cancel');
                  if (name == null) {
                    return;
                  }
                  final child = await _safUtilPlugin.child(widget.folder, name);
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

  Widget _buildList() {
    return ListView.builder(
      itemCount: _contents.length,
      itemBuilder: (context, index) {
        final file = _contents[index];
        return ListTile(
          title: Text(
              file.isDir ? '📦 ${file.name}' : '${file.name} (${file.length})'),
          subtitle: Text(file.uri),
          trailing: OutlinedButton(
              onPressed: () async {
                try {
                  if (await FcQuickDialog.confirm(context,
                          title: 'Are you sure you want to delete this item?',
                          yesText: 'Yes',
                          noText: 'No') !=
                      true) {
                    return;
                  }
                  await _safUtilPlugin.delete(file.uri, file.isDir);
                  await _reload();
                } catch (err) {
                  if (!context.mounted) {
                    return;
                  }
                  await FcQuickDialog.error(context,
                      title: 'Error', error: err, okText: 'OK');
                }
              },
              child: const Text('Delete')),
          onTap: file.isDir
              ? () {
                  final folderRoute = FolderRoute(folder: file.uri);
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (context) => folderRoute),
                  );
                }
              : null,
        );
      },
    );
  }
}
