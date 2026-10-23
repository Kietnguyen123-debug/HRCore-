import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_colors.dart';
import '../../utils/email_utils.dart';
import '../widgets/otp_input_widget.dart';

enum ChangeEmailStep {
  reauth,
  inputNewEmail,
  verifyOtp,
  completed,
}

class ChangeEmailSheet extends StatefulWidget {
  const ChangeEmailSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ChangeEmailSheet(),
      ),
    );
  }

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  final AuthController authController = Get.find<AuthController>();
  final GlobalKey<OtpInputWidgetState> _otpKey = GlobalKey<OtpInputWidgetState>();

  ChangeEmailStep _currentStep = ChangeEmailStep.reauth;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  String? _oldEmail;
  String? _stepError;
  String _otpCode = "";

  // Resend Countdown
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _oldEmail = authController.currentUser.value?.email ?? "";
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newEmailController.dispose();
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

  // STEP 1: Re-authenticate with current password
  Future<void> _handleReauth() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _stepError = "Vui lòng nhập Mật khẩu hiện tại";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _stepError = null;
    });

    final success = await authController.verifyCurrentPassword(password);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _currentStep = ChangeEmailStep.inputNewEmail;
      });
    } else {
      setState(() {
        _isLoading = false;
        _stepError = "Mật khẩu không chính xác. Vui lòng kiểm tra lại.";
      });
    }
  }

  // STEP 2: Submit New Email
  Future<void> _handleSendOtpToNewEmail() async {
    final newEmail = _newEmailController.text.trim();

    if (newEmail.isEmpty || !EmailUtils.isValidEmail(newEmail)) {
      setState(() {
        _stepError = "Vui lòng nhập định dạng Email hợp lệ";
      });
      return;
    }

    if (_oldEmail != null && _oldEmail!.isNotEmpty && newEmail.toLowerCase() == _oldEmail!.toLowerCase()) {
      setState(() {
        _stepError = "Email mới không được trùng với Email hiện tại";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _stepError = null;
    });

    final success = await authController.requestEmailVerify(newEmail);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _currentStep = ChangeEmailStep.verifyOtp;
      });
      _startTimer();
    } else {
      setState(() {
        _isLoading = false;
        _stepError = "Không thể gửi mã OTP tới $newEmail. Vui lòng kiểm tra lại email.";
      });
    }
  }

  // STEP 3: Verify OTP on New Email
  Future<void> _handleVerifyNewEmailOtp() async {
    if (_otpCode.length < 6) {
      setState(() {
        _stepError = "Vui lòng nhập đủ 6 chữ số mã OTP";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _stepError = null;
    });

    final success = await authController.verifyEmailOtp(_otpCode);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isLoading = false;
        _currentStep = ChangeEmailStep.completed;
      });
    } else {
      setState(() {
        _isLoading = false;
        _stepError = "Mã OTP không đúng hoặc đã hết hạn. Thử lại!";
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Indicator Steps
          _buildStepHeader(),

          const SizedBox(height: 20),

          // Current step content
          switch (_currentStep) {
            ChangeEmailStep.reauth => _buildReauthStep(),
            ChangeEmailStep.inputNewEmail => _buildInputNewEmailStep(),
            ChangeEmailStep.verifyOtp => _buildVerifyOtpStep(),
            ChangeEmailStep.completed => _buildCompletedStep(),
          },
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    int currentStepIndex = switch (_currentStep) {
      ChangeEmailStep.reauth => 1,
      ChangeEmailStep.inputNewEmail => 2,
      ChangeEmailStep.verifyOtp => 3,
      ChangeEmailStep.completed => 4,
    };

    return Row(
      children: List.generate(4, (index) {
        int stepNum = index + 1;
        bool isDone = stepNum < currentStepIndex;
        bool isCurrent = stepNum == currentStepIndex;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isDone || isCurrent
                        ? AppColors.primary
                        : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // STEP 1 UI: Re-authentication
  Widget _buildReauthStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.lockKeyhole, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bước 1: Xác minh danh tính",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    "Nhập mật khẩu hiện tại trước khi thay đổi email.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _passwordController,
          obscureText: _isPasswordObscured,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: "Mật khẩu hiện tại",
            prefixIcon: const Icon(LucideIcons.keyRound, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) {
            if (_stepError != null) setState(() => _stepError = null);
          },
        ),

        if (_stepError != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.circleAlert, color: Colors.red, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _stepError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleReauth,
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
                : const Text("Tiếp tục (Nhập Email mới)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // STEP 2 UI: Input New Email
  Widget _buildInputNewEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.mailPlus, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bước 2: Nhập Email mới",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    "Nhập địa chỉ email chính chủ mới để nhận OTP.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _newEmailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          decoration: InputDecoration(
            labelText: "Địa chỉ Email mới",
            hintText: "VD: name@company.com",
            prefixIcon: const Icon(LucideIcons.mail, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) {
            if (_stepError != null) setState(() => _stepError = null);
          },
        ),

        if (_stepError != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.circleAlert, color: Colors.red, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _stepError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendOtpToNewEmail,
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
                : const Text("Gửi mã OTP xác minh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // STEP 3 UI: Verify OTP on New Email
  Widget _buildVerifyOtpStep() {
    final maskedNewEmail = EmailUtils.maskEmail(_newEmailController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.shieldCheck, color: Colors.orange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bước 3: Xác thực Email mới",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    "Mã OTP đã gửi đến $maskedNewEmail",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        OtpInputWidget(
          key: _otpKey,
          length: 6,
          enabled: !_isLoading,
          isError: _stepError != null,
          onChanged: (code) {
            setState(() {
              _otpCode = code;
              _stepError = null;
            });
          },
          onCompleted: (code) {
            _otpCode = code;
            _handleVerifyNewEmailOtp();
          },
        ),

        if (_stepError != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.circleAlert, size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Text(_stepError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
        ],

        const SizedBox(height: 20),

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
                onPressed: _isLoading
                    ? null
                    : () {
                        _otpKey.currentState?.clear();
                        _handleSendOtpToNewEmail();
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
            onPressed: (_isLoading || _otpCode.length < 6) ? null : _handleVerifyNewEmailOtp,
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
                : const Text("Xác nhận đổi Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // STEP 4 UI: Completed & Security Callout
  Widget _buildCompletedStep() {
    final oldEmailMasked = EmailUtils.maskEmail(_oldEmail);

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
          "Cập nhật Email thành công!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Text(
          "Email của bạn đã được cập nhật thành ${_newEmailController.text.trim()} và được xác minh thành công.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Security Notice Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.shieldAlert, size: 22, color: Colors.blue.shade800),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ghi chú bảo mật",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Một email thông báo đã được gửi đến email cũ của bạn ($oldEmailMasked) để phòng ngừa rủi ro tài khoản bị chiếm đoạt.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              authController.refreshProfile();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Hoàn thành", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
