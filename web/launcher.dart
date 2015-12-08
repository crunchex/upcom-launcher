library web.launcher;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:upcom-api/web/mailbox/mailbox.dart';
import 'package:upcom-api/web/tab/tab_controller.dart';

class UpDroidLauncher extends TabController {
  static final List<String> names = ['upcom-launcher', 'UpDroid Launcher', 'Launcher'];

  DivElement _containerDiv, _tabResultsDiv;
  InputElement _searchInput;
  SpanElement _searchIcon;
  Map<String, Map> _tabsInfo;
  StreamSubscription _searchSub;
  List<StreamSubscription> _buttonListeners;

  UpDroidLauncher() :
  super(UpDroidLauncher.names) {

  }

  void setUpController() {
    _searchInput = new InputElement()
      ..id = '$refName-$id-search'
      ..classes.add('$refName-search')
      ..placeholder = 'Search';
    content.children.add(_searchInput);

    _searchIcon = new SpanElement()
      ..classes.addAll(['$refName-search-icon', 'glyphicons', 'glyphicons-search']);
    _searchInput.children.add(_searchIcon);

    _tabResultsDiv = new DivElement()
      ..id = '$refName-$id-results'
      ..classes.add('$refName-results');
    content.children.add(_tabResultsDiv);
  }

  void _getTabsInfo(Msg m) => mailbox.ws.send(new Msg('GET_TABS_INFO').toString());

  void _receivedTabsInfo(Msg m) {
    _tabsInfo = JSON.decode(m.body);
    _tabsInfo.remove('upcom-launcher');

    for (Map<String, String> tabInfo in _tabsInfo.values) {
      _setUpTabButton(tabInfo);
    }

    _searchSub = _searchInput.onKeyUp.listen((e) {
      var keyEvent = new KeyEvent.wrap(e);
      if (keyEvent.keyCode == KeyCode.ENTER) {
        if (_tabResultsDiv.children.length == 1) {
          _requestTab(_tabResultsDiv.children[0].id.replaceFirst('$refName-$id-tab-button-', ''));
        }
      } else {
        _updateResults(_searchInput.value);
      }
    });

    // Nice way to do a "forEach" and "then".
//    Future.wait(_tabsInfo.values.map((Map<String, String> tabInfo) {
//      Completer c = new Completer();
//      _setUpTabButton(tabInfo);
//
//      c.complete();
//      return c.future;
//    })).then((_) => _searchInput.onKeyUp.listen((e) => _handleSearch(_searchInput.value)));
  }

  void _updateResults(String query) {
    Map<String, Map> tabsInfo = new Map.from(_tabsInfo);

    for (String tabInfoKey in _tabsInfo.keys) {
      if (!_searchTabInfo(_tabsInfo[tabInfoKey], query)) tabsInfo.remove(tabInfoKey);
    }

    // Cancel all the button listeners.
    // TODO: investigate if this will cause a listener leak.
    _buttonListeners.forEach((StreamSubscription sub) => sub.cancel());
    // Clear the results div.
    _buttonListeners = [];
    _tabResultsDiv.children = [];
    // Repopulate the div.
    tabsInfo.keys.forEach((e) => _setUpTabButton(tabsInfo[e]));
  }

  void _setUpTabButton(Map<String, String> tabInfo) {
    ButtonElement tabButton = new ButtonElement()
      ..id = '$refName-$id-tab-button-${tabInfo['refName']}'
      ..classes.addAll(['btn-primary', '$refName-button'])
      ..text = tabInfo['shortName'];
    _tabResultsDiv.children.add(tabButton);

    if (_buttonListeners == null) _buttonListeners = [];
    _buttonListeners.add(tabButton.onClick.listen((e) {
      e.preventDefault();
      _requestTab(tabButton.id.replaceFirst('$refName-$id-tab-button-', ''));
    }));
  }

  bool _searchTabInfo(Map<String, String> tabInfo, String query) {
    bool result = false;

    // For when we want to search all the name variations.
    // for (String s in tabInfo.values) {
    //   if (s.contains(query)) result = true;
    // }

    // Only search full name in lower case.
    if (tabInfo['shortName'].toLowerCase().contains(query.toLowerCase())) result = true;

    return result;
  }

  void _requestTab(String refName) {
    _searchInput.value = '';
    _updateResults('');
    mailbox.ws.send(new Msg('REQUEST_TAB', refName).toString());
  }

  void registerMailbox() {
    mailbox.registerWebSocketEvent(EventType.ON_OPEN, 'TAB_READY', _getTabsInfo);
    mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'SEND_TABS_INFO', _receivedTabsInfo);
  }

  void registerEventHandlers() {
    // window.onResize.listen((e) {
    // });
  }

  Element get elementToFocus => _searchInput;

  Future<bool> preClose() {
    Completer c = new Completer();
    c.complete(true);
    return c.future;
  }

  void cleanUp() {
    _searchSub.cancel();
    _buttonListeners.forEach((StreamSubscription sub) => sub.cancel());
  }
}