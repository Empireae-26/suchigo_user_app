import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _displayNameKey = 'auth_display_name';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<void> saveDisplayName(String displayName) async {
    await _storage.write(key: _displayNameKey, value: displayName);
  }

  static Future<String?> getDisplayName() async {
    return await _storage.read(key: _displayNameKey);
  }

  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _storage.write(key: 'auth_phone', value: phoneNumber);
  }

  static Future<String?> getPhoneNumber() async {
    return await _storage.read(key: 'auth_phone');
  }

  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'auth_email', value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: 'auth_email');
  }

  static Future<void> saveRefills(String refillsJson) async {
    await _storage.write(key: 'wallet_refills', value: refillsJson);
  }

  static Future<String?> getRefills() async {
    return await _storage.read(key: 'wallet_refills');
  }

  static const _regStateKey = 'reg_state';
  static const _regDistrictKey = 'reg_district';
  static const _regLocalBodyKey = 'reg_local_body';
  static const _regWardKey = 'reg_ward';

  static Future<void> saveRegisteredState(String state) async {
    await _storage.write(key: _regStateKey, value: state);
  }

  static Future<String?> getRegisteredState() async {
    return await _storage.read(key: _regStateKey);
  }

  static Future<void> saveRegisteredDistrict(String district) async {
    await _storage.write(key: _regDistrictKey, value: district);
  }

  static Future<String?> getRegisteredDistrict() async {
    return await _storage.read(key: _regDistrictKey);
  }

  static Future<void> saveRegisteredLocalBody(String localBody) async {
    await _storage.write(key: _regLocalBodyKey, value: localBody);
  }

  static Future<String?> getRegisteredLocalBody() async {
    return await _storage.read(key: _regLocalBodyKey);
  }

  static Future<void> saveRegisteredWard(String ward) async {
    await _storage.write(key: _regWardKey, value: ward);
  }

  static Future<String?> getRegisteredWard() async {
    return await _storage.read(key: _regWardKey);
  }

  static const _bookingAddressKey = 'booking_address';
  static const _bookingCityKey = 'booking_city';
  static const _bookingPincodeKey = 'booking_pincode';

  static Future<void> saveBookingAddress(String address) async {
    await _storage.write(key: _bookingAddressKey, value: address);
  }

  static Future<String?> getBookingAddress() async {
    return await _storage.read(key: _bookingAddressKey);
  }

  static Future<void> saveBookingCity(String city) async {
    await _storage.write(key: _bookingCityKey, value: city);
  }

  static Future<String?> getBookingCity() async {
    return await _storage.read(key: _bookingCityKey);
  }

  static Future<void> saveBookingPincode(String pincode) async {
    await _storage.write(key: _bookingPincodeKey, value: pincode);
  }

  static Future<String?> getBookingPincode() async {
    return await _storage.read(key: _bookingPincodeKey);
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _displayNameKey);
    await _storage.delete(key: 'auth_phone');
    await _storage.delete(key: 'auth_email');
    await _storage.delete(key: 'wallet_refills');
  }
}
