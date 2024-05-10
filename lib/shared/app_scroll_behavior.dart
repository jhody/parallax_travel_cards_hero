// Add support for testing drag gestures on desktop
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppScrollBehavior extends ScrollBehavior {
  @override
  // Agregue arrastrar el mouse en el escritorio para realizar pruebas de respuesta más sencillas
  Set<PointerDeviceKind> get dragDevices {
    final devices = Set<PointerDeviceKind>.from(super.dragDevices);
    devices.add(PointerDeviceKind.mouse);
    return devices;
  }
}