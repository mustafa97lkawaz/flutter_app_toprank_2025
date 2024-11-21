import 'package:flutter/material.dart';


class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 100,
                ),
                SizedBox(height: 24),
                Text(
                  "إنشاء حساب جديد",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                _buildTextField(
                  hintText: "الاسم الكامل",
                  icon: Icons.person,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  hintText: "البريد الإلكتروني",
                  icon: Icons.email,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  hintText: "كلمة المرور",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Handle Sign Up Logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 71, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "إنشاء حساب",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "لديك حساب؟ تسجيل الدخول",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 14,
                      color: Color(0xFFB98068),
                    //  decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(255, 236, 236, 236),
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 71, 0, 0)),
        hintText: hintText,
        hintStyle: TextStyle(fontFamily: "Cairo"),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
