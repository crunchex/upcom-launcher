library web.launcher;

import 'dart:async';
import 'dart:html';

import 'package:upcom-api/web/mailbox/mailbox.dart';
import 'package:upcom-api/web/tab/tab_controller.dart';

class UpDroidLauncher extends TabController {
  static final List<String> names = ['upcom-launcher', 'UpDroid Launcher', 'Launcher'];

  static List getMenuConfig() {
    List menu = [
      {'title': 'File', 'items': [
        {'type': 'toggle', 'title': 'Close Tab'}]}
    ];
    return menu;
  }

  UpDroidLauncher() :
  super(UpDroidLauncher.names, getMenuConfig(), 'tabs/upcom-launcher/launcher.css') {

  }

  void setUpController() {

  }

  void _getTabsInfo(Msg m) => mailbox.ws.send('[[GET_TABS_INFO]]');

  void registerMailbox() {
    mailbox.registerWebSocketEvent(EventType.ON_OPEN, 'TAB_READY', _getTabsInfo);
  }

  void registerEventHandlers() {
    window.onResize.listen((e) {

    });
  }

  Element get elementToFocus => view.content.children[0];

  Future<bool> preClose() {
    Completer c = new Completer();
    c.complete(true);
    return c.future;
  }

  void cleanUp() {

  }
}