import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';

/// Interactive 6-digit OTP Pin Code Input Widget.
/// Supports auto-focus, focus jumping, backspace navigation, and clipboard paste.
class OtpInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool isError;
  final bool autoFocus;

  const OtpInputWidget({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.isError = false,
    this.autoFocus = true,
  });

  @override
  State<OtpInputWidget> createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    if (widget.autoFocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get otpCode {
    return _controllers.map((c) => c.text).join();
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty && widget.enabled) {
      _focusNodes[0].requestFocus();
    }
    _triggerCallbacks();
  }

  void _triggerCallbacks() {
    final code = otpCode;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _handlePaste(String text) {
    final cleanDigits = text.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) return;

    final lengthToFill = cleanDigits.length > widget.length ? widget.length : cleanDigits.length;
    for (int i = 0; i < lengthToFill; i++) {
      _controllers[i].text = cleanDigits[i];
    }

    if (lengthToFill < widget.length) {
      _focusNodes[lengthToFill].requestFocus();
    } else {
      _focusNodes[widget.length - 1].unfocus();
    }

    setState(() {});
    _triggerCallbacks();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 46,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(), // Temporary node for backspace detection
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  _controllers[index].text.isEmpty &&
                  index > 0) {
                _focusNodes[index - 1].requestFocus();
                _controllers[index - 1].clear();
                _triggerCallbacks();
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.isError ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.isError
                        ? Colors.red
                        : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.isError ? Colors.red : AppColors.primary,
                    width: 2.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                fillColor: _controllers[index].text.isNotEmpty
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Theme.of(context).cardColor,
                filled: true,
              ),
              onChanged: (value) {
                if (value.length > 1) {
                  // User pasted into field
                  _handlePaste(value);
                  return;
                }

                if (value.isNotEmpty) {
                  if (index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  } else {
                    _focusNodes[index].unfocus();
                  }
                }

                setState(() {});
                _triggerCallbacks();
              },
            ),
          ),
        );
      }),
    );
  }
}
