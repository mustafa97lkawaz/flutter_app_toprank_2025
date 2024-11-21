import 'package:cafe_management_app/MenuItemSelectionScreen.dart';
import 'package:cafe_management_app/invoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format the date
import 'database_helper.dart';

// Define color constants
const Color primaryColor = Color.fromARGB(255, 71, 0, 0); // Coffee Brown
const Color secondaryColor = Color(0xFF3E2723); // Dark Coffee Brown
const Color accentColor = Color(0xFF8D6E63); // Light Coffee
const Color backgroundColor = Color(0xFFFBE9E7); // Soft Beige/Off-White
const Color textColor = Color(0xFF3E2723); // Dark Coffee for text
const Color successColor = Color(0xFF388E3C); // Green for success (Order Completed)
const Color errorColor = Color(0xFFE53935); // Soft Red for errors
const Color dividerColor = Color(0xFFBCAAA4); // Light Brown for dividers
class SubscriberDetailsScreen extends StatefulWidget {
  final int subscriberId;

  SubscriberDetailsScreen({required this.subscriberId});

  @override
  _SubscriberDetailsScreenState createState() => _SubscriberDetailsScreenState();
}

class _SubscriberDetailsScreenState extends State<SubscriberDetailsScreen> {
  double totalPrice = 0.0;
 String subscriberName = '';
  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
    _loadData();
  }
   Future<void> _loadData() async {
    String name = await DatabaseHelper.instance.getSubscriberName(widget.subscriberId);
    setState(() {
     subscriberName = name;
    });
  }

  // Calculate the total price of orders for the subscriber
  Future<void> _calculateTotalPrice() async {
    final orders = await DatabaseHelper.instance.getOrderHistory(widget.subscriberId);
    double total = 0.0;
    for (var order in orders) {
      total += (order['total_price'] ?? 0.0);
    }
    setState(() {
      totalPrice = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true,
        title: Text('تفاصيل المستخدم', style: TextStyle(color: primaryColor,fontFamily: "Cairo")),foregroundColor: primaryColor,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color.fromARGB(255, 71, 0, 0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16),top: Radius.circular(16)),
              ),
              child: Column(
                children: [ Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' المشترك: ${subscriberName}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,fontFamily: "Cairo"
                        ),
                      ),
                      Icon(Icons.person, color: Color.fromARGB(255, 255, 255, 255), size: 30),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'مجموع الحساب: \$${totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,fontFamily: "Cairo"
                        ),
                      ),
                      Icon(Icons.history, color: const Color.fromARGB(0, 255, 255, 255), size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>( 
              future: DatabaseHelper.instance.getOrderHistory(widget.subscriberId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('لا يوجد عنصر', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data![index];
                    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(order['date']));

                    return  Padding(
  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
     // contentPadding: EdgeInsets.all(12),
      title: Text(
        order['item_name'] ?? 'No Item Name',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textColor,
          fontFamily: "Cairo",
          letterSpacing: 0.5,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الكمية: ${order['quantity']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: "Cairo",
              ),
            ),
            SizedBox(height: 4),
            Text(
              'التاريخ: $formattedDate',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: "Cairo",
              ),
            ),
          ],
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '\$${order['total_price'].toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: successColor,
            fontFamily: "Cairo",
          ),
        ),
      ),
    ),
  ),
);

                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuItemSelectionScreen(subscriberId: widget.subscriberId),
            ),
          );

          if (result == true) {
            _calculateTotalPrice(); // Recalculate total price
            setState(() {}); // Refresh orders list
          }
        },
        label: Text('طلب جديد',                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Cairo"),
),
        icon: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
     bottomNavigationBar: BottomAppBar(
  color: Color.fromARGB(255, 255, 255, 255),elevation: 0,
  child: Container(
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
    child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [Text('الحساب', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255),fontFamily: "Cairo")),
        IconButton(
          icon: Icon(
            Icons.calculate,
            color: Color.fromARGB(255, 255, 255, 255), // Icon color
          ),
          onPressed: () async {
            // Navigate to the calculation screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalculationListScreen(subscriberId: widget.subscriberId),
              ),
            );
          },
        ),
      ],
    ),
  ),
),

    );
  }
}
