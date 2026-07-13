import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../provider/register_provider.dart';

import '../screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final provider = context.read<RegisterProvider>();

      _usernameController.text = provider.username;
      _firstNameController.text = provider.firstName;
      _lastNameController.text = provider.lastName;
      _emailController.text = provider.email;
      _phoneController.text = provider.phone;
      _passwordController.text = provider.password;

      _usernameController.addListener(() {
        provider.setUsername(_usernameController.text);
        provider.clearError();
      });
      _firstNameController.addListener(() {
        provider.setFirstName(_firstNameController.text);
        provider.clearError();
      });
      _lastNameController.addListener(() {
        provider.setLastName(_lastNameController.text);
        provider.clearError();
      });
      _emailController.addListener(() {
        provider.setEmail(_emailController.text);
        provider.clearError();
      });
      _phoneController.addListener(() {
        provider.setPhone(_phoneController.text);
        provider.clearError();
      });
      _passwordController.addListener(() {
        provider.setPassword(_passwordController.text);
        provider.clearError();
      });

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    const primaryGreen = Color(0xFF1E713D);
    const backgroundGreen = Color(0xFFE2F2DF);
    // Covers both the "send OTP" call (triggered by CONTINUE) and the
    // final "create account" call (triggered from inside the OTP sheet
    // after verification), so the form locks during either.
    final isSubmitting = provider.isSendingOtp || provider.isLoading;

    return Scaffold(
      backgroundColor: backgroundGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign up to get started with SuchiGo',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 28),

                  // --- INPUT FIELDS ---
                  _buildInput(
                    hint: 'Username',
                    controller: _usernameController,
                    type: TextInputType.text,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          hint: 'First Name',
                          controller: _firstNameController,
                          type: TextInputType.text,
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInput(
                          hint: 'Last Name',
                          controller: _lastNameController,
                          type: TextInputType.text,
                          icon: Icons.badge_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    hint: 'Email Address',
                    controller: _emailController,
                    type: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    hint: 'Phone (e.g., +919998887776)',
                    controller: _phoneController,
                    type: TextInputType.phone,
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    hint: 'Password',
                    controller: _passwordController,
                    type: TextInputType.text,
                    isPassword: true,
                    icon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 20),

                  Builder(
                    builder: (context) {
                      // Registration and OTP-send errors share one banner so
                      // the user always sees the most recent failure, no
                      // matter which network call produced it.
                      final banner =
                          provider.errorMessage ?? provider.otpErrorMessage;
                      if (banner == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          banner,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: provider.termsAccepted,
                          activeColor: primaryGreen,
                          onChanged: isSubmitting
                              ? null
                              : (v) => provider.setTermsAccepted(v ?? false),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: isSubmitting
                              ? null
                              : () => provider.setTermsAccepted(
                                  !provider.termsAccepted,
                                ),
                          child: Text(
                            'I have read and agree to the terms and conditions stated above',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isValid && !isSubmitting
                          ? () async {
                              // Send the OTP BEFORE creating the account.
                              // The backend's /otp/send/ endpoint rejects
                              // phone numbers that already belong to a
                              // user, so the account must not exist yet
                              // when this call is made.
                              final otpSent = await provider.sendOtp();
                              if (otpSent && mounted) {
                                _showOtpBottomSheet(context, provider.phone);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isSendingOtp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OR Separator
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Or sign up with',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/icons/fb.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.facebook,
                                  size: 24,
                                  color: Colors.blue,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 24,
                            height: 24,
                            placeholderBuilder: (context) => const Icon(
                              Icons.g_mobiledata,
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for input fields
  Widget _buildInput({
    required String hint,
    required TextEditingController controller,
    required TextInputType type,
    required IconData icon,
    bool isPassword = false,
  }) {
    const primaryGreen = Color(0xFF1E713D);

    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  void _showOtpBottomSheet(BuildContext outerContext, String phone) {
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        // Reuse the same RegisterProvider instance so the phone number and
        // OTP network state stay in sync with the registration form above.
        return ChangeNotifierProvider.value(
          value: context.read<RegisterProvider>(),
          child: _OtpVerificationSheet(
            phoneNumber: phone,
            onSuccess: () {
              Navigator.pop(sheetContext);

              ScaffoldMessenger.of(outerContext).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful! Please login.'),
                  backgroundColor: Color(0xFF1E713D),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.pushReplacement(
                outerContext,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        );
      },
    );
  }
}

// =====================================================================
// OTP VERIFICATION SHEET
// =====================================================================
// NOTE ON THE FIX:
// The previous version created 6 controllers/focus nodes but only ever
// rendered 4 OTP boxes on screen (and the copy said "4-digit code").
// Because 2 of those 6 controllers could never receive text from the UI,
// `isOtpComplete` (which checked all 6) could NEVER become true — so the
// VERIFY & SUBMIT button was permanently stuck disabled no matter what the
// user typed. Everything below is now consistently 4-digit, end-to-end:
// controllers, focus nodes, rendered boxes, completion check, and the
// backend payload length check in RegisterProvider.verifyOtp().
class _OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onSuccess;

  const _OtpVerificationSheet({
    required this.phoneNumber,
    required this.onSuccess,
  });

  @override
  State<_OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<_OtpVerificationSheet> {
  static const int _otpLength = 4;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsRemaining = 59;
  Timer? _timer;

  // Guards against double-submission if the last digit's onChanged fires
  // an auto-verify at the same moment the user also taps the button.
  bool _autoSubmitTriggered = false;

  @override
  void initState() {
    super.initState();
    // The OTP was already sent by the CONTINUE button before this sheet
    // was opened, so the countdown starts immediately on mount.
    _startTimer();
    // Give the first box focus automatically for a smoother typing flow.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  bool get _isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  Future<void> _resendOtp() async {
    final provider = context.read<RegisterProvider>();
    _autoSubmitTriggered = false;
    final success = await provider.sendOtp();
    if (!mounted) return;

    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully!'),
          backgroundColor: Color(0xFF1E713D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.otpErrorMessage ?? 'Failed to resend the OTP.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startTimer() {
    _secondsRemaining = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Runs: verify OTP -> on success, create the account -> on success,
  // hand off to onSuccess() which pops the sheet and navigates to Login.
  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text.trim()).join();
    final provider = context.read<RegisterProvider>();

    if (otp.length < _otpLength) {
      provider.setOtpErrorMessage('Please enter all $_otpLength digits.');
      return;
    }

    // Step 1: confirm the code is correct.
    final otpVerified = await provider.verifyOtp(otp);
    if (!mounted) return;
    if (!otpVerified) {
      // provider.otpErrorMessage is already populated and rendered inline.
      // Let the user retry instead of getting stuck.
      _autoSubmitTriggered = false;
      return;
    }

    // Step 2: the phone is now confirmed as belonging to this device, so
    // it's safe to actually create the account.
    final registered = await provider.registerUser();
    if (!mounted) return;

    if (registered) {
      // Account created and OTP verified -> move straight to Login.
      widget.onSuccess();
    } else {
      // On failure (e.g. email/username already taken), provider.errorMessage
      // is populated and rendered inline below the OTP boxes in build().
      _autoSubmitTriggered = false;
    }
  }

  void _clearFieldsAndError(RegisterProvider provider) {
    if (provider.otpErrorMessage != null) {
      provider.clearOtpError();
    }
    if (provider.errorMessage != null) {
      provider.clearError();
    }
  }

  void _onDigitChanged(RegisterProvider provider, int index, String val) {
    _clearFieldsAndError(provider);

    if (val.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    setState(() {});

    // Auto-verify the instant the last digit is entered and the code is
    // complete — this is what makes the flow feel "active" the moment the
    // OTP is added, on top of the VERIFY & SUBMIT button working manually.
    final provider2 = context.read<RegisterProvider>();
    final isBusy =
        provider2.isSendingOtp ||
        provider2.isVerifyingOtp ||
        provider2.isLoading;
    if (_isOtpComplete && !isBusy && !_autoSubmitTriggered) {
      _autoSubmitTriggered = true;
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E713D);
    final provider = context.watch<RegisterProvider>();
    final isOtpComplete = _isOtpComplete;
    // Busy across OTP resend, OTP verify, and the final account-creation
    // call, so the boxes/buttons lock during any in-flight request.
    final isBusy =
        provider.isSendingOtp || provider.isVerifyingOtp || provider.isLoading;
    // Show the account-creation error here too, since it can only surface
    // after a successful verification inside this sheet.
    final inlineError = provider.otpErrorMessage ?? provider.errorMessage;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.mark_email_read_outlined,
            color: primaryGreen,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Verification Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We have sent a $_otpLength-digit code to your phone number:\n${widget.phoneNumber}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // OTP box inputs — count is driven by _otpLength everywhere.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              return SizedBox(
                width: 56,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    color: isBusy ? Colors.grey.shade100 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: inlineError != null
                          ? Colors.red.shade300
                          : _focusNodes[index].hasFocus
                          ? primaryGreen
                          : Colors.grey.shade300,
                      width: _focusNodes[index].hasFocus ? 1.5 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: !isBusy,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => _onDigitChanged(provider, index, val),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          if (inlineError != null)
            Text(
              inlineError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _secondsRemaining > 0
                    ? 'Resend code in ${_secondsRemaining}s'
                    : 'Didn\'t receive the code? ',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              if (_secondsRemaining == 0)
                GestureDetector(
                  onTap: isBusy ? null : _resendOtp,
                  child: const Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (isOtpComplete && !isBusy)
                  ? () {
                      _autoSubmitTriggered = true;
                      _verifyOtp();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: (provider.isVerifyingOtp || provider.isLoading)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'VERIFY & SUBMIT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
