library lib.launcher;

import 'dart:isolate';

import 'package:upcom-api/tab_backend.dart';

part 'src/launcher_helper.dart';

class CmdrLauncher extends Tab {
  static final List<String> names = ['upcom-launcher', 'UpDroid Launcher', 'Launcher'];

  CmdrLauncher(SendPort sp, args) :
  super(CmdrLauncher.names, sp, args) {

  }

  void _getTabsInfo(String s) {
    mailbox.relay(Tab.upcomName, 1, new Msg('GET_TABS_INFO', '${CmdrLauncher.names[0]}:$id'));
  }

  void _sendTabsInfo(String s) {
    print(s);
    mailbox.send(new Msg('SEND_TABS_INFO', s));
  }

  void registerMailbox() {
    mailbox.registerMessageHandler('GET_TABS_INFO', _getTabsInfo);
    mailbox.registerMessageHandler('SEND_TABS_INFO', _sendTabsInfo);
  }

  void cleanup() {

  }
}