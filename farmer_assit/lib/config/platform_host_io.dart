import 'dart:io';

String resolveBackendHost() {
  if (Platform.isAndroid) {
    return '10.0.2.2';
  }
  return 'localhost';
}