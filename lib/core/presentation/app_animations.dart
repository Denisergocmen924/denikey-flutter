import 'package:flutter/material.dart';

class AppAnim {
  // Süreler
  static const Duration fast   = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow   = Duration(milliseconds: 380);
  static const Duration stagger = Duration(milliseconds: 40);

  // Eğriler
  static const Curve smooth  = Curves.easeOut;
  static const Curve spring  = Curves.easeOutBack;
  static const Curve snappy  = Curves.fastOutSlowIn;

  // Giriş animasyonu gecikmeleri (ekran öğeleri için)
  static Duration entranceDelay(int index) =>
      Duration(milliseconds: index * 75);
}
