import 'package:contacts_on_map/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:contacts_on_map/db.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    DB.open();
    super.initState();
  }

  @override
  void dispose() {
    DB.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts on Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
