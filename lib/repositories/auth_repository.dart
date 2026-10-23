import '../data/network/dio_client.dart';
import '../data/network/models/auth_models.dart';
import '../data/network/rest_clients/auth_rest_client.dart';
import '../core/storage/secure_storage.dart';

/// Repository responsible for all authentication-related operations,
/// including server-side requests and local token management.
class AuthRepository {
  final AuthRestClient _restClient;
  final BaseSecureStorage _storage;

  AuthRepository({
    AuthRestClient? restClient,
    BaseSecureStorage? storage,
  })  : _restClient = restClient ?? AuthRestClient(DioClient().dio),
        _storage = storage ?? SecureStorageImpl();

  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Performs login and persists tokens upon success.
  Future<AuthResponse> login({
    required String employeeCode,
    required String password,
    required String deviceId,
  }) async {
    final response = await _restClient.login(LoginRequest(
      employeeCode: employeeCode,
      password: password,
      deviceId: deviceId,
    ));

    if (response.success && response.token != null) {
      await _persistTokens(
        token: response.token!,
        refreshToken: response.refreshToken,
      );
    }

    return response;
  }

  /// Performs first-time activation and persists tokens upon success.
  Future<AuthResponse> activateFirstTime(FirstTimeActivationRequest request) async {
    final response = await _restClient.activateFirstTime(request);

    if (response.success && response.token != null) {
      await _persistTokens(
        token: response.token!,
        refreshToken: response.refreshToken,
      );
    }

    return response;
  }

  /// Refreshes the access token using the stored refresh token.
  Future<AuthResponse> refreshToken() async {
    final storedRefreshToken = await _storage.read(key: _refreshTokenKey);
    if (storedRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _restClient.refreshToken(RefreshTokenRequest(
      refreshToken: storedRefreshToken,
    ));

    if (response.success && response.token != null) {
      await _persistTokens(
        token: response.token!,
        refreshToken: response.refreshToken,
      );
    }

    return response;
  }

  /// Logs out the user and clears local tokens.
  Future<void> logout() async {
    try {
      await _restClient.logout();
    } catch (_) {
      // Silently ignore logout failures to ensure local cleanup still happens
    } finally {
      await _storage.deleteAll();
    }
  }

  /// Fetches the current user profile.
  Future<EmployeeMeResponse> getMe() {
    return _restClient.getMe();
  }

  /// Changes user password.
  Future<MessageResponse> changePassword(String currentPassword, String newPassword) {
    return _restClient.changePassword(ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));
  }

  /// Requests email OTP verification.
  Future<ApiMessageResponse> requestEmailVerify(String email) {
    return _restClient.requestEmailVerify(RequestEmailVerificationRequest(email: email));
  }

  /// Verifies email OTP code.
  Future<ApiMessageResponse> verifyEmailOtp(String otp) {
    return _restClient.verifyEmailOtp(VerifyEmailRequest(otp: otp));
  }

  /// Requests password reset OTP via email.
  Future<ApiMessageResponse> forgotPassword(String employeeCodeOrEmail) {
    return _restClient.forgotPassword(RequestPasswordResetRequest(employeeCodeOrEmail: employeeCodeOrEmail));
  }

  /// Resets password using email, OTP, and new password.
  Future<ApiMessageResponse> resetPassword({
    required String employeeCodeOrEmail,
    required String otp,
    required String newPassword,
  }) {
    return _restClient.resetPassword(ResetPasswordRequest(
      employeeCodeOrEmail: employeeCodeOrEmail,
      otp: otp,
      newPassword: newPassword,
    ));
  }

  /// Helper to persist access and refresh tokens.
  Future<void> _persistTokens({required String token, String? refreshToken}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Returns the current access token if present.
  Future<String?> getAccessToken() => _storage.read(key: _tokenKey);

  /// Clears all authentication state.
  Future<void> clearAuth() => _storage.deleteAll();
}
