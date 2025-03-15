import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/sheets/v4.dart';

class GoogleSheetsService {
  static const String _spreadsheetId =
      "1sBzGtD3UHJbfPOtgl3eL02wFXSHLNEDjjH4YiwSCXwg"; // Replace with your Google Sheet ID
  static const String _sheetName =
      "Students"; // Ensure this matches your sheet name

  /// **Get Authenticated HTTP Client**
  static Future<auth.AuthClient> getHttpClient() async {
    try {
      final credentialsJson =
          await rootBundle.loadString("assets/credentials.json");
      final credentials = json.decode(credentialsJson);

      final accountCredentials =
          auth.ServiceAccountCredentials.fromJson(credentials);

      final client = await auth.clientViaServiceAccount(
          accountCredentials, [SheetsApi.spreadsheetsScope]);

      return client;
    } catch (e) {
      print("Error in authentication: $e");
      throw Exception("Failed to authenticate with Google Sheets API.");
    }
  }

  /// **Fetch All Student Data**
  static Future<List<Map<String, String>>> fetchStudentData() async {
    try {
      final client = await getHttpClient();
      final sheetsApi = SheetsApi(client);

      final response = await sheetsApi.spreadsheets.values
          .get(_spreadsheetId, "$_sheetName!A2:G");

      if (response.values == null) return [];

      return response.values!.map((row) {
        return {
          "id": row[0].toString(),
          "name": row[1].toString(),
          "system": row[2].toString(),
          "session": row[3].toString(),
          "date": row[4].toString(),
          "in_time": row[5].toString(),
          "out_time": row[6].toString(),
        };
      }).toList();
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  /// **Add a New Student Record**
  static Future<void> addStudent(
      String name, String system, String sessionName, String date, String inTime, String outTime) async {
    try {
      final client = await getHttpClient();
      final sheetsApi = SheetsApi(client);

      final values = [
        [
           (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString(),// Auto-generated ID
          name,
          system,
          sessionName,
          date,
          inTime,
          outTime
        ]
      ];

      await sheetsApi.spreadsheets.values.append(
        ValueRange(values: values),
        _spreadsheetId,
        "$_sheetName!A:G",
        valueInputOption: "USER_ENTERED",
      );
      print("Student added successfully!");
    } catch (e) {
      print("Error adding student: $e");
    }
  }
}
