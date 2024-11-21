// import 'package:cafe_management_app/invoicedetails.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'database_helper.dart'; // Ensure that DatabaseHelper is imported correctly

// class InvoiceHistoryScreen extends StatefulWidget {
//   @override
//   _InvoiceHistoryScreenState createState() => _InvoiceHistoryScreenState();
// }

// class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
//   List<Map<String, dynamic>> invoices = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadInvoiceHistory();
//   }

//   Future<void> _loadInvoiceHistory() async {
//     // Fetch invoices for all subscribers
//     List<Map<String, dynamic>> fetchedInvoices = await DatabaseHelper.instance.getAllInvoiceHistory();
//     setState(() {
//       invoices = fetchedInvoices;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(backgroundColor: Colors.white,
//       appBar:  AppBar(centerTitle: true,
//         title: Text(' سجل الفواتير', style: TextStyle(color: Color.fromARGB(255, 71, 0, 0),fontFamily: "Cairo")),foregroundColor: Color.fromARGB(255, 71, 0, 0),
//         backgroundColor: Color.fromARGB(255, 255, 255, 255),
//       ),
//       body: invoices.isEmpty
//           ? Center(
//               child: Text(
//                 'No invoice history available.',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               itemCount: invoices.length,
//               itemBuilder: (context, index) {
//                 final invoice = invoices[index];
//                 final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(invoice['date']));
//                 final totalAmount = invoice['total_amount'];  // Use total_amount here
//                 final subscriberName = invoice['subscriberName'] ?? 'Unknown';  // Assuming subscriber's name is stored in the invoice

//                 return  Padding(
//   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//   child: Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           blurRadius: 6,
//           color: Colors.black.withOpacity(0.1),
//           offset: Offset(0, 4),
//         ),
//       ],
//     ),
//     child: ListTile(
//       contentPadding: EdgeInsets.all(16),
//       title: Text(
//         'فاتورة المشترك $subscriberName بتاريخ $date',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           fontFamily: "Cairo",
//           color: Colors.black87,
//         ),
//       ),
//       subtitle: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Text(
//           'المبلغ الإجمالي: \$${totalAmount != null ? totalAmount.toStringAsFixed(0) : '0.00'}',
//           style: TextStyle(
//             fontSize: 16,
//             fontFamily: "Cairo",
//             color: const Color.fromARGB(137, 0, 0, 0),
//           ),
//         ),
//       ),
//       trailing: Container(
//         padding: EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color:Color.fromARGB(255, 71, 0, 0).withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           Icons.arrow_forward_ios,
//           color: Color.fromARGB(255, 71, 0, 0),
//           size: 20,
//         ),
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => InvoiceDetailScreen(invoice: invoice),
//           ),
//         );
//       },
//     ),
//   ),
// );

//               },
//             ),
//     );
//   }
// }

import 'package:cafe_management_app/invoicedetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart'; // Ensure that DatabaseHelper is imported correctly

class InvoiceHistoryScreen extends StatefulWidget {
  @override
  _InvoiceHistoryScreenState createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  List<Map<String, dynamic>> invoices = [];
  List<Map<String, dynamic>> filteredInvoices = [];
  TextEditingController _dateController = TextEditingController();

  int _limit = 5; // Number of items per page
  int _offset = 0; // Current page offset
  bool _isLoading = false; // To prevent multiple loads
  bool _hasMore = true; // To track if more invoices are available

  @override
  void initState() {
    super.initState();
    _loadInvoiceHistory();
  }

  // Function to load invoices with pagination
  Future<void> _loadInvoiceHistory() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> fetchedInvoices = await DatabaseHelper.instance.getAllInvoiceHistory(
      limit: _limit,
      offset: _offset,
    );

    setState(() {
      _isLoading = false;
      _offset += _limit; // Increase offset for the next page
      if (fetchedInvoices.isEmpty) {
        _hasMore = false; // No more data available
      } else {
        invoices.addAll(fetchedInvoices);
        filteredInvoices = invoices; // Initially, show all invoices
      }
    });
  }

  // Function to filter invoices by selected date
  void _filterInvoicesByDate(String selectedDate) {
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        final invoiceDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(invoice['date'])); 
        return invoiceDate == selectedDate;
      }).toList();
    });
  }

  // Function to open the DatePicker and set the selected date
  void _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      _dateController.text = formattedDate;
      _filterInvoicesByDate(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'سجل الفواتير',
          style: TextStyle(color: Color.fromARGB(255, 71, 0, 0), fontFamily: "Cairo"),
        ),
        foregroundColor: Color.fromARGB(255, 71, 0, 0),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Color.fromARGB(255, 71, 0, 0)),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: filteredInvoices.isEmpty
          ? Center(
              child: Text(
                'No invoice history available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  _loadInvoiceHistory(); // Load more invoices when the user reaches the bottom
                }
                return false;
              },
              child: ListView.builder(
                itemCount: filteredInvoices.length + (_hasMore ? 1 : 0), // Add one for the loading indicator
                itemBuilder: (context, index) {
                  if (index == filteredInvoices.length) {
                    return Center(child: CircularProgressIndicator()); // Show loading spinner at the bottom
                  }
                  final invoice = filteredInvoices[index];
                  final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(invoice['date']));
                  final totalAmount = invoice['total_amount'];
                  final subscriberName = invoice['subscriberName'] ?? 'Unknown';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          'فاتورة المشترك $subscriberName بتاريخ $date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Cairo",
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'المبلغ الإجمالي: \$${totalAmount != null ? totalAmount.toStringAsFixed(0) : '0.00'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Cairo",
                              color: const Color.fromARGB(137, 0, 0, 0),
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 71, 0, 0).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Color.fromARGB(255, 71, 0, 0),
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailScreen(invoice: invoice),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
