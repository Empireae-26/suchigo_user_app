import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _displayNameKey = 'auth_display_name';

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing token: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading token: $e');
      try {
        await _storage.delete(key: _tokenKey);
      } catch (_) {}
      return null;
    }
  }

  static Future<void> saveUsername(String username) async {
    try {
      await _storage.write(key: _usernameKey, value: username);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing username: $e');
    }
  }

  static Future<String?> getUsername() async {
    try {
      return await _storage.read(key: _usernameKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading username: $e');
      return null;
    }
  }

  static Future<void> saveDisplayName(String displayName) async {
    try {
      await _storage.write(key: _displayNameKey, value: displayName);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing displayName: $e');
    }
  }

  static Future<String?> getDisplayName() async {
    try {
      return await _storage.read(key: _displayNameKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading displayName: $e');
      return null;
    }
  }

  static Future<void> savePhoneNumber(String phoneNumber) async {
    try {
      await _storage.write(key: 'auth_phone', value: phoneNumber);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing phoneNumber: $e');
    }
  }

  static Future<String?> getPhoneNumber() async {
    try {
      return await _storage.read(key: 'auth_phone');
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading phoneNumber: $e');
      return null;
    }
  }

  static Future<void> saveEmail(String email) async {
    try {
      await _storage.write(key: 'auth_email', value: email);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing email: $e');
    }
  }

  static Future<String?> getEmail() async {
    try {
      return await _storage.read(key: 'auth_email');
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading email: $e');
      return null;
    }
  }

  static Future<void> saveRefills(String refillsJson) async {
    try {
      await _storage.write(key: 'wallet_refills', value: refillsJson);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing refills: $e');
    }
  }

  static Future<String?> getRefills() async {
    try {
      return await _storage.read(key: 'wallet_refills');
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading refills: $e');
      return null;
    }
  }

  static const _regStateKey = 'reg_state';
  static const _regDistrictKey = 'reg_district';
  static const _regLocalBodyKey = 'reg_local_body';
  static const _regWardKey = 'reg_ward';

  static Future<void> saveRegisteredState(String state) async {
    try {
      await _storage.write(key: _regStateKey, value: state);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing regState: $e');
    }
  }

  static Future<String?> getRegisteredState() async {
    try {
      return await _storage.read(key: _regStateKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading regState: $e');
      return null;
    }
  }

  static Future<void> saveRegisteredDistrict(String district) async {
    try {
      await _storage.write(key: _regDistrictKey, value: district);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing regDistrict: $e');
    }
  }

  static Future<String?> getRegisteredDistrict() async {
    try {
      return await _storage.read(key: _regDistrictKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading regDistrict: $e');
      return null;
    }
  }

  static Future<void> saveRegisteredLocalBody(String localBody) async {
    try {
      await _storage.write(key: _regLocalBodyKey, value: localBody);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing regLocalBody: $e');
    }
  }

  static Future<String?> getRegisteredLocalBody() async {
    try {
      return await _storage.read(key: _regLocalBodyKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading regLocalBody: $e');
      return null;
    }
  }

  static Future<void> saveRegisteredWard(String ward) async {
    try {
      await _storage.write(key: _regWardKey, value: ward);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing regWard: $e');
    }
  }

  static Future<String?> getRegisteredWard() async {
    try {
      return await _storage.read(key: _regWardKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading regWard: $e');
      return null;
    }
  }

  static const _bookingAddressKey = 'booking_address';
  static const _bookingCityKey = 'booking_city';
  static const _bookingPincodeKey = 'booking_pincode';

  static Future<void> saveBookingAddress(String address) async {
    try {
      await _storage.write(key: _bookingAddressKey, value: address);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing bookingAddress: $e');
    }
  }

  static Future<String?> getBookingAddress() async {
    try {
      return await _storage.read(key: _bookingAddressKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading bookingAddress: $e');
      return null;
    }
  }

  static Future<void> saveBookingCity(String city) async {
    try {
      await _storage.write(key: _bookingCityKey, value: city);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing bookingCity: $e');
    }
  }

  static Future<String?> getBookingCity() async {
    try {
      return await _storage.read(key: _bookingCityKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading bookingCity: $e');
      return null;
    }
  }

  static Future<void> saveBookingPincode(String pincode) async {
    try {
      await _storage.write(key: _bookingPincodeKey, value: pincode);
    } catch (e) {
      debugPrint('[SecureStorageService] Error writing bookingPincode: $e');
    }
  }

  static Future<String?> getBookingPincode() async {
    try {
      return await _storage.read(key: _bookingPincodeKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error reading bookingPincode: $e');
      return null;
    }
  }

  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: _displayNameKey);
      await _storage.delete(key: 'auth_phone');
      await _storage.delete(key: 'auth_email');
      await _storage.delete(key: 'wallet_refills');
      await _storage.delete(key: _regStateKey);
      await _storage.delete(key: _regDistrictKey);
      await _storage.delete(key: _regLocalBodyKey);
      await _storage.delete(key: _regWardKey);
      await _storage.delete(key: _bookingAddressKey);
      await _storage.delete(key: _bookingCityKey);
      await _storage.delete(key: _bookingPincodeKey);
    } catch (e) {
      debugPrint('[SecureStorageService] Error clearing all keys: $e');
    }
  }
}
