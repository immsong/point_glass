import 'package:flutter/material.dart';

enum ColorMap { turbo, rainbow }

Color colorMapToColor(
  double value,
  ColorMap colorMap, {
  double min = 0,
  double max = 255,
}) {
  final normalized = ((value - min) / (max - min)).clamp(0.0, 1.0);

  return colorMap == ColorMap.turbo
      ? _turboColor(normalized)
      : _rainbowColor(normalized);
}

Color _turboColor(double normalized) {
  const r = [0.18995, 0.5, 0.8, 1.0, 0.9, 0.5];
  const g = [0.07176, 0.5, 0.9, 0.8, 0.3, 0.1];
  const b = [0.23217, 0.9, 0.5, 0.1, 0.05, 0.0];

  final idx = normalized * (r.length - 1);
  final lo = idx.floor().clamp(0, r.length - 2);
  final t = idx - lo;

  return Color.fromARGB(
    255,
    ((r[lo] + t * (r[lo + 1] - r[lo])) * 255).round(),
    ((g[lo] + t * (g[lo + 1] - g[lo])) * 255).round(),
    ((b[lo] + t * (b[lo + 1] - b[lo])) * 255).round(),
  );
}

Color _rainbowColor(double normalized) {
  final hue = (1.0 - normalized) * 240.0;
  final h = hue / 60.0;
  final i = h.floor();
  final f = h - i;
  double r, g, b;
  switch (i % 6) {
    case 0:
      r = 1.0;
      g = f;
      b = 0.0;
      break;
    case 1:
      r = 1.0 - f;
      g = 1.0;
      b = 0.0;
      break;
    case 2:
      r = 0.0;
      g = 1.0;
      b = f;
      break;
    case 3:
      r = 0.0;
      g = 1.0 - f;
      b = 1.0;
      break;
    case 4:
      r = f;
      g = 0.0;
      b = 1.0;
      break;
    default:
      r = 1.0;
      g = 0.0;
      b = 1.0 - f;
      break;
  }
  return Color.fromARGB(
    255,
    (r * 255).round(),
    (g * 255).round(),
    (b * 255).round(),
  );
}
