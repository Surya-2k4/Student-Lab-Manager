import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class ExportService {
  static Future<void> exportToCSV(
      List<Map<String, String>> data, BuildContext context) async {
    List<List<String>> csvData = [
      [
        "ID",
        "Name",
        "System",
        "Session",
        "Date",
        "In-Time",
        "Out-Time"
      ], // CSV Headers
      ...data.map((student) => [
            student["id"]!,
            student["name"]!,
            student["system"]!,
            student["session"]!,
            student["date"]!,
            student["in_time"]!,
            student["out_time"]!
          ]),
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      directory = Directory('/storage/emulated/0/Download');
    }
    String filePath = "${directory.path}/StudentData.csv";

    File file = File(filePath);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("CSV Exported: $filePath")));
  }

  static Future<void> exportToPDF(
      List<Map<String, String>> data, BuildContext context) async {
    try {
      // Request storage permissions
      if (await Permission.storage.request().isGranted) {
        final pdf = pw.Document();

        // Load a font that supports Unicode
        final font = pw.Font.ttf(
            await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

        // Define column headers
        final headers = [
          "ID",
          "Name",
          "System",
          "Session",
          "Date",
          "In-Time",
          "Out-Time"
        ];

        // Extract table data dynamically
        final tableData = data
            .map((student) => [
                  student["id"] ?? "",
                  student["name"] ?? "",
                  student["system"] ?? "",
                  student["session"] ?? "",
                  student["date"] ?? "",
                  student["in_time"] ?? "",
                  student["out_time"] ?? ""
                ])
            .toList();

        // Create PDF content
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Student Lab Records",
                      style: pw.TextStyle(font: font, fontSize: 20)),
                  pw.SizedBox(height: 10),
                  pw.Table.fromTextArray(
                    headers: headers,
                    data: tableData,
                    border: pw.TableBorder.all(),
                    cellAlignment: pw.Alignment.centerLeft,
                    headerStyle: pw.TextStyle(font: font, fontSize: 12),
                    cellStyle: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              );
            },
          ),
        );

        // Save file to **Downloads Directory** (Android)
        Directory? directory = await getExternalStorageDirectory();
        if (directory == null) {
          directory = Directory('/storage/emulated/0/Download');
        }
        String filePath = "${directory.path}/StudentData.pdf";
        File file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "✅ PDF Exported Successfully: StudentData.pdf (Downloads Folder)")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Storage permission denied")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ PDF Export Failed: $e")),
      );
    }
  }
}
