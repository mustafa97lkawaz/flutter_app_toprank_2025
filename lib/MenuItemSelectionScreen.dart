import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class MenuItemSelectionScreen extends StatefulWidget {
  final int subscriberId;

  MenuItemSelectionScreen({required this.subscriberId});

  @override
  _MenuItemSelectionScreenState createState() => _MenuItemSelectionScreenState();
}

class _MenuItemSelectionScreenState extends State<MenuItemSelectionScreen> {
  List<Map<String, dynamic>> _menuItems = [];
  Map<int, int> _quantities = {}; // Stores the quantity for each menu item

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    _menuItems = await DatabaseHelper.instance.getMenuItems();
    setState(() {
      // Initialize each item with a quantity of 0
      _menuItems.forEach((item) {
        _quantities[item['id']] = 0;
      });
    });
  }

  Future<void> _addOrder(int menuItemId, int quantity, double price, String itemName) async {
    double totalPrice = price * quantity;
    await DatabaseHelper.instance.insertOrderHistory({
      'subscriberId': widget.subscriberId,
      'menuId': menuItemId,
      'item_name': itemName,  // Include item name
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'quantity': quantity,
      'total_price': totalPrice,
    });
  }

  void _confirmOrder() {
    _quantities.forEach((menuItemId, quantity) async {
      if (quantity > 0) {
        final menuItem = _menuItems.firstWhere((item) => item['id'] == menuItemId);
        await _addOrder(
          menuItemId,
          quantity,
          menuItem['price'],
          menuItem['name'],  // Pass the item name here
        );
      }
    });

    Navigator.pop(context, true); // Return to previous screen and refresh data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar( backgroundColor: Colors.white, centerTitle: true, title: Text('المنيو',style: TextStyle(fontFamily: "Cairo"),)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final item = _menuItems[index];
            final itemId = item['id'];
            final itemPrice = item['price'];
            final itemQuantity = _quantities[itemId] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                 color: Colors.white,
                boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, 4),
                      ),
                    ],),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset("images/tea.png"),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['name']}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '\$${itemPrice.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (itemQuantity == 0)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _quantities[itemId] = 1; // Set to 1 to show increment/decrement
                                });
                              },
                              child: Text("اضافة",style: TextStyle(color: Colors.white,fontFamily: "Cairo"),),
                              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 71, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      if (_quantities[itemId]! > 1) {
                                        _quantities[itemId] = itemQuantity - 1;
                                      } else {
                                        _quantities[itemId] = 0; // Reset to 0 if decrementing from 1
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  itemQuantity.toString(),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      _quantities[itemId] = itemQuantity + 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          Text(
                            'المجموع: \$${(itemQuantity * itemPrice).toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Cairo"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmOrder,
        icon: Icon(Icons.check),
        label: Text('تاكيد الطلب',                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Cairo"),
),
        backgroundColor: Colors.green,
      ),
    );
  }
}
