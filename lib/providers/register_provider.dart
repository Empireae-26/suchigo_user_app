import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suchigo_app/services/secure_storage_service.dart';

class RegisterProvider with ChangeNotifier {
  // -----------------------------------------------------------
  // 1. STATE MANAGEMENT
  // -----------------------------------------------------------
  static const String _registerUrl =
      'https://suchigoapis.pythonanywhere.com//api/register/';
  static const String _otpSendUrl =
      'https://suchigoapis.pythonanywhere.com//api/otp/send/';
  static const String _otpVerifyUrl =
      'https://suchigoapis.pythonanywhere.com//api/otp/verify/';

  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _password = '';

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedLocalBody;
  String? _selectedWard;

  bool _termsAccepted = false;
  bool _isLoading = false;
  String? _errorMessage;

  // OTP-specific state (kept separate from registration state so the
  // OTP bottom sheet can show its own loading/error UI independently).
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String? _otpErrorMessage;

  // Getters
  String get username => _username;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get phone {
    String p = _phone.replaceAll(RegExp(r'\s+'), '');
    if (p.isEmpty) return p;
    if (p.startsWith('+')) return p;
    if (p.startsWith('91') && p.length == 12) return '+$p';
    return '+91$p';
  }
  String get password => _password;
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedLocalBody => _selectedLocalBody;
  String? get selectedWard => _selectedWard;
  bool get termsAccepted => _termsAccepted;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get otpErrorMessage => _otpErrorMessage;

  bool get isValid =>
      _username.isNotEmpty &&
      _firstName.isNotEmpty &&
      _lastName.isNotEmpty &&
      _phone.isNotEmpty &&
      _password.isNotEmpty &&
      _termsAccepted;

  // Setters (trims whitespace defensively)
  void setUsername(String value) {
    _username = value.trim();
    notifyListeners();
  }

