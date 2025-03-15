import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../services/export_service.dart';
import '../services/google_sheets_service.dart'; // Ensure this path is correct

class ViewDataScreen extends StatefulWidget {
  const ViewDataScreen({super.key});

  @override
  _ViewDataScreenState createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  List<Map<String, String>> studentData = [];
  List<Map<String, String>> filteredData = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now(); // Default to today

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  /// **Fetch Student Data from Google Sheets**
  Future<void> _fetchStudentData() async {
    setState(() => isLoading = true);
    var data = await GoogleSheetsService.fetchStudentData();
    setState(() {
      studentData = data;
      _filterDataByDate();
      isLoading = false;
    });
  }

  /// **Filter data based on selected date**
  void _filterDataByDate() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    setState(() {
      filteredData = studentData.where((student) => student['date'] == formattedDate).toList();
    });
  }

  /// **Pick a date**
Future<void> _pickDate() async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2025), // Allows selection of past dates from the year 2000
    lastDate: DateTime(2100), // Allows selection of future dates up to the year 2100
  );
  if (pickedDate != null && pickedDate != selectedDate) {
    setState(() {
      selectedDate = pickedDate;
      _filterDataByDate();
    });
  }
}

  void _exportToPDF() async {
    if (filteredData.isNotEmpty) {
      await ExportService.exportToPDF(filteredData, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No data available to export")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
 children: [
  Text(
    "Student Data",
    style: TextStyle(
      fontSize: 22, 
      fontWeight: FontWeight.bold,
      //decoration: TextDecoration.underline,
    ),
  ),
  SizedBox(height: 5), // Adds spacing
  Text(
    "Total Entries: ${filteredData.length}",
    style: TextStyle(
      fontSize: 16,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
      color: Colors.grey[700],
    ),
  ),
],

        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
        elevation: 4,
        shadowColor: Colors.white24,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchStudentData,
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: "Export to PDF",
            onPressed: _exportToPDF,
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[800],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredData.isEmpty
                    ? Center(
                        child: Text(
                          "No Data Available",
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            var student = filteredData[index];
                            return Card(
                              color: Colors.blueGrey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: ListTile(
                                title: Text(
                                  student['name']!,
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  "Session : ${student['session']}\nSystem : ${student['system']}\nIn-Time : ${student['in_time']}\nOut-Time : ${student['out_time']}",
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}