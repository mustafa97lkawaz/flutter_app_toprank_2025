import 'package:flutter/material.dart';

class MenuProvider with ChangeNotifier {
  // Example of moving a function to a provider
  void confirmOrder(Map<int, int> quantities) {
    quantities.forEach((menuItemId, quantity) async {
      // Logic to confirm order
    });
    notifyListeners();
  }

  void clearControllers(TextEditingController nameController) {
    nameController.clear();
    notifyListeners();
  }

  void showEditDialog(Map<String, dynamic> item, TextEditingController nameController) {
    nameController.text = item['name'];
    notifyListeners();
  }

  // Add other menu-related functions here
}
