import 'package:cafe_management_app/Subscriber%20Details%20Screen.dart';
import 'package:cafe_management_app/database_helper.dart';
import 'package:cafe_management_app/database_helper.dart';
import 'package:cafe_management_app/database_helper.dart';
import 'package:cafe_management_app/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'database_helper.dart';
import 'database_helper.dart';

const Color primaryColor = Color.fromARGB(255, 71, 0, 0); // Coffee Brown
const Color secondaryColor = Color(0xFF3E2723); // Dark Coffee Brown
const Color accentColor = Color(0xFF8D6E63); // Light Coffee
const Color backgroundColor = Color(0xFFFBE9E7); // Soft Beige/Off-White
const Color textColor = Color(0xFF3E2723); // Dark Coffee for text
const Color successColor =
    Color(0xFF388E3C); // Green for success (Order Completed)
const Color errorColor = Color(0xFFE53935); // Soft Red for errors

class SubscriberManagementScreen extends StatefulWidget {
  @override
  _SubscriberManagementScreenState createState() =>
      _SubscriberManagementScreenState();
}

class _SubscriberManagementScreenState
    extends State<SubscriberManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _subscribers = [];
  List<Map<String, dynamic>> _filteredSubscribers = [];

  @override
  void initState() {
    super.initState();
    _fetchSubscribers();
    _searchController.addListener(_filterSubscribers);
  }

  Future<void> _fetchSubscribers() async {
    final subscribers = await DatabaseHelper.instance.getSubscribers();
    setState(() {
      _subscribers = subscribers;
      _filteredSubscribers = subscribers;
    });
  }

  void _filterSubscribers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubscribers = _subscribers
          .where(
              (subscriber) => subscriber['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
        final databasehelper = Provider.of<DatabaseHelper>(context);

    return Directionality(textDirection: TextDirection.rtl,
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(centerTitle: true,foregroundColor:Colors.white ,
          title: Text('ادارة  المشتركين',style: TextStyle(color: Colors.white,fontFamily: "Cairo"),),
          backgroundColor: primaryColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: Offset(0, 2), // Shadow position
                      blurRadius: 5, // Shadow blur
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'ابجث عن مشترك',
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.transparent), // Remove the border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.transparent), // Remove the border
                    ),
                    border: InputBorder.none, // Remove the bottom line
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSubscribers.length,
                itemBuilder: (context, index) {
                  final subscriber = _filteredSubscribers[index];
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 4),
        ),
      ],),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Icon(
                        Icons.person,
                        color: primaryColor,
                        size: 35,
                      ),
                      title: Row(
                        children: [ Text(
                            " المشترك :",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,fontFamily: "Cairo"),
                          ),
                          Text(
                            subscriber['name'],
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,fontFamily: "Cairo"),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: errorColor),
                            onPressed: () => _showDeleteConfirmationDialog(
                                context, subscriber['id']),
                          ),
                          // Icon(Icons.arrow_forward, color: primaryColor),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriberDetailsScreen(
                                subscriberId: subscriber['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddSubscriberDialog(context),
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: primaryColor,
        ),
      ),
    );
  }

  void _showAddSubscriberDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(backgroundColor: Colors.white,elevation: 0,
          title:
              Text('اضافة مستخدم جديد', style: TextStyle(color: primaryColor,fontFamily: "Cairo")),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'ادخل الاسم',
              labelStyle: TextStyle(color: primaryColor,fontFamily: "Cairo"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('الغاء', style: TextStyle(color: primaryColor,fontFamily: "Cairo")),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await DatabaseHelper.instance
                      .insertSubscriber(nameController.text);
                  Navigator.pop(context);
                  _fetchSubscribers();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم اضاقة مشترك جديد')));
                }
              },
              child: Text('اضافة',style: TextStyle(fontFamily: "Cairo"),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

 void _showDeleteConfirmationDialog(BuildContext context, int subscriberId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(backgroundColor: Colors.white,elevation: 0,
        title: Text('حذف المشترك', style: TextStyle(color: errorColor)),
        content: Text('هل أنت متأكد أنك تريد حذف هذا المشترك؟',style: TextStyle(fontFamily: "Cairo"),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: primaryColor,fontFamily: "Cairo")),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteSubscriber(subscriberId);
              Navigator.pop(context);
              _fetchSubscribers();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف المشترك')));
            },
            child: Text('حذف',style: TextStyle(fontFamily: "Cairo"),),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      );
    },
  );
}

}
