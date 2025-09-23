import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
  final themeProvider = StateProvider<ThemeMode>((ref) {
    return ThemeMode.dark;

    return ThemeMode.light;
});
});