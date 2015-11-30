library lib.launcher;

import 'dart:isolate';

import 'package:upcom-api/tab_backend.dart';

part 'src/launcher_helper.dart';

class CmdrLauncher extends Tab {
  static final List<String> names = ['upcom-launcher', 'UpDroid Launcher', 'Launcher'];

  CmdrLauncher(SendPort sp, args) :
  super(CmdrLauncher.names, sp, args) {

  }

  void registerMailbox() {
//    mailbox.registerMessageHandler('MESSAGE_TO_LISTEN_FOR', _messageHandler);
//
//    mailbox.registerEndPointHandler('/$refName/$id/websocket_endpoint', _endpointHandler);
  }

  void cleanup() {

  }
}