library lib.launcher;

import 'dart:isolate';

import 'package:upcom-api/tab_backend.dart';

part 'src/launcher_helper.dart';

class CmdrLauncher extends Tab {
  static final List<String> names = ['upcom-launcher', 'UpDroid Launcher', 'Launcher'];

  CmdrLauncher(SendPort sp, args) : super(CmdrLauncher.names, sp, args);

  void _getTabsInfo(String s) {
    mailbox.relay(Tab.upcomName, 1, new Msg('GET_TABS_INFO', '${CmdrLauncher.names[0]}:$id'));
  }

  void _getPanelsInfo(String s) {
    mailbox.relay(Tab.upcomName, 1, new Msg('GET_PANELS_INFO', '${CmdrLauncher.names[0]}:$id'));
  }

  void _sendTabsInfo(String s) => mailbox.send(new Msg('SEND_TABS_INFO', s));
  void _sendPanelsInfo(String s) => mailbox.send(new Msg('SEND_PANELS_INFO', s));

  void _requestTab(String m) {
    mailbox.relay(Tab.upcomName, -1, new Msg('REQUEST_TAB', '${names[0]}:$id:$m'));
  }

  void _requestFulfilled(String requestedTabId) {
    // Empty callback.
  }

  void registerMailbox() {
    mailbox.registerMessageHandler('GET_TABS_INFO', _getTabsInfo);
    mailbox.registerMessageHandler('GET_PANELS_INFO', _getPanelsInfo);
    mailbox.registerMessageHandler('SEND_TABS_INFO', _sendTabsInfo);
    mailbox.registerMessageHandler('SEND_PANELS_INFO', _sendPanelsInfo);
    mailbox.registerMessageHandler('REQUEST_TAB', _requestTab);
    mailbox.registerMessageHandler('REQUEST_FULFILLED', _requestFulfilled);
  }

  void cleanup() {

  }
}