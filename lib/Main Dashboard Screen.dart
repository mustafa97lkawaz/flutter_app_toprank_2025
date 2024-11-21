import 'dart:async';
import 'package:cafe_management_app/Menu%20Management%20Screen.dart';
import 'package:cafe_management_app/Subscriber%20Management%20Screen.dart';
import 'package:cafe_management_app/contact%20us.dart';
import 'package:cafe_management_app/database_helper.dart';
import 'package:cafe_management_app/historyinvoices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final List<String> _bannerImages = [
    'images/1.jpeg',
    'images/2.jpg',
    'images/3.jpg',
  ];

  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  int _totalSubscribers = 0;
  double _totalOrderPrices = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startBannerTimer();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    _totalSubscribers = await DatabaseHelper.instance.getTotalSubscribers();
    _totalOrderPrices = await DatabaseHelper.instance.getTotalOrderPrices();
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _bannerImages.length;
        });

        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 70,
                child: Image.asset('images/logo.png'),
              ),
              // Search Bar Container
              Container(
                width: 230,
                height: 35,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 236, 236, 236),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(width: 25, child: Image.asset("images/777.png")),
                    Text(
                      "باقي",
                      style: TextStyle(fontSize: 14, fontFamily: "Cairo"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Text(
                        "120", // Replace with your expiration date variable
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    Text(
                      "يوم",
                      style: TextStyle(fontSize: 14, fontFamily: "Cairo"),
                    ),
                    SizedBox(width: 8),
                    // Change icon to something related to dates
                  ],
                ),
              ),
              // Logo on the Right
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            // Total Subscribers and Total Order Prices Panels
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //  _buildInfoPanel('Total Subscribers', _totalSubscribers.toString(),Icons.person),
                  _buildInfoPanel(
                    'مجموع الديون',
                    '\$${_totalOrderPrices.toStringAsFixed(0)}',
                    'عدد المشتركين',
                    _totalSubscribers.toString(),
                    Icons.price_change,
                    Icons.person,
                  )
                ],
              ),
            ),

            // Animated Banner (Carousel)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 90.0,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentIndex = index % _bannerImages.length;
                    });
                  },
                  itemBuilder: (context, index) {
                    final realIndex = index % _bannerImages.length;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage(_bannerImages[realIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Dots Indicator
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _bannerImages.map((url) {
                  int index = _bannerImages.indexOf(url);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Color(0xFFB98068)
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Rest of the Dashboard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDashboardCard(
                      context,
                      'ادارة العناصر',
                      "images/77.png",
                      Color(0xFFB98068),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuManagementScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'ادارة  المشتركين',
                      "images/use.png",
                      Color(0xFF8C6D62),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriberManagementScreen(),
                        ),
                      ).then((_) =>
                          _fetchDashboardData()), 
                    ),
                    // ElevatedButton(
                    //     onPressed: () async {
                    //    await DatabaseHelper.instance.exportDatabase();
                    //    // await DatabaseHelper.instance.importDatabase();

                    //     },
                    
                      //  child: Text("export")),
                    _buildDashboardCard(
                      context,
                      'سجل الحسابات',
                      "images/pot.png",
                      Color(0xFF70534A),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceHistoryScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'اتصل بنا',
                      "images/contact.png",
                      Color(0xFFD4A373),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactUsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(String title, String value, String title2,
      String value2, IconData icon, IconData icon2) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color.fromARGB(255, 97, 0, 0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFAD02E),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon2, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(
                title2,
                style: const TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                value2,
                style: const TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFAD02E),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                  width: 100, height: 100, child: Image.asset("images/555.png"))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title,
      String imageName, Color iconColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(
                            255, 75, 30, 30), // dark brown color for black tea
                        Color.fromARGB(255, 65, 65,
                            65), // lighter brown color for black tea
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                            0.3), // deeper shadow to match tea colors
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(
                            3, 6), // offset for a more pronounced shadow effect
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 140),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 35,
                child: Image.asset(
                  '$imageName', // dynamically loads the image from assets
                  // color: iconColor,
                  width: 66,
                  height: 66,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
