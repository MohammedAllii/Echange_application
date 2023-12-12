import 'package:flutter/material.dart';
import 'package:flutter_simple_page/Views/splash_screen.dart';
import 'package:flutter_simple_page/Utils/size_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 42,
            vertical: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Color(0xFF757575),
            ),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Color(0xFF757575),
            ),
            gapPadding: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: Color(0xFF757575),
            ),
            gapPadding: 10,
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "Muli",
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Color(0xFF757575)),
          bodyText2: TextStyle(color: Color(0xFF757575)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PageSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
