import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:simda_mobile/const.dart';
import 'package:simda_mobile/models/inventarisSearch.dart';

class ApiService {
  // Ganti BASE_URL sesuai API Laravel Anda
  static Map<String, String> jsonHeader(String token) => {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer \$token',
      };

  // Register
  static Future<http.Response> register(Map<String, String> body) async {
    final uri = Uri.parse('$BASE_URL/api/register');
    return await http.post(uri, body: body);
  }

  // Login
  static Future<http.Response> login(String username, String password) async {
    final uri = Uri.parse('$BASE_URL/api/login');

    final resp = await http.post(uri, body: {
      'username': username,
      'password': password,
    });

    return resp;
  }

  static Future<Map<String, dynamic>> getTotal(String token) async {
    final res = await http.get(
      Uri.parse('$BASE_URL/api/get_total'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final json = jsonDecode(res.body);

    if (res.statusCode == 200 && json['status'] == true) {
      return json['data'];
    }

    throw Exception('Gagal mengambil data dashboard: ${res.body}');
  }

  static Future<List<InventarisSearch>> searchInventaris(
    String keyword,
  ) async {
    final res = await http.get(
      Uri.parse('$BASE_URL/api/inventarisasi/search?keyword=$keyword'),
      headers: {
        'Accept': 'application/json',
        // 'Authorization': 'Bearer TOKEN', // nanti gampang nambah
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data');
    }

    final json = jsonDecode(res.body);

    return List<InventarisSearch>.from(
      json['data'].map((e) => InventarisSearch.fromJson(e)),
    );
  }

  // Get inventaris list
  static Future<http.Response> getInventaris(String token) async {
    final uri = Uri.parse('$BASE_URL/api/get_inventarisasi');
    return await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    });
  }

  static Future<dynamic> getKartuRuang(String token) async {
    final url = Uri.parse('$BASE_URL/api/get_kartu_ruang');

    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return resp.statusCode == 200
        ? jsonDecode(resp.body)
        : {'status': false, 'data': []};
  }

  // Upload inventaris with image and kartu_ruang_id
  static Future<http.StreamedResponse> uploadInventaris({
    required String token,
    required Map<String, String> fields,
    required List<File> images,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/inventarisasi');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(jsonHeader(token));
    request.fields.addAll(fields);

    for (final image in images) {
      final multipartFile = await http.MultipartFile.fromPath(
        'gambar[]', // 🔥 PENTING
        image.path,
      );
      request.files.add(multipartFile);
    }

    return await request.send();
  }

  // Get detail inventaris by id
  static Future<http.Response> getInventarisDetail({
    required String token,
    required int id,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/inventarisasi/$id');

    print('=== GET INVENTARIS DETAIL ===');
    print('URL : $uri');

    return await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // Update inventaris (PUT/PATCH) (example using multipart)
  static Future<http.StreamedResponse> updateInventaris({
    required String token,
    required int id,
    required Map<String, String> fields,
    required List<File> images,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/inventarisasi/$id');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(jsonHeader(token));
    request.fields['_method'] = 'PUT';
    request.fields.addAll(fields);

    for (final image in images) {
      final file = await http.MultipartFile.fromPath(
        'gambar[]', // 🔥 HARUS array
        image.path,
      );
      request.files.add(file);
    }

    return await request.send();
  }
}
