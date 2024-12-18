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
  late TextEditingController _controller;
  var _initialUri = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final dir = await _safUtilPlugin.pickDirectory(
                      writePermission: true, initialUri: _initialUri);
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
            const SizedBox(height: 10),
            ElevatedButton(
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
            const SizedBox(height: 10),
            Text(_status),
            const SizedBox(height: 10),
            Text('Initial URI'),
            const SizedBox(height: 10),
            TextField(
                controller: _controller,
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
