import 'package:flutter/material.dart';

class ExampleProvider with ChangeNotifier {
  String _exampleData = "Initial Data";

  String get exampleData => _exampleData;

  void updateData(String newData) {
    _exampleData = newData;
    notifyListeners();
  }
}
