import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallback;
  final AsyncCallback pausedCallback;
  final AsyncCallback inactiveCallback;
  final AsyncCallback detachedCallback;

  LifecycleEventHandler({this.resumeCallback, this.pausedCallback, this.inactiveCallback, this.detachedCallback});

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallback != null) {
          await resumeCallback();
        }
        break;
      case AppLifecycleState.paused:
        if (pausedCallback != null) {
          await pausedCallback();
        }
        break;
      case AppLifecycleState.inactive:
        if (inactiveCallback != null) {
          await inactiveCallback();
        }
        break;
      case AppLifecycleState.detached:
        if (detachedCallback != null) {
          await detachedCallback();
        }
        break;
      default:
        break;
    }
  }
}
