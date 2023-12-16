import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> sendDataToBackend(Map<String, dynamic> data) async {
  const String backendUrl = '';
  final response = await http.post(
    Uri.parse(backendUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );
  return response;
}
