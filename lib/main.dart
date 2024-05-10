import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parallax_travel_cards_hero/shared/app_scroll_behavior.dart';
import 'package:parallax_travel_cards_hero/shared/env.dart';
import 'package:parallax_travel_cards_hero/travel_card_demo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static String _pkg = "parallax_travel_cards_hero";
  static String? get pkg => Env.getPackage(_pkg);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(), //para que funcione el mouse
      debugShowCheckedModeBanner: false,
      home: TravelCardDemo(),
    );
  }
}
