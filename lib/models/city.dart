import 'package:flutter/material.dart';
import 'package:parallax_travel_cards_hero/models/hotel.dart';

class City {
  final String name;
  final String title;
  final String description;
  final Color color;
  final List<Hotel> hotels;

  City(
      {required this.title,
      required this.name,
      required this.description,
      required this.color,
      required this.hotels});
}
