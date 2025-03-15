import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Corrected import path

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit Application"),
            content: Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Exit")),
            ],
          ),
        );
        return exit ?? false;
      },
      child: MaterialApp(
        title: "Lab Management",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: SplashScreen(),
      ),
    );
  }
}
