import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:quest_system/internal/event_dispatcher.dart';
import 'package:quest_system/internal/quest_system.dart';
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

class RouteTrigger extends NavigatorObserver
    with EventDispatcher<QuestTriggerData> {
  static late RouteTrigger instance = RouteTrigger();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      dispatch(QuestTriggerData(
          condition: RouteCondition(
              routeName: route.settings.name!, isRemove: false)));
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      dispatch(QuestTriggerData(
          condition:
              RouteCondition(routeName: route.settings.name!, isRemove: true)));
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      dispatch(QuestTriggerData(
          condition:
              RouteCondition(routeName: route.settings.name!, isRemove: true)));
    }
    super.didRemove(route, previousRoute);
  }

  @override
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
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void dispatch(QuestTriggerData data) {
    if (QuestSystem.verbose) log("QuestTrigger dispatch $data", name: "QUEST");
    super.dispatch(data);
  }
}
