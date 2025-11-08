import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final class ServersListApi {
  static const String url = 'https://servers.joinmatrix.org/servers.json';

  const ServersListApi._();

  static Future<List<dynamic>> fetchServersList() async {
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.acceptHeader: 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['public_servers'].toList();
    } else {
      throw Exception('Failed to load servers list');
    }
  }
}
