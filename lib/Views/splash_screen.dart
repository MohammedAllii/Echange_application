import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_simple_page/Views/HomeScreen.dart';
import 'package:flutter_simple_page/Views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/size_config.dart';

class PageSplashScreen extends StatefulWidget {
  const PageSplashScreen({Key? key}) : super(key: key);

  @override
  State<PageSplashScreen> createState() => _PageSplashScreenState();
}

class _PageSplashScreenState extends State<PageSplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut // Use a different curve if needed
    );

    _animationController!.addListener(() {
      setState(() {
        // Empty setState to rebuild the widget when animation updates
      });

      if (_animationController!.isCompleted) {
        // Navigate directly to the HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PageLogin()),
        );
      }
    });

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/splash.png',
                  width: _animation!.value * 275,
                  height: _animation!.value * 275,
                ),
                const Text(
                  "HAYA NBADLOU",
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
