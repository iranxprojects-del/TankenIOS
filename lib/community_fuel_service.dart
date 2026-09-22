import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'fuel_countries.dart';

/// Crowd-sourced live pump prices for markets without free station APIs (US / IN).
class CommunityFuelService {
  static const _boxName = 'communityFuelBox';
  static const _pointsKey = 'communityPoints';
  static const _lastReportAtKey = 'lastCommunityReportAt';
  static const _collection = 'community_fuel_prices';
  static const pointsPerReport = 15;
  static const minReportInterval = Duration(minutes: 8);
  static const maxReportAge = Duration(hours: 48);

  /// Countries that accept live community reports.
  static const crowdCountries = {'us', 'ca', 'in'};

  static Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  static Future<int> getPoints() async {
    final box = await _box();
    return (box.get(_pointsKey, defaultValue: 0) as num).toInt();
  }

  static Future<void> _addPoints(int delta) async {
    final box = await _box();
    final cur = (box.get(_pointsKey, defaultValue: 0) as num).toInt();
    await box.put(_pointsKey, cur + delta);
  }

  static bool isCrowdCountry(String code) =>
      crowdCountries.contains(code.trim().toLowerCase());

  /// User GPS must fall inside the target country bbox.
  static Future<Position?> requirePositionInCountry(String countryCode) async {
    final code = countryCode.trim().toLowerCase();
    if (!isCrowdCountry(code)) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 12),
    );
    final detected = detectCountryCodeFromLatLng(pos.latitude, pos.longitude);
    if (detected != code) return null;
    return pos;
  }

  static Future<String> _deviceId() async {
    try {
      if (kIsWeb) return 'web_${DateTime.now().millisecondsSinceEpoch}';
      final info = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final a = await info.androidInfo;
        return a.id;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final i = await info.iosInfo;
        return i.identifierForVendor ?? 'ios_unknown';
      }
    } catch (_) {}
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Submit a live price. Returns points awarded, or null on failure.
  static Future<({int points, String messageKey})?> submitReport({
    required String countryCode,
    required String fuelType,
    required double price,
    required Position position,
    String? stationNote,
  }) async {
    final code = countryCode.trim().toLowerCase();
    if (!isCrowdCountry(code)) {
      return (points: 0, messageKey: 'community_err_country');
    }
    if (price <= 0 || price > 500) {
      return (points: 0, messageKey: 'community_err_price');
    }

    final detected =
        detectCountryCodeFromLatLng(position.latitude, position.longitude);
    if (detected != code) {
      return (points: 0, messageKey: 'community_err_location');
    }

    final box = await _box();
    final lastRaw = box.get(_lastReportAtKey)?.toString();
    if (lastRaw != null) {
      final last = DateTime.tryParse(lastRaw);
      if (last != null &&
          DateTime.now().difference(last) < minReportInterval) {
        return (points: 0, messageKey: 'community_err_cooldown');
      }
    }

    final deviceId = await _deviceId();
    final doc = {
      'country': code,
      'fuelType': fuelType,
      'price': double.parse(price.toStringAsFixed(2)),
      'currency': code == 'us' ? 'USD' : 'INR',
      'lat': position.latitude,
      'lng': position.longitude,
      'stationNote': (stationNote ?? '').trim(),
      'deviceId': deviceId,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await FirebaseFirestore.instance.collection(_collection).add(doc);
    } catch (e) {
      debugPrint('Community report Firestore error: $e');
      // Still keep a local copy so the reporter sees their pin.
      final local = box.get('localReports', defaultValue: <dynamic>[]) as List;
      local.insert(0, {
        ...doc,
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      });
      if (local.length > 80) local.removeRange(80, local.length);
      await box.put('localReports', local);
    }

    await box.put(_lastReportAtKey, DateTime.now().toIso8601String());
    await _addPoints(pointsPerReport);
    return (points: pointsPerReport, messageKey: 'community_ok');
  }

  /// Nearby community reports (Firestore + local fallback).
  static Future<List<Map<String, dynamic>>> fetchNearby({
    required String countryCode,
    required double lat,
    required double lng,
    required double radiusKm,
    required String fuelType,
  }) async {
    final code = countryCode.trim().toLowerCase();
    final out = <Map<String, dynamic>>[];
    final cutoff =
        DateTime.now().subtract(maxReportAge).millisecondsSinceEpoch;

    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .where('country', isEqualTo: code)
          .where('fuelType', isEqualTo: fuelType)
          .where('createdAtMs', isGreaterThan: cutoff)
          .limit(80)
          .get();
      for (final doc in snap.docs) {
        final d = doc.data();
        final sLat = (d['lat'] as num?)?.toDouble();
        final sLng = (d['lng'] as num?)?.toDouble();
        final price = (d['price'] as num?)?.toDouble();
        if (sLat == null || sLng == null || price == null) continue;
        final dist = _haversine(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        out.add({
          'id': doc.id,
          'name': (d['stationNote']?.toString().trim().isNotEmpty == true)
              ? d['stationNote'].toString()
              : 'Community report',
          'brand': '👥 Community',
          'street': '',
          'place': code.toUpperCase(),
          'houseNumber': '',
          'lat': sLat,
          'lng': sLng,
          'dist': double.parse(dist.toStringAsFixed(2)),
          'price': price,
          'isOpen': true,
          'community': true,
        });
      }
    } catch (e) {
      debugPrint('Community fetch error: $e');
    }

    // Merge local unsynced
    try {
      final box = await _box();
      final local = box.get('localReports', defaultValue: <dynamic>[]) as List;
      for (final raw in local) {
        if (raw is! Map) continue;
        if (raw['country']?.toString() != code) continue;
        if (raw['fuelType']?.toString() != fuelType) continue;
        final sLat = (raw['lat'] as num?)?.toDouble();
        final sLng = (raw['lng'] as num?)?.toDouble();
        final price = (raw['price'] as num?)?.toDouble();
        if (sLat == null || sLng == null || price == null) continue;
        final dist = _haversine(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        out.add({
          'id': raw['id']?.toString() ?? '${sLat}_$sLng',
          'name': (raw['stationNote']?.toString().trim().isNotEmpty == true)
              ? raw['stationNote'].toString()
              : 'Your report',
          'brand': '👥 You',
          'street': '',
          'place': code.toUpperCase(),
          'houseNumber': '',
          'lat': sLat,
          'lng': sLng,
          'dist': double.parse(dist.toStringAsFixed(2)),
          'price': price,
          'isOpen': true,
          'community': true,
        });
      }
    } catch (_) {}

    out.sort((a, b) =>
        ((a['price'] as num?) ?? 0).compareTo((b['price'] as num?) ?? 0));
    return out;
  }

  static double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double d) => d * math.pi / 180.0;
}
