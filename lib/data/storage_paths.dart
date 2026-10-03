import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Durable private app storage; the parent of the per-app cache directory maps
/// to Android's app files directory and Windows' %LOCALAPPDATA% app folder.
Future<Directory> appDataDirectory() async {
  final Directory directory = Platform.isWindows
      ? await getApplicationCacheDirectory()
      : await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  return directory;
}
