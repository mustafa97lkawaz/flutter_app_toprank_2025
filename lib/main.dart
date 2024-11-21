import 'package:cafe_management_app/Main%20Dashboard%20Screen.dart';
import 'package:cafe_management_app/database_helper.dart';
import 'package:cafe_management_app/intro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafe_management_app/providers/example_provider.dart';
import 'package:cafe_management_app/providers/menu_provider.dart';
import 'package:cafe_management_app/providers/menu_item_provider.dart';
import 'package:cafe_management_app/providers/menu_management_provider.dart';
import 'package:cafe_management_app/providers/database_provider.dart'; // Import DatabaseProvider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExampleProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => MenuItemProvider()),
        ChangeNotifierProvider(create: (_) => MenuManagementProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider.instance), // Use DatabaseProvider.instance
        ChangeNotifierProvider(create: (_) => DatabaseHelper.instance), // Use DatabaseProvider.instance

        
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: CoffeeHomePage(),
      ),
    );
  }
}
