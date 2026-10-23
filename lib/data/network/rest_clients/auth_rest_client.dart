import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_models.dart';

part 'auth_rest_client.g.dart';

@RestApi()
abstract class AuthRestClient {
  factory AuthRestClient(Dio dio, {String baseUrl}) = _AuthRestClient;

  @POST('Auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('Auth/activate-first-time')
  Future<AuthResponse> activateFirstTime(@Body() FirstTimeActivationRequest request);

  @POST('Auth/refresh-token')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST('Auth/logout')
  Future<void> logout();

  @GET('Auth/me')
  Future<EmployeeMeResponse> getMe();

  @POST('Auth/change-password')
  Future<MessageResponse> changePassword(@Body() ChangePasswordRequest request);

  @POST('Auth/request-email-verify')
  Future<ApiMessageResponse> requestEmailVerify(@Body() RequestEmailVerificationRequest request);

  @POST('Auth/verify-email-otp')
  Future<ApiMessageResponse> verifyEmailOtp(@Body() VerifyEmailRequest request);

  @POST('Auth/request-password-reset')
  Future<ApiMessageResponse> forgotPassword(@Body() RequestPasswordResetRequest request);

  @POST('Auth/reset-password')
  Future<ApiMessageResponse> resetPassword(@Body() ResetPasswordRequest request);
}
