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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                final folder =
                    await _safUtilPlugin.openDirectory(writePermission: true);
                if (folder == null) {
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                final folderRoute = FolderRoute(folder: folder);
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
          const SizedBox(height: 20),
          Text(_status),
        ],
      )),
    );
  }
}
