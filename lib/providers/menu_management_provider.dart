import 'package:flutter/material.dart';
import '../database_helper.dart';

class MenuManagementProvider with ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Future<void> addMenuItem() async {
    final db = DatabaseHelper.instance;
    await db.insertMenuItem({
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.parse(priceController.text),
      'image': '',
    });
    clearControllers();
    notifyListeners();
  }

  Future<void> editMenuItem(int id) async {
    final db = DatabaseHelper.instance;
    await db.updateMenuItem(id, {
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.parse(priceController.text),
    });
    clearControllers();
    notifyListeners();
  }

  Future<void> deleteMenuItem(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteMenuItem(id);
    notifyListeners();
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> item) {
    nameController.text = item['name'];
    descriptionController.text = item['description'];
    priceController.text = item['price'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Item Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                clearControllers();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                editMenuItem(item['id']);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void clearControllers() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
  }
}
