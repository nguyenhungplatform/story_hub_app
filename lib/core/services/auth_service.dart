import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../data/providers/auth_provider.dart';
import '../network/api_provider.dart';
import '../network/api_response.dart';
import '../storage/storage_service.dart';

/// Giữ phiên đăng nhập: token + thông tin user, đồng bộ với [ApiProvider] và bộ nhớ cục bộ.
class AuthService extends GetxService {
  AuthService(this._api, this._storage, this._provider);

  final ApiProvider _api;
  final StorageService _storage;
  final AuthProvider _provider;

  final user = Rxn<UserModel>();

  bool get isLoggedIn => user.value != null;

  AuthService init() {
    final token = _storage.read<String>(StorageKeys.token);
    final cached = _storage.readJson(StorageKeys.user);
    if (token != null && cached is Map<String, dynamic>) {
      _api.token = token;
      user.value = UserModel.fromJson(cached);
      refreshProfile();
    }
    _api.onUnauthorized = _clearSession;
    return this;
  }

  Future<void> login(String email, String password) async {
    final (token, basic) = await _provider.login(email, password);
    _api.token = token;
    await _storage.write(StorageKeys.token, token);
    await _saveUser(basic);
    await refreshProfile();
  }

  Future<void> refreshProfile() async {
    try {
      await _saveUser(await _provider.me());
    } on ApiException catch (_) {
      // 401 đã được xử lý qua onUnauthorized; lỗi mạng thì giữ dữ liệu cũ.
    }
  }

  Future<void> updateProfile({String? name}) async => _saveUser(await _provider.updateMe(name: name));

  Future<void> logout() async {
    try {
      await _provider.logout();
    } on ApiException catch (_) {}
    await _clearSession();
  }

  Future<void> _saveUser(UserModel value) async {
    user.value = value;
    await _storage.write(StorageKeys.user, value.toJson());
  }

  Future<void> _clearSession() async {
    _api.token = null;
    user.value = null;
    await _storage.remove(StorageKeys.token);
    await _storage.remove(StorageKeys.user);
  }
}
