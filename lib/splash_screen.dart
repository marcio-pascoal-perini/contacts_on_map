import 'dart:async';
import 'package:contacts_on_map/home_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (_progress >= 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const HomePage(),
              ),
            );
            timer.cancel();
          } else {
            _progress += 0.25;
          }
        },
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            height: 180.0,
            width: 180.0,
            child: CircularProgressIndicator(
              strokeWidth: 20,
              backgroundColor: Colors.cyanAccent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              value: _progress,
            ),
          ),
        ),
      ),
    );
  }
}
