import 'dart:convert';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/horoscope_history.dart';

class AppService {
  static const String _rsaPublicKey = "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDLXe2/IeDhRC7tGQV6C43ElN5LkTdzPPB121HeLqScs+mn4cuM3F9/ZSmZE+FqIc3k261vLrylezWdZRnBaVQtNYOaWLwNv3L3BOT8vz4H0OfjQerpOE9ba28U81rQsUr5KiFdKavOznjoqt/jzNNB+Jvkgx0/CT6rMNslLjKpaLZD7Ym/wnAaiv7DXioZIYwV7YkkI+Lwb49fiHBs+8bPHinFTzkV6lFEzyGnh+MCAwEAAQ==";
  static const String _subscriptionProductId = "fallmanora1405";

  static const String _isSubscribedKey = 'is_subscribed';
  static const String _expiryKey = 'subscription_expiry';
  static const String _usedFreeIdsKey = 'used_free_ids';
  static const String _historyKey = 'horoscope_history';

  static bool _isPoolakeyInitialized = false;

  static Future<void> initPoolakey() async {
    if (_isPoolakeyInitialized) return;
    try {
      bool connected = await FlutterPoolakey.connect(
        _rsaPublicKey,
        onDisconnected: () {
          _isPoolakeyInitialized = false;
        },
      );
      if (connected) {
        _isPoolakeyInitialized = true;
      } else {
        throw Exception("اتصال به بازار برقرار نشد. لطفا اپلیکیشن بازار را چک کنید.");
      }
    } catch (e) {
      _isPoolakeyInitialized = false;
      rethrow; // Rethrow to catch it in the UI
    }
  }

  static Future<bool> isSubscribed() async {
    // 1. Check local cache first
    final prefs = await SharedPreferences.getInstance();
    final bool locallySubscribed = prefs.getBool(_isSubscribedKey) ?? false;
    final int expiry = prefs.getInt(_expiryKey) ?? 0;
    
    if (locallySubscribed && DateTime.now().millisecondsSinceEpoch < expiry) {
      return true;
    }

    // 2. Check with Bazaar if possible
    try {
      await initPoolakey();
      final List<PurchaseInfo> purchases = await FlutterPoolakey.getAllSubscribedProducts();
      final bool hasActiveSub = purchases.any((p) => p.productId == _subscriptionProductId);
      
      if (hasActiveSub) {
        await subscribeLocally();
        return true;
      }
    } catch (e) {
      // If error (like no internet or no Bazaar), rely on local cache
    }

    return false;
  }

  static Future<void> subscribeLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSubscribedKey, true);
    final int expiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    await prefs.setInt(_expiryKey, expiry);
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
