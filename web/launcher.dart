library web.launcher;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:upcom-api/web/mailbox/mailbox.dart';
import 'package:upcom-api/web/tab/launcher_controller.dart';

class UpDroidLauncher extends LauncherController {
  static final List<String> names = ['upcom-launcher', 'UpDroid Launcher', 'Launcher'];

  DivElement _containerDiv, _resultsDiv;
  InputElement _searchInput;
  SpanElement _searchIcon;

  UpDroidLauncher() :
  super(UpDroidLauncher.names, 'tabs/upcom-launcher/launcher.css') {

  }

  void setUpController() {
    _searchInput = new InputElement()
      ..id = '$refName-$id-search'
      ..classes.add('$refName-search')
      ..placeholder = 'search tab name';
    view.content.children.add(_searchInput);

    _searchIcon = new SpanElement()
      ..classes.addAll(['$refName-search-icon', 'glyphicons', 'glyphicons-search']);
    _searchInput.children.add(_searchIcon);

    _resultsDiv = new DivElement()
      ..id = '$refName-$id-results'
      ..classes.add('$refName-results');
    view.content.children.add(_resultsDiv);
  }

  void _getTabsInfo(Msg m) => mailbox.ws.send(new Msg('GET_TABS_INFO').toString());

  void _receivedTabsInfo(Msg m) {
    Map<String, Map> tabsInfo = JSON.decode(m.body);
    // This loop is just for testing a long list.
    for (int i = 0; i < 2; i++) {
      tabsInfo.keys.forEach((e) {
        Map<String, String> tabInfo = tabsInfo[e];

        ButtonElement tabButton = new ButtonElement()
          ..id = '$refName-$id-tab-button-${tabInfo['refName']}'
          ..classes.addAll(['btn-primary', '$refName-button'])
          ..text = tabInfo['fullName'];
        _resultsDiv.children.add(tabButton);

        tabButton.onClick.listen((e) => _requestTab(tabButton.id.replaceFirst('$refName-$id-tab-button-', '')));
      });
    }
  }

  void _requestTab(String refName) {
    mailbox.ws.send(new Msg('REQUEST_TAB', refName).toString());
  }

  void registerMailbox() {
    mailbox.registerWebSocketEvent(EventType.ON_OPEN, 'TAB_READY', _getTabsInfo);
    mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'SEND_TABS_INFO', _receivedTabsInfo);
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