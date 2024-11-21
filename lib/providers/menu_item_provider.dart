import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';

class MenuItemProvider with ChangeNotifier {
  List<Map<String, dynamic>> _menuItems = [];
  Map<int, int> _quantities = {};

  List<Map<String, dynamic>> get menuItems => _menuItems;
  Map<int, int> get quantities => _quantities;

  Future<void> fetchMenuItems() async {
    _menuItems = await DatabaseHelper.instance.getMenuItems();
    _menuItems.forEach((item) {
      _quantities[item['id']] = 0;
    });
    notifyListeners();
  }

  Future<void> addOrder(int menuItemId, int quantity, double price, String itemName) async {
    double totalPrice = price * quantity;
    await DatabaseHelper.instance.insertOrderHistory({
      'subscriberId': menuItemId,
      'menuId': menuItemId,
      'item_name': itemName,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'quantity': quantity,
      'total_price': totalPrice,
    });
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity) {
    _quantities[itemId] = quantity;
    notifyListeners();
  }
}
