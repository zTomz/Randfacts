import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:randfacts/models/background_notifier.dart';
import 'package:randfacts/models/fact.dart';
import 'package:randfacts/models/fact_notifier.dart';
import 'package:randfacts/models/foreground_notifier.dart';

final factsProvider = StateNotifierProvider<FactNotifier, List<Fact>>(
  (ref) => FactNotifier(),
);

final backgroundProvider = StateNotifierProvider<BackgroundNotifier, File?>(
  (ref) => BackgroundNotifier(),
);

final foregroundProvider = StateNotifierProvider<ForegroundNotifier, AppBrightness>((ref) => ForegroundNotifier());