  void setFirstName(String value) {
    _firstName = value.trim();
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value.trim();
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setSelectedState(String? val) {
    _selectedState = val;
    _selectedDistrict = null;
    _selectedLocalBody = null;
    _selectedWard = null;
    notifyListeners();
  }

  void setSelectedDistrict(String? val) {
    _selectedDistrict = val;
    _selectedLocalBody = null;
    _selectedWard = null;
    notifyListeners();
  }

  void setSelectedLocalBody(String? val) {
    _selectedLocalBody = val;
    _selectedWard = null;
    notifyListeners();
  }

  void setSelectedWard(String? val) {
    _selectedWard = val;
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Lets the UI surface local validation errors (e.g. "enter all 4
  /// digits") through the same inline error widget used for server errors.
  void setOtpErrorMessage(String message) {
    _otpErrorMessage = message;
    notifyListeners();
  }

  void clearOtpError() {
    if (_otpErrorMessage == null) return;
    _otpErrorMessage = null;
    notifyListeners();
  }

  // -----------------------------------------------------------
  // 2. API REGISTRATION LOGIC
  // -----------------------------------------------------------
  Future<bool> registerUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Validation check for phone format (automatic +91 format)
    final cleanPhone = phone;
    if (cleanPhone.startsWith('+91') && cleanPhone.length != 13) {
      _isLoading = false;
      _errorMessage = 'Please enter a valid 10-digit phone number.';
      notifyListeners();
      return false;
    } else if (cleanPhone.length < 10) {
      _isLoading = false;
      _errorMessage = 'Please enter a valid phone number.';
      notifyListeners();
      return false;
    }

    final requestBody = jsonEncode(<String, String>{
      'username': _username,
      'email': _email.trim().isEmpty ? '${cleanPhone.replaceAll('+', '')}@suchigo.com' : _email,
      'password': _password,
      'first_name': _firstName,
      'last_name': _lastName,
      'phone_number': cleanPhone,
    });
    print('[http] REQUEST: POST $_registerUrl');
    print(
      '[http] REQUEST Headers: {Content-Type: application/json; charset=UTF-8}',
    );
    print('[http] REQUEST Data: $requestBody');

    http.Response response;

    // --- Isolate the network call itself ---
    // Only genuine network failures (timeouts, no connection, DNS issues,
    // etc.) should land in this catch block.
    try {
      response = await http.post(
        Uri.parse(_registerUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
    } catch (e) {
      print('[http] ERROR: POST $_registerUrl -> $e');
      _isLoading = false;
      _errorMessage = 'Network error. Could not connect to the server.';
      notifyListeners();
      return false;
    }

    print('[http] RESPONSE: ${response.statusCode} POST $_registerUrl');
    print('[http] RESPONSE Data: ${response.body}');

    _isLoading = false;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // --- SUCCESSFUL REGISTRATION ---
      // Parsing the body is isolated in its own try/catch so that a
      // missing or malformed JSON body on a 2xx response can NEVER cause
      // registration to be reported as failed. The OTP sheet must show
      // whenever the server confirms success, regardless of body shape.
      try {
        if (response.body.isNotEmpty) {
          final responseBody = jsonDecode(response.body);
          print('Registration Successful: $responseBody');
        } else {
          print('Registration Successful: (empty response body)');
        }
      } catch (e) {
        print(
          'Registration succeeded but response body was not valid JSON: $e',
        );
        // Intentionally not treated as an error - the HTTP status already
        // confirms success.
      }

      // Cache the registration details locally so they can be retrieved after login
      await SecureStorageService.saveEmail(_email);
      await SecureStorageService.savePhoneNumber(phone);
      await SecureStorageService.saveUsername(_username);
      if (_firstName.isNotEmpty || _lastName.isNotEmpty) {
        await SecureStorageService.saveDisplayName(
          '$_firstName $_lastName'.trim(),
        );
      }
      if (_selectedState != null) {
        await SecureStorageService.saveRegisteredState(_selectedState!);
      }
      if (_selectedDistrict != null) {
        await SecureStorageService.saveRegisteredDistrict(_selectedDistrict!);
      }
      if (_selectedLocalBody != null) {
        await SecureStorageService.saveRegisteredLocalBody(_selectedLocalBody!);
      }
      if (_selectedWard != null) {
        await SecureStorageService.saveRegisteredWard(_selectedWard!);
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = _extractErrorMessage(
        response,
        keys: const [
          'username',
          'email',
          'phone_number',
          'password',
          'first_name',
          'last_name',
          'non_field_errors',
          'detail',
          'message',
        ],
      );
      notifyListeners();
      return false;
    }
  }

  // -----------------------------------------------------------
  // 3. OTP SEND
  // -----------------------------------------------------------
  /// Requests a fresh OTP for the phone number entered during registration.
  /// Returns true only on a 2xx response from the server.
  Future<bool> sendOtp() async {
    _isSendingOtp = true;
    _otpErrorMessage = null;
    notifyListeners();

    final requestBody = jsonEncode(<String, String>{'phone_number': phone});
    print('[http] REQUEST: POST $_otpSendUrl');
    print(
      '[http] REQUEST Headers: {Content-Type: application/json; charset=UTF-8}',
    );
    print('[http] REQUEST Data: $requestBody');

    http.Response response;
    try {
      response = await http.post(
        Uri.parse(_otpSendUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
    } catch (e) {
      print('[http] ERROR: POST $_otpSendUrl -> $e');
      _isSendingOtp = false;
      _otpErrorMessage = 'Network error. Could not send the OTP.';
      notifyListeners();
      return false;
    }

    print('[http] RESPONSE: ${response.statusCode} POST $_otpSendUrl');
    print('[http] RESPONSE Data: ${response.body}');

    _isSendingOtp = false;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      notifyListeners();
      return true;
    } else {
      _otpErrorMessage = _extractErrorMessage(
        response,
        keys: const [
          'phone_number',
          'non_field_errors',
          'detail',
          'message',
          'error',
        ],
      );
      notifyListeners();
      return false;
    }
  }

  // -----------------------------------------------------------
  // 4. OTP VERIFY
  // -----------------------------------------------------------
  /// Verifies the digit code the user entered. Returns true only on a
  /// 2xx response from the server.
  Future<bool> verifyOtp(String otp) async {
    _isVerifyingOtp = true;
    _otpErrorMessage = null;
    notifyListeners();

    final requestBody = jsonEncode(<String, String>{
      'phone_number': phone,
      'otp': otp,
    });
    print('[http] REQUEST: POST $_otpVerifyUrl');
    print(
      '[http] REQUEST Headers: {Content-Type: application/json; charset=UTF-8}',
    );
    print('[http] REQUEST Data: $requestBody');

    http.Response response;
    try {
      response = await http.post(
        Uri.parse(_otpVerifyUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
    } catch (e) {
      print('[http] ERROR: POST $_otpVerifyUrl -> $e');
      _isVerifyingOtp = false;
      _otpErrorMessage = 'Network error. Could not verify the OTP.';
      notifyListeners();
      return false;
    }

    print('[http] RESPONSE: ${response.statusCode} POST $_otpVerifyUrl');
    print('[http] RESPONSE Data: ${response.body}');

    _isVerifyingOtp = false;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // If the backend returns a session/auth token on successful
      // verification, cache it so later screens/login can reuse it.
      try {
        if (response.body.isNotEmpty) {
          final responseBody = jsonDecode(response.body);
          if (responseBody is Map) {
            final token =
                responseBody['token'] ??
                responseBody['access'] ??
                responseBody['auth_token'];
            if (token is String && token.isNotEmpty) {
              await SecureStorageService.saveToken(token);
            }
          }
        }
      } catch (e) {
        print('OTP verified but response body was not valid JSON: $e');
        // Not treated as an error - the HTTP status already confirms success.
      }

      notifyListeners();
      return true;
    } else {
      _otpErrorMessage = _extractErrorMessage(
        response,
        keys: const [
          'otp',
          'phone_number',
          'non_field_errors',
          'detail',
          'message',
          'error',
        ],
      );
      notifyListeners();
      return false;
    }
  }

  // -----------------------------------------------------------
  // 5. SHARED ERROR PARSING
  // -----------------------------------------------------------
  /// Pulls a human-readable message out of a DRF-style error response body,
  /// checking [keys] in order. Falls back to the raw body (truncated) when
  /// the response isn't valid JSON, which is common for 500 errors.
  String _extractErrorMessage(
    http.Response response, {
    required List<String> keys,
  }) {
    final rawBody = response.body;
    try {
      final errorBody = jsonDecode(rawBody);
      if (errorBody is Map) {
        for (final key in keys) {
          if (errorBody.containsKey(key)) {
            final value = errorBody[key];
            if (value is List && value.isNotEmpty) {
              return '$key: ${value.first}';
            } else if (value is String && value.isNotEmpty) {
              return '$key: $value';
            }
          }
        }
      }
      return 'Request failed (Status: ${response.statusCode}). Unrecognized JSON error format.';
    } catch (e) {
      final truncatedBody = rawBody.length > 50
          ? '${rawBody.substring(0, 50)}...'
          : rawBody;
      print('--- RAW API ERROR RESPONSE START ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: $rawBody');
      print('--- RAW API ERROR RESPONSE END ---');
      return 'API Error (Status: ${response.statusCode}). Raw response: "$truncatedBody"';
    }
  }
}
