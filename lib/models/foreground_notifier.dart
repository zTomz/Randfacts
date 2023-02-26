import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForegroundNotifier extends StateNotifier<AppBrightness> {
  ForegroundNotifier()
      : super(
          AppBrightness.adaptive,
        );

  late SharedPreferences prefInstance;

  void init() async {
    prefInstance = await SharedPreferences.getInstance();

    _initForeground();
  }

  void _initForeground() {
    final foregroundData = prefInstance.getString("foreground");
    if (foregroundData == null) {
      state == AppBrightness.adaptive;
      return;
    }

    if (foregroundData == "light") {
      state == AppBrightness.light;
      return;
    }

    if (foregroundData == "dark") {
      state == AppBrightness.dark;
      return;
    }

    if (foregroundData == "adaptive") {
      state == AppBrightness.adaptive;
      return;
    }
  }

  void changeAppBrightness() async {
    if (state == AppBrightness.adaptive) {
      state = AppBrightness.light;
      await prefInstance.setString("foreground", "light");
      return;
    }

    if (state == AppBrightness.light) {
      state = AppBrightness.dark;
      await prefInstance.setString("foreground", "dark");
      return;
    }

    if (state == AppBrightness.dark) {
      state = AppBrightness.adaptive;
      await prefInstance.setString("foreground", "adaptive");
      return;
    }
  }

  Color getColorForBrightness(BuildContext context) {
    if (state == AppBrightness.light) {
      return Colors.grey.shade800;
    }

    if (state == AppBrightness.dark) {
      return Theme.of(context).textTheme.bodyLarge!.color!;
    }

    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade800
        : Theme.of(context).textTheme.bodyLarge!.color!;
  }
}

enum AppBrightness {
  light,
  dark,
  adaptive,
}
