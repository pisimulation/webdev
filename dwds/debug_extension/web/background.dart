// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('chrome')
library background;

import 'package:js/js.dart';
import 'package:sse/client/sse_client.dart';

void main() {
  addListener(allowInterop((e) {
    var query = QueryInfo(active: true, currentWindow: true);
    Tab currentTab;

    // Sends commands to debugger attached to the current tab.
    //
    // Extracts the extension backend port from the injected JS.
    void callback(List<Tab> tabs) {
      currentTab = tabs[0];
      attach(Debuggee(tabId: currentTab.id), '1.3', allowInterop((e) {}));
      sendCommand(Debuggee(tabId: currentTab.id), 'Debugger.enable',
          CommandParams(), allowInterop((e) {}));
      sendCommand(Debuggee(tabId: currentTab.id), 'Runtime.evaluate',
          CommandParams(expression: '\$extensionPort'), allowInterop((e) {
        var port = e.result.value;
        startSseClient(port);
      }));
    }

    queryTabs(query, allowInterop((List tabs) {
      callback(List.from(tabs));
    }));
  }));
}

// Starts an SSE client.
//
// Creates 2 channels which connect to the SSE handler at the extension
// backend, send a simple message.
Future<void> startSseClient(port) async {
  var channel = SseClient('http://localhost:$port/test');
  channel.stream.listen((s) {
    channel.sink.add('This is channel 1.');
  }, onError: (e) {
    channel.close();
  }, cancelOnError: true);

  var channel2 = SseClient('http://localhost:$port/test');
  await channel2.onOpen.first;
  channel2.sink.add('This is channel 2.');
}

@JS('browserAction.onClicked.addListener')
external void addListener(Function callback);

@JS('debugger.sendCommand')
external void sendCommand(Debuggee target, String method,
    CommandParams commandParams, Function callback);

@JS('debugger.attach')
external void attach(
    Debuggee target, String requiredVersion, Function callback);

@JS('tabs.query')
external void queryTabs(QueryInfo queryInfo, Function callback);

@JS()
@anonymous
class QueryInfo {
  external bool get active;
  external bool get currentWindow;
  external factory QueryInfo({bool active, bool currentWindow});
}

@JS()
@anonymous
class Debuggee {
  external dynamic get tabId;
  external String get extensionId;
  external String get targetId;
  external factory Debuggee(
      {dynamic tabId, String extensionId, String targetId});
}

@JS()
@anonymous
class CommandParams {
  external String get expression;
  external factory CommandParams({String expression});
}

@JS()
@anonymous
class Tab {
  external int get id;
}
