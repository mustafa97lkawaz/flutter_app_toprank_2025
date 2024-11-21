import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class ContactUsScreen extends StatelessWidget {
  // Function to launch a URL
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text(' اتصل بنا', style: TextStyle(color: Color.fromARGB(255, 71, 0, 0),fontFamily: "Cairo")),foregroundColor: Color.fromARGB(255, 71, 0, 0),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'images/logo.png', // Make sure to place logo.png in the 'assets' folder
              height: 100.0,
            ),
            SizedBox(height: 20.0),
            
            // Title
          
            // Phone Call Button with brown colors
            ElevatedButton.icon(
              onPressed: () => _launchURL("tel:+1234567890"), // Replace with your phone number
              icon: Icon(Icons.phone, color: Colors.white),
              label: Text("Call Us", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor:Color.fromARGB(255, 71, 0, 0), // Button color set to brown
              ),
            ),
            SizedBox(height: 10.0),

            // Website Link Button with brown colors
            ElevatedButton.icon(
              onPressed: () => _launchURL("https://www.yourwebsite.com"), // Replace with your website URL
              icon: Icon(Icons.web, color: Colors.white),
              label: Text("Visit Our Website", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 71, 0, 0), // Button color set to brown
              ),
            ),
            SizedBox(height: 20.0),

            // Social Media Icons with brown colors
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () => _launchURL("https://www.facebook.com/yourpage"), // Replace with your Facebook link
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.pink), // Instagram icon
                  onPressed: () => _launchURL("https://www.instagram.com/yourpage"), // Replace with your Instagram link
                ),
                IconButton(
                  icon: Icon(Icons.face, color: Colors.lightBlue),
                  onPressed: () => _launchURL("https://www.twitter.com/yourpage"), // Replace with your Twitter link
                ),
              ],
            ),
            Center(
        child: Container(width: 150,
          child: Lottie.asset('images/toprankfinal.json')), // Use your Lottie animation here
      ),
    
         
           Text(
  "جميع الحقوق محفوظة لشركة TopRank النظام المتكامل لإدارة المقاهي.\n"
  "تتمتع الشركة بملكية كاملة لكافة المحتويات والتقنيات المستخدمة ضمن نظامها المتخصص، والذي يهدف إلى تحسين وتطوير كفاءة إدارة المقاهي.\n"
  "يحظر نسخ أو إعادة توزيع أي جزء من هذا النظام دون إذن مسبق من الشركة.\n"
  "يلتزم النظام بأعلى معايير الجودة والأمان لضمان تجربة متميزة وموثوقة.\n"
  "نحن نسعى دائمًا لتقديم حلول مبتكرة تلبي احتياجات شركائنا في قطاع الضيافة.",
  style: TextStyle(
    color: const Color.fromARGB(255, 87, 87, 87),
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontFamily: 'Cairo', // Added for a professional Arabic font style
    height: 1.5, // Line height for better readability
  ),
  textAlign: TextAlign.end, // To justify the text for a cleaner look
),

            SizedBox(height: 10.0),

          ],
        ),
      ),
    );
  }
}
