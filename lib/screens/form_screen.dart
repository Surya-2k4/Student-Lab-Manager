import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/google_sheets_service.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _systemController = TextEditingController();
  final TextEditingController _sessionController = TextEditingController();

  String _selectedDate = "Select Date";
  String _inTime = "Select In Time";
  String _outTime = "Select Out Time";

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
      
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isInTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        String formattedTime = DateFormat("hh:mm a")
            .format(DateTime(0, 0, 0, picked.hour, picked.minute));
        if (isInTime) {
          _inTime = formattedTime;
        } else {
          _outTime = formattedTime;
        }
      });
    }
  }

  void _submitForm() async {
    String name = _nameController.text.trim();
    String system = _systemController.text.trim();
    String session = _sessionController.text.trim();

    if (name.isEmpty ||
        system.isEmpty ||
        session.isEmpty ||
        _selectedDate == "Select Date" ||
        _inTime == "Select In Time" ||
        _outTime == "Select Out Time") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All fields are required"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await GoogleSheetsService.addStudent(
        name, system, session, _selectedDate, _inTime, _outTime);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Student data added successfully!"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _nameController.clear();
    _systemController.clear();
    _sessionController.clear();
    setState(() {
      _selectedDate = "Select Date";
      _inTime = "Select In Time";
      _outTime = "Select Out Time";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Student Record"),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.blueGrey[800],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_nameController, "Student Name", "Enter full name",
                Icons.person),
            SizedBox(height: 15),
            _buildTextField(_systemController, "System Number",
                "Enter system ID", Icons.computer),
            SizedBox(height: 15),
            _buildTextField(_sessionController, "Session Name",
                "Enter session name", Icons.meeting_room),
            SizedBox(height: 15),
            _buildDatePicker(context, "Select Date", Icons.calendar_today),
            SizedBox(height: 15),
            _buildTimePicker(context, true, "In-Time", Icons.access_time),
            SizedBox(height: 15),
            _buildTimePicker(context, false, "Out-Time", Icons.access_time),
            SizedBox(height: 30),
            Center(
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.blueGrey[900]?.withOpacity(0.85),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]?.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 10),
                Text(_selectedDate,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
      BuildContext context, bool isInTime, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _selectTime(context, isInTime),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]?.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 10),
                Text(isInTime ? _inTime : _outTime,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _submitForm,
      icon: Icon(Icons.save, size: 24, color: Colors.white),
      label: Text("Submit",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: Colors.blueGrey.shade900,
      ),
    );
  }
}
