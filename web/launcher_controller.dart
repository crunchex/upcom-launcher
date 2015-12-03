library web.launcher_controller;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:upcom-api/web/tab/container_view.dart';
import 'package:upcom-api/web/mailbox/mailbox.dart';

part 'launcher_view.dart';

abstract class LauncherController {
  int id, col;
  bool active;
  String refName, fullName, shortName;

  LauncherView view;
  Mailbox mailbox;

  List<StreamSubscription> _listeners;

  LauncherController(List<String> names, [String externalCssPath]) {
    refName = names[0];
    fullName = names[1];
    shortName = names[2];
    // Wait for an ID event before we continue with the setup.
    _getId().then((_) => _setupLauncher(externalCssPath));

    // Let UpCom know that we are ready for ID.
    CustomEvent event = new CustomEvent('TabReadyForId', canBubble: false, cancelable: false, detail: refName);
    window.dispatchEvent(event);
  }

  Future _getId() {
    EventStreamProvider<CustomEvent> LauncherIdStream = new EventStreamProvider<CustomEvent>('TabIdEvent');
    return LauncherIdStream.forTarget(window).where((CustomEvent e) {
      Map detail = JSON.decode(e.detail);
      return refName == detail['refName'];
    }).first.then((e) {
      Map detail = JSON.decode(e.detail);
      id = detail['id'];
      col = detail['col'];
    });
  }

  Future _setupLauncher([String externalCssPath]) async {
    mailbox = new Mailbox(refName, id);
    registerMailbox();

    view = await LauncherView.createLauncherView(id, col, refName, fullName, shortName, externalCssPath);

    setUpController();

    mailbox.registerWebSocketEvent(EventType.ON_MESSAGE, 'UPDATE_COLUMN', _updateColumn);
    registerEventHandlers();

    if (_listeners == null) _listeners = [];
    _listeners.add(view.tabHandleButton.onClick.listen((e) {
      // Need to show the tab content before the input field can be focused.
      new Timer(new Duration(milliseconds: 500), () => elementToFocus.focus());
    }));
    // When the content of this Launcher receives focus, transfer it to whatever is the main content of the Launcher
    // (which may or may not be the direct child of view.content).
    // Also, this is done last as additional view set up may have been done in setUpController().
    _listeners.add(view.tabContent.onFocus.listen((e) => elementToFocus.focus()));

    CustomEvent event = new CustomEvent('TabSetupComplete', canBubble: false, cancelable: false, detail: refName);
    window.dispatchEvent(event);

    return null;
  }

  void makeActive() => view.makeActive();
  void makeInactive() => view.makeInactive();

  String get hoverText => view.tabHandle.title;

  void set hoverText(String text) {
    view.tabHandle.title = text;
  }

  void registerMailbox();
  void setUpController();
  void registerEventHandlers();
  Future<bool> preClose();
  void cleanUp();
  Element get elementToFocus;

  Future<bool> _closeLauncher() async {
    // Cancel closing if preClose returns false for some reason.
    bool canClose = await preClose();
    if (!canClose) return false;

    for (StreamSubscription sub in _listeners) {
      sub.cancel();
    }

    view.destroy();
    cleanUp();

    Msg um = new Msg('CLOSE_LAUNCHER', '$refName:$id');
    mailbox.ws.send(um.toString());

    return true;
  }

  void _updateColumn(Msg um) {
    col = int.parse(um.body);
    view.col = int.parse(um.body);
  }
}
