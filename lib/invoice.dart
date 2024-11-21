import 'package:cafe_management_app/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculationListScreen extends StatefulWidget {
  final int subscriberId;

  CalculationListScreen({required this.subscriberId});

  @override
  _CalculationListScreenState createState() => _CalculationListScreenState();
}

class _CalculationListScreenState extends State<CalculationListScreen> {
  Map<String, double> itemQuantities = {};
  Map<String, double> itemTotalPrices = {};
  double totalAmount = 0.0;
  String subscriberName = '';
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadData();
  }

  Future<void> _loadData() async {
    String name = await DatabaseHelper.instance.getSubscriberName(widget.subscriberId);
    await _calculateItemsAndTotal();
    setState(() {
      subscriberName = name;
    });
  }

  Future<void> _calculateItemsAndTotal() async {
    final orders = await DatabaseHelper.instance.getOrderHistory(widget.subscriberId);
    Map<String, double> quantities = {};
    Map<String, double> totalPrices = {};
    double total = 0.0;

    for (var order in orders) {
      double itemTotalPrice = (order['total_price'] as num).toDouble();
      String itemName = order['item_name'];
      double quantity = (order['quantity'] as num).toDouble();

      total += itemTotalPrice;
      quantities[itemName] = (quantities[itemName] ?? 0) + quantity;
      totalPrices[itemName] = (totalPrices[itemName] ?? 0) + itemTotalPrice;
    }

    setState(() {
      itemQuantities = quantities;
      itemTotalPrices = totalPrices;
      totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar:  AppBar(centerTitle: true,
        title: Text(' الفاتورة', style: TextStyle(color: Color.fromARGB(255, 71, 0, 0),fontFamily: "Cairo")),foregroundColor: Color.fromARGB(255, 71, 0, 0),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      child: Image.asset("images/logo.png"),
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.grey),
                  Text('التاريخ: $currentDate', style: TextStyle(fontSize: 16)),
                  Text('المشترك: $subscriberName', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Items Section
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Text(
                      'تفاصيل الطلبيات',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Cairo"),
                    ),
                    Divider(color: Colors.grey),
                    Expanded(
                      child: itemQuantities.isNotEmpty
                          ? ListView.separated(
                              itemCount: itemQuantities.keys.length,
                              separatorBuilder: (context, index) => Divider(color: Colors.grey),
                              itemBuilder: (context, index) {
                                String itemName = itemQuantities.keys.elementAt(index);
                                double quantity = itemQuantities[itemName] ?? 0;
                                double totalPrice = itemTotalPrices[itemName] ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(itemName, style: TextStyle(fontSize: 16)),
                                      Text('الكمية: $quantity', style: TextStyle(fontSize: 16)),
                                      Text('\$${totalPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'No items to display',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Total Section
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'مجموع الحساب',                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Cairo"),

                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Footer Section with Delete Button
            // ElevatedButton(
            //   onPressed: () async {
            //     await DatabaseHelper.instance.deleteOrderHistory(widget.subscriberId);
            //     Navigator.pop(context);
            //   },
            //   style: ElevatedButton.styleFrom(backgroundColor:Color.fromARGB(255, 81, 3, 3),foregroundColor: Colors.white ,
            //     padding: EdgeInsets.symmetric(vertical: 12),
            //     textStyle: TextStyle(fontSize: 18),
            //   ),
            //   child: Text('Delete All Orders'),
            // ),
            ///////////////////////////////
//             ElevatedButton(
//   onPressed: () async {
//     // Insert the invoice into the history table
//     await DatabaseHelper.instance.insertInvoiceHistory(
//       widget.subscriberId, // Subscriber ID
//       currentDate,          // Current date for the invoice
//       totalAmount,   subscriberName, "put data here",     // Total amount of the invoice
//     );

//     // Now, save each individual order into the order history table
//     // for (var itemName in itemQuantities.keys) {
//     //   await DatabaseHelper.instance.insertOrderHistory({
//     //     'subscriberId': widget.subscriberId,
//     //     'menuId': itemQuantities.keys.toList().indexOf(itemName) + 1,  // You may need to handle actual MenuItem IDs
//     //     'item_name': itemName,
//     //     'date': currentDate,
//     //     'quantity': itemQuantities[itemName],
//     //     'total_price': itemTotalPrices[itemName],
//     //   });
//     // }

//     // After saving, you can delete the order history if needed
//     await DatabaseHelper.instance.deleteOrderHistory(widget.subscriberId);

//     // Navigate back to the previous screen
//     Navigator.pop(context);
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Color.fromARGB(255, 81, 3, 3),
//     foregroundColor: Colors.white,
//     padding: EdgeInsets.symmetric(vertical: 12),
//     textStyle: TextStyle(fontSize: 18),
//   ),
//   child: Text('Finalize and Save Invoice'),
// )
Container(
    padding: EdgeInsets.all(8), // Optional padding for the button
    decoration: BoxDecoration( gradient: LinearGradient(
                  colors: [Colors.black, Color.fromARGB(255, 71, 0, 0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ), boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 4),
        ),
      ],
      color: Colors.white, // Background color of the button
      borderRadius: BorderRadius.circular(30), // Rounded corners
    ),
  child: ElevatedButton(
    onPressed: () async {
      // Build the order details string
      String orderDetails = '';
      for (var itemName in itemQuantities.keys) {
        double quantity = itemQuantities[itemName] ?? 0;
        double totalPrice = itemTotalPrices[itemName] ?? 0;
        orderDetails += '$itemName (Qty: $quantity) - \$${totalPrice.toStringAsFixed(2)}\n';
      }
  
      // Insert the invoice into the history table with the order details
      await DatabaseHelper.instance.insertInvoiceHistory(
        widget.subscriberId, // Subscriber ID
        currentDate,          // Current date for the invoice
        totalAmount,          // Total amount of the invoice
        subscriberName,       // Subscriber's name
        orderDetails,         // Order details as a string
      );
  
      // After saving, you can delete the order history if needed
      await DatabaseHelper.instance.deleteOrderHistory(widget.subscriberId);
  
      // Navigate back to the previous screen
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(elevation: 0,
      backgroundColor: Color.fromARGB(0, 81, 3, 3),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 2),
      textStyle: TextStyle(fontSize: 18),
    ),
    child: Text('اكمال الحساب',                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Cairo"),
),
  ),
)


          ],
        ),
      ),
    );
  }
}
