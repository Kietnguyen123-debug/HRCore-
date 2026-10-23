import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_colors.dart';
import '../../utils/email_utils.dart';
import '../widgets/otp_input_widget.dart';

enum VerificationStep {
  requestOtp,
  enterOtp,
  success,
  error,
}

class EmailVerificationSheet extends StatefulWidget {
  final String email;

  const EmailVerificationSheet({
    super.key,
    required this.email,
  });

  static Future<void> show(BuildContext context, {required String email}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EmailVerificationSheet(email: email),
      ),
    );
  }

  @override
  State<EmailVerificationSheet> createState() => _EmailVerificationSheetState();
}

class _EmailVerificationSheetState extends State<EmailVerificationSheet> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<OtpInputWidgetState> _otpKey = GlobalKey<OtpInputWidgetState>();

  late String _currentEmail;
  VerificationStep _currentStep = VerificationStep.requestOtp;
  
  bool _isLoading = false;
  String? _errorMessage;
  String _otpCode = "";

  // Countdown timer for resend
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email.trim();
    // Auto trigger request OTP if email is non-empty
    if (_currentEmail.isNotEmpty) {
      _sendOtpRequest();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
      }
    });
  }

  Future<void> _sendOtpRequest() async {
    if (_currentEmail.isEmpty || !EmailUtils.isValidEmail(_currentEmail)) {
      setState(() {
        _errorMessage = "Vui lòng nhập địa chỉ email hợp lệ";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await authController.requestEmailVerify(_currentEmail);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _currentStep = VerificationStep.enterOtp;
      });
      _startTimer();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Không thể gửi mã OTP. Vui lòng thử lại sau.";
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() {
        _errorMessage = "Vui lòng nhập đủ 6 chữ số mã OTP";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await authController.verifyEmailOtp(_otpCode);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _currentStep = VerificationStep.success;
      });
    } else {
      setState(() {
        _isLoading = false;
        _currentStep = VerificationStep.error;
        _errorMessage = "Mã OTP không chính xác hoặc đã hết hạn";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Body step content
        switch (_currentStep) {
          VerificationStep.requestOtp => _buildRequestOtpView(),
          VerificationStep.enterOtp => _buildEnterOtpView(),
          VerificationStep.success => _buildSuccessView(),
          VerificationStep.error => _buildErrorView(),
        },
      ],
    );
  }

  Widget _buildRequestOtpView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.mail, size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          "Xác thực địa chỉ Email",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Mã OTP kích hoạt sẽ được gửi tới email:",
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          EmailUtils.maskEmail(_currentEmail),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOtpRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text("Gửi mã kích hoạt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildEnterOtpView() {
    final maskedEmail = EmailUtils.maskEmail(_currentEmail);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.shieldAlert, size: 36, color: Colors.orange),
        ),
        const SizedBox(height: 16),
        const Text(
          "Nhập mã OTP xác minh",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
            children: [
              const TextSpan(text: "Vui lòng nhập 6 chữ số OTP đã được gửi tới "),
              TextSpan(
                text: maskedEmail,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // OTP Input Widget
        OtpInputWidget(
          key: _otpKey,
          length: 6,
          enabled: !_isLoading,
          isError: _errorMessage != null,
          onChanged: (code) {
            setState(() {
              _otpCode = code;
              _errorMessage = null;
            });
          },
          onCompleted: (code) {
            _otpCode = code;
            _verifyOtp();
          },
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.circleAlert, size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
        ],

        const SizedBox(height: 20),

        // Resend Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _canResend ? "Chưa nhận được mã?" : "Gửi lại mã sau:",
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(width: 6),
            if (!_canResend)
              Text(
                "${_secondsRemaining}s",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
              )
            else
              TextButton(
                onPressed: _isLoading ? null : () {
                  _otpKey.currentState?.clear();
                  _sendOtpRequest();
                },
                child: const Text(
                  "Gửi lại mã",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_isLoading || _otpCode.length < 6) ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.circleCheck, size: 54, color: Colors.green),
        ),
        const SizedBox(height: 20),
        const Text(
          "Xác thực Email thành công!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Text(
          "Địa chỉ email ${EmailUtils.maskEmail(_currentEmail)} đã được xác minh chính thức trên hệ thống.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Tiếp tục", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.circleX, size: 54, color: Colors.red),
        ),
        const SizedBox(height: 20),
        const Text(
          "Xác thực thất bại",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? "Mã OTP nhập vào không chính xác hoặc đã hết hạn. Vui lòng kiểm tra và thử lại.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = VerificationStep.enterOtp;
                    _errorMessage = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Thử lại"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _otpKey.currentState?.clear();
                  _sendOtpRequest();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Gửi mã mới"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
