import 'dart:math';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randfacts/models/fact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FactNotifier extends StateNotifier<List<Fact>> {
  List<String> allFacts = [];
  late Box<Fact> box;
  late SharedPreferences prefInstance;

  final myUuid = const Uuid();

  FactNotifier() : super([]);

  String? getImagePath() {
    final data = prefInstance.getString("background");
    if (data == null || data == "none") {
      return null;
    }
    return data;
  }

  void loadFirstFacts() async {
    box = await Hive.openBox<Fact>("factsBox");
    allFacts =
        (await rootBundle.loadString("assets/facts/all_facts.txt")).split("\n");
    prefInstance = await SharedPreferences.getInstance();

    state = [];

    state = [
      ...state,
      Fact(
        text: allFacts[Random().nextInt(allFacts.length)],
        uuid: myUuid.v4(),
      ),
      Fact(
        text: allFacts[Random().nextInt(allFacts.length)],
        uuid: myUuid.v4(),
      ),
    ];
  }

  void loadMoreFacts({int count = 1}) {
    final newFact = allFacts[Random().nextInt(allFacts.length)];
    state = [
      ...state,
      Fact(
        text: newFact,
        isLiked: false,
        uuid: myUuid.v4(),
      ),
    ];
  }

  void toggleLikeFact(Fact fact) {
    final changedFact = Fact(
      text: fact.text,
      isLiked: !fact.isLiked,
      uuid: fact.uuid,
    );

    state = [
      for (Fact myFact in state)
        if (myFact.uuid == fact.uuid)
          changedFact
        else
          Fact(
            text: myFact.text,
            isLiked: myFact.isLiked,
            uuid: myFact.uuid,
          )
    ];

    if (changedFact.isLiked) {
      box.put(changedFact.uuid, changedFact);
    } else {
      box.delete(changedFact.uuid);
    }
  }

  List<Fact> getLikedFacts() {
    return box.values.toList();
  }
}
