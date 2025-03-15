import 'package:flutter/material.dart';
import 'form_screen.dart';
import 'ViewDataScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Lab Manager",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        elevation: 3,
      ),
      backgroundColor: Colors.blueGrey[800],// Light, clean background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                context,
                title: "Fill Student Entry Form",
                icon: Icons.edit_note_rounded,
                color: Colors.blueAccent,
                screen: FormScreen(),
              ),
              SizedBox(height: 20),
              _buildActionButton(
                context,
                title: "View Student Data",
                icon: Icons.table_chart_rounded,
                color: Colors.green,
                screen: ViewDataScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {required String title, required IconData icon, required Color color, required Widget screen}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
      ),
    );
  }
}
