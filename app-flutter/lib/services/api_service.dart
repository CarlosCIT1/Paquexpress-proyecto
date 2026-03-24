import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const baseUrl = "http://127.0.0.1:8000";

class ApiService {
  // =========================
  // LOGIN
  // =========================
  static Future<Map?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        // Especificar que enviamos JSON
        headers: {"Content-Type": "application/json"},
        // Convertir el mapa a un String JSON
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["access_token"] != null) {
        return data; // {access_token, user_id}
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // =========================
  // OBTENER PAQUETES (CON JWT)
  // =========================
  static Future<List> getPaquetes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/paquetes"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
