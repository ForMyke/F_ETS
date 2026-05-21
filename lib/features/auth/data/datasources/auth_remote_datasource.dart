import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  // TODO: reemplazar por variables de entorno
  static const String _baseUrl = 'https://api.ets.edu.mx';

  // ─── Supabase (descomentar cuando esté configurado) ──────────────────────
  // static const String _supabaseUrl = 'https://<PROJECT>.supabase.co';
  // static const String _supabaseAnonKey = '<ANON_KEY>';
  // ─────────────────────────────────────────────────────────────────────────

  const AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 401) {
      throw const InvalidCredentialsFailure();
    } else {
      throw const ServerFailure();
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 409) {
      throw const ServerFailure('Este correo ya está registrado.');
    } else {
      throw const ServerFailure();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    // ─── Con Supabase (descomentar cuando esté configurado) ───────────────
    // final response = await client.post(
    //   Uri.parse('$_supabaseUrl/auth/v1/recover'),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'apikey': _supabaseAnonKey,
    //   },
    //   body: jsonEncode({'email': email}),
    // );
    // if (response.statusCode != 200) throw const ServerFailure();
    // ──────────────────────────────────────────────────────────────────────

    // TODO: reemplazar con la llamada real cuando tengas Supabase
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) throw const ServerFailure();
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    // ─── Con Supabase (descomentar cuando esté configurado) ───────────────
    // El cliente de Supabase maneja el token del deep link automáticamente.
    // Aquí solo necesitas llamar:
    //
    // final response = await client.put(
    //   Uri.parse('$_supabaseUrl/auth/v1/user'),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'apikey': _supabaseAnonKey,
    //     'Authorization': 'Bearer <ACCESS_TOKEN_DEL_DEEP_LINK>',
    //   },
    //   body: jsonEncode({'password': newPassword}),
    // );
    // if (response.statusCode != 200) throw const ServerFailure();
    // ──────────────────────────────────────────────────────────────────────

    // TODO: reemplazar con la llamada real cuando tengas Supabase
    final response = await client.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': newPassword}),
    );

    if (response.statusCode != 200) throw const ServerFailure();
  }
}
