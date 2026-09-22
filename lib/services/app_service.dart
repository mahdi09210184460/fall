import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/horoscope_history.dart';

class AppService {
  static const String _subscriptionProductId = "fallmanora1405";

  static const String _isSubscribedKey = 'is_subscribed';
  static const String _expiryKey = 'subscription_expiry';
  static const String _usedFreeIdsKey = 'used_free_ids';
  static const String _historyKey = 'horoscope_history';
  static const String _deviceIdKey = 'device_id';
  static const String _securitySignatureKey = 'security_signature';

  static Future<String?> _getDeviceId() async {
    if (kIsWeb) return null;
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
    } catch (e) {
      debugPrint("Error getting device ID: $e");
    }
    return null;
  }

  static String _generateSignature(String deviceId, bool isSubscribed) {
    final String data = "$deviceId:$isSubscribed:fallmanora_secret_salt";
    return sha256.convert(utf8.encode(data)).toString();
  }

  static Future<bool> isSubscribed() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Validate device and signature
    final String? currentDeviceId = await _getDeviceId();
    final String storedDeviceId = prefs.getString(_deviceIdKey) ?? '';
    final bool locallySubscribed = prefs.getBool(_isSubscribedKey) ?? false;
    final String storedSignature = prefs.getString(_securitySignatureKey) ?? '';

    if (locallySubscribed) {
      if (currentDeviceId != null && storedDeviceId.isNotEmpty && currentDeviceId != storedDeviceId) {
        debugPrint("Security Alert: Device ID mismatch. Invalidating subscription.");
        await _invalidateSubscription();
        return false;
      }

      final expectedSignature = _generateSignature(storedDeviceId, true);
      if (storedSignature != expectedSignature) {
        debugPrint("Security Alert: Signature mismatch. Invalidating subscription.");
        await _invalidateSubscription();
        return false;
      }
    }

    final int expiry = prefs.getInt(_expiryKey) ?? 0;
    final bool isExpired = DateTime.now().millisecondsSinceEpoch >= expiry;

    return locallySubscribed && !isExpired;
  }

  static Future<void> subscribeLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String? deviceId = await _getDeviceId();
    
    await prefs.setBool(_isSubscribedKey, true);
    final int expiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    await prefs.setInt(_expiryKey, expiry);
    
    if (deviceId != null) {
      await prefs.setString(_deviceIdKey, deviceId);
      final signature = _generateSignature(deviceId, true);
      await prefs.setString(_securitySignatureKey, signature);
    }
  }

  static Future<void> _invalidateSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSubscribedKey, false);
    await prefs.setInt(_expiryKey, 0);
    await prefs.remove(_securitySignatureKey);
  }

  static Future<bool> canUseHoroscope(String horoscopeId) async {
    if (await isSubscribed()) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final List<String> usedIds = prefs.getStringList(_usedFreeIdsKey) ?? [];
    return !usedIds.contains(horoscopeId);
  }

  static Future<void> markAsUsed(String horoscopeId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usedIds = prefs.getStringList(_usedFreeIdsKey) ?? [];
    if (!usedIds.contains(horoscopeId)) {
      usedIds.add(horoscopeId);
      await prefs.setStringList(_usedFreeIdsKey, usedIds);
    }
  }

  static Future<void> addToHistory(HoroscopeHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    historyJson.insert(0, jsonEncode(entry.toJson()));
    if (historyJson.length > 50) historyJson.removeLast();
    await prefs.setStringList(_historyKey, historyJson);
  }

  static Future<List<HoroscopeHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    return historyJson.map((e) => HoroscopeHistoryEntry.fromJson(jsonDecode(e))).toList();
  }

  static Future<String> getSubscriptionRemainingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final int expiry = prefs.getInt(_expiryKey) ?? 0;
    if (expiry == 0) return 'غیرفعال';
    
    final int remaining = expiry - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) return 'منقضی شده';
    
    final int days = (remaining / (1000 * 60 * 60 * 24)).ceil();
    return '$days روز باقی‌مانده';
  }
}
