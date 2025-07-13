import 'package:flutter/material.dart';

/// A class to hold configuration data for the app.
class Config {
  /// A list of all possible subjects.
  static List<String> allSubjects = [
    "Deutsch",
    "Englisch",
    "Französisch",
    "Latein",
    "Spanisch",
    "Italienisch",
    "Russisch",
    "Mathematik",
    "Physik",
    "Chemie",
    "Biologie",
    "Informatik",
    "Geschichte",
    "Politik und Gesellschaft",
    "Wirtschaft und Recht",
    "Geographie",
    "Ethik",
    "Religion",
    "Musik",
    "Kunst",
    "Sport",
    "W-Seminar"
  ];

  /// A list of all available colors for subjects.
  static final List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightGreen,
  ];
}
