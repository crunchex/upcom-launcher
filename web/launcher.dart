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
  Map<String, Map> _tabsInfo;

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
    _tabsInfo = JSON.decode(m.body);
    Map<String, Map> tabsInfo = new Map.from(_tabsInfo);

    // Nice way to do a "forEach" and "then".
    Future.wait(tabsInfo.values.map((Map<String, String> tabInfo) {
      Completer c = new Completer();
      ButtonElement tabButton = new ButtonElement()
        ..id = '$refName-$id-tab-button-${tabInfo['refName']}'
        ..classes.addAll(['btn-primary', '$refName-button'])
        ..text = tabInfo['fullName'];
      _resultsDiv.children.add(tabButton);

      tabButton.onClick.listen((e) {
        e.preventDefault();
        _requestTab(tabButton.id.replaceFirst('$refName-$id-tab-button-', ''));
      });

      c.complete();
      return c.future;
    })).then((_) => _searchInput.onKeyUp.listen((e) => _handleSearch(_searchInput.value)));
  }

  void _handleSearch(String query) {
    Map<String, Map> tabsInfo = new Map.from(_tabsInfo);

    Future.wait(_tabsInfo.keys.map((String key) {
      Completer c = new Completer();
      if (!_searchTabInfo(_tabsInfo[key], query)) {
        tabsInfo.remove(key);
      }
      c.complete();
      return c.future;
    })).then((_) {
      _resultsDiv.children = [];

      tabsInfo.keys.forEach((e) {
        Map<String, String> tabInfo = tabsInfo[e];

        ButtonElement tabButton = new ButtonElement()
          ..id = '$refName-$id-tab-button-${tabInfo['refName']}'
          ..classes.addAll(['btn-primary', '$refName-button'])
          ..text = tabInfo['fullName'];
        _resultsDiv.children.add(tabButton);

        tabButton.onClick.listen((e) {
          e.preventDefault();
          _requestTab(tabButton.id.replaceFirst('$refName-$id-tab-button-', ''));
        });
      });
    });
  }

  bool _searchTabInfo(Map<String, String> tabInfo, String query) {
    bool result = false;

    // For when we want to search all the name variations.
    // for (String s in tabInfo.values) {
    //   if (s.contains(query)) result = true;
    // }

    // Only search full name in lower case.
    if (tabInfo['fullName'].toLowerCase().contains(query.toLowerCase())) result = true;

    return result;
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

  Element get elementToFocus => _searchInput;

  Future<bool> preClose() {
    Completer c = new Completer();
    c.complete(true);
    return c.future;
  }

  void cleanUp() {

  }
}