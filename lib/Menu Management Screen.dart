import 'package:flutter/material.dart';
import 'database_helper.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _addMenuItem() async {
    final db = DatabaseHelper.instance;
    await db.insertMenuItem({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'image': '', // For simplicity, leave image as empty
    });
    _clearControllers();
    setState(() {}); // Refresh UI
  }

  Future<void> _editMenuItem(int id) async {
    final db = DatabaseHelper.instance;
    await db.updateMenuItem(id, {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
    });
    _clearControllers();
    setState(() {}); // Refresh UI
  }

  Future<void> _deleteMenuItem(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteMenuItem(id);
    setState(() {}); // Refresh UI
  }

  void _clearControllers() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
  }

  void _showEditDialog(Map<String, dynamic> item) {
    _nameController.text = item['name'];
    _descriptionController.text = item['description'];
    _priceController.text = item['price'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Item Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearControllers();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editMenuItem(item['id']);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('ادارة العناصر',style: TextStyle(fontFamily: "Cairo"),),
          backgroundColor: Color.fromARGB(255, 71, 0, 0),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nameController, 'الاسم', Icons.label),
              SizedBox(height: 12.0),
              _buildTextField(_descriptionController, 'الوصف', Icons.description),
              SizedBox(height: 12.0),
              _buildTextField(_priceController, 'السعر', Icons.attach_money, TextInputType.number),
              SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: _addMenuItem,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('اضافة', style: TextStyle(color: Colors.white,fontFamily: "Cairo")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 71, 0, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              SizedBox(height: 20.0),
              Expanded(child: _buildMenuList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, [TextInputType inputType = TextInputType.text]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 71, 0, 0)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getMenuItems(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(child: Text('No menu items added yet.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: Image.asset("images/tea.png"),
                title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${item['price']}',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMenuItem(item['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
