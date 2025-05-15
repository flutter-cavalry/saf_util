import 'package:fc_quick_dialog/fc_quick_dialog.dart';
import 'package:flutter/material.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util_example/folder_route.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _safUtilPlugin = SafUtil();
  var _status = '';
  var _multipleFiles = false;
  var _persistablePermission = false;
  late TextEditingController _initialUriController;
  var _initialUri = '';
  late TextEditingController _checkPersistablePermissionInputController;
  var _checkPersistablePermissionInput = '';

  @override
  void initState() {
    super.initState();
    _initialUriController = TextEditingController();
    _checkPersistablePermissionInputController = TextEditingController();
  }

  @override
  void dispose() {
    _initialUriController.dispose();
    _checkPersistablePermissionInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          children: [
            OutlinedButton(
              onPressed: () async {
                try {
                  final dir = await _safUtilPlugin.pickDirectory(
                      writePermission: true,
                      initialUri: _initialUri,
                      persistablePermission: _persistablePermission);
                  if (dir == null) {
                    return;
                  }
                  if (!context.mounted) {
                    return;
                  }
                  final folderRoute = FolderRoute(
                    uri: dir.uri,
                    name: dir.name,
                  );
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (context) => folderRoute),
                  );
                } catch (err) {
                  setState(() {
                    _status = 'Error: $err';
                  });
                }
              },
              child: const Text('Select a folder'),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  final files = await _safUtilPlugin.pickFiles(
                      initialUri: _initialUri, multiple: _multipleFiles);
                  if (files == null) {
                    return;
                  }
                  if (!context.mounted) {
                    return;
                  }

                  String summary = 'You have selected ${files.length} files:\n';
                  for (final file in files) {
                    summary +=
                        '${file.name}\nSize: ${file.length}\nUri:${file.uri}\n\n';
                  }
                  setState(() {
                    _status = summary;
                  });
                } catch (err) {
                  setState(() {
                    _status = 'Error: $err';
                  });
                }
              },
              child: const Text('Select file/files'),
            ),
            Text(_status),
            Text('Initial URI'),
            TextField(
                controller: _initialUriController,
                onChanged: (String value) {
                  setState(() {
                    _initialUri = value;
                  });
                }),
            CheckboxListTile(
                title: const Text('Pick multiple files'),
                value: _multipleFiles,
                onChanged: (value) {
                  setState(() {
                    _multipleFiles = value!;
                  });
                }),
            CheckboxListTile(
                title: const Text('Persistable permission'),
                value: _persistablePermission,
                onChanged: (value) {
                  setState(() {
                    _persistablePermission = value!;
                  });
                }),
            TextField(
                controller: _checkPersistablePermissionInputController,
                onChanged: (String value) {
                  setState(() {
                    _checkPersistablePermissionInput = value;
                  });
                }),
            OutlinedButton(
              onPressed: () async {
                try {
                  final input = _checkPersistablePermissionInput;
                  if (input.isEmpty) {
                    return;
                  }
                  final ok = await _safUtilPlugin.hasPersistedPermission(input);
                  if (!context.mounted) {
                    return;
                  }
                  await FcQuickDialog.info(context,
                      title: 'Is persisted permission?',
                      content: 'Persisted permission: $ok',
                      okText: 'OK');
                } catch (err) {
                  setState(() {
                    _status = 'Error: $err';
                  });
                }
              },
              child: const Text('Check URI permission persisted'),
            ),
          ],
        ),
      ),
    );
  }
}
