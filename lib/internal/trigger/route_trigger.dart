import 'package:flutter/cupertino.dart';
import 'package:quest_system/internal/trigger/quest_trigger.dart';

class RouteCondition {
  final String routeName;
  final bool isRemove;

  const RouteCondition({required this.routeName, required this.isRemove});

  @override
  bool operator ==(Object other) {
    if (other is RouteCondition) {
      return other.routeName == routeName && other.isRemove == isRemove;
    }
    return false;
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  @override
  String toString() {
    return 'RouteCondition{routeName: $routeName, isRemove: $isRemove}';
  }
}

typedef DidPushCallback = void Function(
    Route<dynamic> route, Route<dynamic>? previousRoute);

class MyNavigatorObserver extends NavigatorObserver {
  final DidPushCallback didPushCallBack;
  final DidPushCallback didPopCallBack;
  final DidPushCallback didRemoveCallBack;
  final DidPushCallback didReplaceCallBack;
  MyNavigatorObserver(this.didPushCallBack, this.didPopCallBack,
      this.didRemoveCallBack, this.didReplaceCallBack);
}

class RouteTrigger extends QuestTrigger {
  static late RouteTrigger instance = RouteTrigger();

  late NavigatorObserver navigatorObserver;

  RouteTrigger() {
    navigatorObserver = MyNavigatorObserver(didPush, didPush, didPush, didPush);
  }

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      dispatch(QuestTriggerData(
          condition: RouteCondition(
              routeName: route.settings.name!, isRemove: false)));
    }
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      dispatch(QuestTriggerData(
          condition:
              RouteCondition(routeName: route.settings.name!, isRemove: true)));
    }
  }

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      dispatch(QuestTriggerData(
          condition:
              RouteCondition(routeName: route.settings.name!, isRemove: true)));
    }
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      dispatch(QuestTriggerData(
          condition: RouteCondition(
              routeName: newRoute!.settings.name!, isRemove: false)));
    }
    if (oldRoute?.settings.name != null) {
      dispatch(QuestTriggerData(
          condition: RouteCondition(
              routeName: oldRoute!.settings.name!, isRemove: true)));
    }
  }
}
