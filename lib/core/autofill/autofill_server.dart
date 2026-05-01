import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../storage/secure_storage.dart';
import '../../features/vault/data/vault_repository.dart';
import '../network/dio_client.dart';

class AutofillServer {
  static const int port = 27653;
  static AutofillServer? _instance;
  static AutofillServer get instance => _instance ??= AutofillServer._();
  AutofillServer._();

  HttpServer? _server;
  String? _sessionToken;

  String? get sessionToken => _sessionToken;

  Future<void> start() async {
    if (_server != null) return;

    final saved = await SecureStorage.instance.getAutofillToken();
    if (saved != null && saved.isNotEmpty) {
      _sessionToken = saved;
    } else {
      final rng = Random.secure();
      _sessionToken = base64Url.encode(List<int>.generate(32, (_) => rng.nextInt(256)));
      await SecureStorage.instance.saveAutofillToken(_sessionToken!);
    }

    final router = Router()
      ..get('/status', _handleStatus)
      ..post('/autofill', _handleAutofill)
      ..options('/<ignored|.*>', _handleOptions);

    final handler = Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(_authMiddleware())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Middleware _corsMiddleware() {
    return (Handler inner) => (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders());
      }
      final response = await inner(request);
      return response.change(headers: _corsHeaders());
    };
  }

  Map<String, String> _corsHeaders() => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-DeniKey-Token',
  };

  Middleware _authMiddleware() {
    return (Handler inner) => (Request request) async {
      if (request.method == 'OPTIONS') return inner(request);
      final token = request.headers['x-denikey-token'];
      if (token != _sessionToken) {
        return Response.forbidden('{"error":"unauthorized"}',
            headers: {'Content-Type': 'application/json'});
      }
      return inner(request);
    };
  }

  Future<Response> _handleOptions(Request request) async =>
      Response.ok('', headers: _corsHeaders());

  Future<Response> _handleStatus(Request request) async {
    final token = await SecureStorage.instance.getToken();
    final masterKey = await SecureStorage.instance.getMasterKey();
    final locked = token == null || masterKey == null;
    return Response.ok(
      jsonEncode({'locked': locked}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleAutofill(Request request) async {
    final token = await SecureStorage.instance.getToken();
    final masterKey = await SecureStorage.instance.getMasterKey();
    if (token == null || masterKey == null) {
      return Response.ok(
        jsonEncode({'locked': true, 'items': []}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final body = await request.readAsString();
    final Map<String, dynamic> payload = jsonDecode(body);
    final String domain = (payload['domain'] as String? ?? '').toLowerCase();

    try {
      final dio = DioClient.instance.dio;
      final response = await dio.get('/api/v1/vault/items');
      final items = (response.data as List<dynamic>);

      final repo = VaultRepository();
      final matches = <Map<String, dynamic>>[];

      for (final raw in items) {
        final item = Map<String, dynamic>.from(raw as Map);
        final url = (item['url'] as String? ?? '').toLowerCase();
        if (url.isEmpty) continue;
        if (url.contains(domain) || domain.contains(_extractDomain(url))) {
          final decrypted = await repo.getItemDecrypted(item);
          matches.add({
            'id': item['id'],
            'title': item['title'] ?? '',
            'username': decrypted['username'] ?? item['username'] ?? '',
            'email': item['email'] ?? '',
            'password': decrypted['decrypted_password'] ?? '',
            'url': item['url'] ?? '',
          });
        }
      }

      return Response.ok(
        jsonEncode({'locked': false, 'items': matches}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (_) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'vault_error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      // www. prefix'ini kaldır
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return url;
    }
  }
}
