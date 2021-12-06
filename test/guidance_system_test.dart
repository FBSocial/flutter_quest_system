import 'package:flutter_test/flutter_test.dart';
import 'package:guidance_system/internal/checker.dart';
import 'package:guidance_system/internal/guidance_system.dart';
import 'package:guidance_system/internal/quest.dart';
import 'package:guidance_system/internal/trigger/custom_trigger.dart';
import 'package:guidance_system/internal/trigger/quest_trigger.dart';

enum QuestCondition { c1, c2, c3, c4, c5, c6 }
enum QuestId {
  q1,
  q2,
  q3,
  q4,
  q5,
  q6,
}

main() {
  late GuidanceSystem gs;
  late CustomTrigger ct;

  setUpAll(() {});

  setUp(() {
    gs = GuidanceSystem.instance = GuidanceSystem();
    ct = CustomTrigger.instance = CustomTrigger();
    gs.addTrigger(ct);
  });

  test("single task queue", () {
    gs.addSequence(QuestSequence(quests: [
      Quest(
        id: QuestId.q1,
        triggerChecker: QuestChecker(condition: QuestCondition.c1),
        completeChecker: QuestChecker(condition: QuestCondition.c2),
      ),
      Quest(
        id: QuestId.q2,
        triggerChecker: QuestChecker(condition: QuestCondition.c1),
        completeChecker: QuestChecker(condition: QuestCondition.c2),
      )
    ]));
    gs.addSequence(QuestSequence(quests: [
      Quest(
        id: QuestId.q3,
        triggerChecker: QuestChecker(condition: QuestCondition.c1),
        completeChecker: QuestChecker(condition: QuestCondition.c2),
      )
    ]));

    final q0 = gs.getQuest(QuestId.q1)!;
    final q1 = gs.getQuest(QuestId.q3)!;

    expect(q0.status, QuestStatus.inactive);
    expect(q1.status, QuestStatus.inactive);
    ct.dispatch(QuestTriggerData(condition: QuestCondition.c1));
    expect(q0.status, QuestStatus.activated);
    expect(q1.status, QuestStatus.activated);
    ct.dispatch(QuestTriggerData(condition: QuestCondition.c2));
    expect(q0.status, QuestStatus.completed);
    expect(q1.status, QuestStatus.completed);

    // quest checker should not effect the inactive quests.
    expect(q0.next!.status, QuestStatus.inactive);
    expect(q0.next!.status, QuestStatus.inactive);
    expect(q0.next!.status, QuestStatus.inactive);
  });

  test("auto active sub-quests, and manually complete parent quest", () {
    gs.addSequence(
      QuestSequence(quests: [
        Quest(
            id: QuestId.q4,
            triggerChecker: QuestChecker(condition: QuestCondition.c1),
            completeChecker: QuestChecker(condition: QuestCondition.c2),
            children: [
              Quest.activatedByParent(
                id: QuestId.q5,
                completeChecker: QuestChecker(condition: QuestCondition.c3),
              ),
              Quest.activatedByParent(
                id: QuestId.q6,
                completeChecker: QuestChecker(condition: QuestCondition.c4),
              ),
            ])
      ]),
    );

    final q = gs.questPaths[0][0];

    ct.dispatch(QuestTriggerData(condition: QuestCondition.c1));
    expect(q.status, QuestStatus.activated);
    ct.dispatch(QuestTriggerData(condition: QuestCondition.c2));
    expect(
      q.status != QuestStatus.completed,
      true,
      reason: "before the quest group completed, "
          "you must complete all its sub quests",
    );
    expect(q.children![0].status, QuestStatus.activated);
    expect(q.children![1].status, QuestStatus.activated);

    ct.dispatch(QuestTriggerData(condition: QuestCondition.c3));
    expect(q.children![0].status, QuestStatus.completed);
    expect(q.children![1].status, QuestStatus.activated);
    expect(q.status, QuestStatus.activated);

    ct.dispatch(QuestTriggerData(condition: QuestCondition.c4));
    expect(q.children![0].status, QuestStatus.completed);
    expect(q.children![1].status, QuestStatus.completed);
    expect(q.status, QuestStatus.activated);

    ct.dispatch(QuestTriggerData(condition: QuestCondition.c2));
    expect(q.status, QuestStatus.completed);
  });

  test("auto active sub-quests, and auto complete parent quest", () {
    gs.questPaths.add(
      QuestSequence(quests: [
        Quest.completeByChildren(
            id: QuestId.q1,
            triggerChecker: QuestChecker(condition: QuestCondition.c1),
            children: [
              Quest.activatedByParent(
                id: QuestId.q5,
                completeChecker: QuestChecker(condition: QuestCondition.c3),
              ),
              Quest.activatedByParent(
                id: QuestId.q6,
                completeChecker: QuestChecker(condition: QuestCondition.c4),
              ),
            ])
      ]),
    );

    final q = gs.questPaths[0];

    ct.dispatch(QuestTriggerData(condition: QuestCondition.c1));
    ct.dispatch(QuestTriggerData(condition: QuestCondition.c2));
    expect(
      q.status != QuestStatus.completed,
      true,
      reason: "before the quest group completed, "
          "you must complete all its sub quests",
    );
    ct.dispatch(QuestTriggerData(condition: QuestCondition.c3));
    ct.dispatch(QuestTriggerData(condition: QuestCondition.c4));

    expect(q.status, QuestStatus.completed);
  });
}
