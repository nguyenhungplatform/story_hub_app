import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, GoogleAuthProvider;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase_options.dart';

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

  Future<void> login(String email, String password) async => _startSession(await _provider.login(email, password));

  /// Đăng nhập/đăng ký bằng Google qua Firebase. Trả về `false` nếu người dùng huỷ chọn tài khoản.
  Future<bool> loginWithGoogle() async {
    await _initGoogleSignIn();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
    final credential = GoogleAuthProvider.credential(idToken: account.authentication.idToken);
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    final idToken = await result.user?.getIdToken();
    if (idToken == null) throw StateError('Không lấy được Firebase ID token');
    await _startSession(await _provider.loginWithFirebase(idToken));
    return true;
  }

  Future<void>? _googleInit;

  Future<void> _initGoogleSignIn() => _googleInit ??= GoogleSignIn.instance.initialize(
    clientId: defaultTargetPlatform == TargetPlatform.iOS ? DefaultFirebaseOptions.ios.iosClientId : null,
    serverClientId: DefaultFirebaseOptions.webClientId,
  );

  Future<void> _startSession((String, UserModel) session) async {
    final (token, basic) = session;
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
    // Đăng xuất Google để lần sau hiện lại màn chọn tài khoản.
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
      await _initGoogleSignIn();
      await GoogleSignIn.instance.signOut().catchError((_) {});
    }
    user.value = null;
    await _storage.remove(StorageKeys.token);
    await _storage.remove(StorageKeys.user);
  }
}
