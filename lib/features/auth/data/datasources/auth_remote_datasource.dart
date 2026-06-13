import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:etsAndroid/core/error/failures.dart';
import 'package:etsAndroid/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  const AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw const InvalidCredentialsFailure();

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        name: user.email ?? '',
        token: response.session?.accessToken ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    final response = await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (response.user == null) throw const ServerFailure();
  }
}