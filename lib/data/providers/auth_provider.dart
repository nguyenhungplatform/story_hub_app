import '../../core/network/api_provider.dart';
import '../models/user_model.dart';

class AuthProvider {
  const AuthProvider(this._api);

  final ApiProvider _api;

  Future<(String, UserModel)> login(String email, String password) async {
    final res = await _api.post('/auth/login', body: {'email': email, 'password': password});
    final data = res.data as Map<String, dynamic>;
    return (data['accessToken'] as String, UserModel.fromJson(data['user'] as Map<String, dynamic>));
  }

  Future<void> register(String name, String email, String password) =>
      _api.post('/auth/register', body: {'name': name, 'email': email, 'password': password});

  Future<String?> forgotPassword(String email) async =>
      (await _api.post('/auth/forgot-password', body: {'email': email})).message;

  Future<void> logout() => _api.post('/auth/logout');

  Future<UserModel> me() async => UserModel.fromJson((await _api.get('/users/me')).data as Map<String, dynamic>);

  Future<UserModel> updateMe({String? name, String? avatar}) async {
    final res = await _api.patch('/users/me', body: {'name': ?name, 'avatar': ?avatar});
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async => (await _api.post(
    '/users/me/change-password',
    body: {'currentPassword': currentPassword, 'newPassword': newPassword},
  )).message;
}
