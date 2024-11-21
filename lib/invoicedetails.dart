import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  InvoiceDetailScreen({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(invoice['date']);
    final totalAmount = invoice['total_amount'];
    final subscriberName = invoice['subscriberName'] ?? 'غير متوفر';
    final invoiceId = invoice['id'];
    final additionalInfo = invoice['additionalInfo'] ?? 'غير متوفر';

    return Scaffold(backgroundColor: Colors.white,
      appBar:  AppBar(centerTitle: true,
        title: Text('  الفاتورة', style: TextStyle(color: Color.fromARGB(255, 71, 0, 0),fontFamily: "Cairo")),foregroundColor: Color.fromARGB(255, 71, 0, 0),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
             boxShadow: [
        BoxShadow(
          blurRadius: 6,
          color: Colors.black.withOpacity(0.1),
          offset: Offset(0, 4),
        ),
      ],
          //  border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
             
              // Invoice Details Section
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'التاريخ: ${DateFormat('yyyy-MM-dd').format(date)}',
                      style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'المشترك: $subscriberName',
                      style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'المبلغ الإجمالي: \$${totalAmount != null ? totalAmount.toStringAsFixed(2) : '0.00'}',
                      style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 177, 177, 177),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'معلومات إضافية:',
                            style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    Container(
                      width: 300,
                      child: Center(
                        child: Text(
                          additionalInfo,
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            //  Divider(thickness: 2),

              // Footer Section
           ],
          ),
        ),
      ),
    );
  }
}
