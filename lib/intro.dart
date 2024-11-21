import 'package:cafe_management_app/Main%20Dashboard%20Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CoffeeHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, const Color.fromARGB(255, 0, 0, 0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Coffee cup image
          Center(
            child: Image.asset('images/111.jpg',fit: BoxFit.cover,),
          ),
          Container( decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(0, 0, 0, 0),Color.fromARGB(30, 0, 0, 0), Color.fromARGB(255, 79, 1, 1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Positioned(
              bottom: 0,
              left: 30,
              right: 30,
              child: Column(mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'حساباتك في جيبك',
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'نظام حساب الدين الخاص ببيع الشاي والقهوة',
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainDashboard(),
                        ),
                      );
                    },
                    child: Container(width: 200,
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'ابدأ',
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 16,
                            color: Color.fromARGB(255, 114, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ),
          ),
          // Floating coffee beans
 Positioned(top: 5, child: Container(width: 300, child: Image.asset("images/logo2.png"))),
          // Text and button
        ],
      ),
    );
  }
}
