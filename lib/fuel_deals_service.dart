import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'fuel_countries.dart';

/// Curated loyalty promo shown in «Coupons of the day».
class LoyaltyCoupon {
  final String id;
  final String network; // Payback, DeutschlandCard, Shell ClubSmart, …
  final String titleKey;
  final String detailKey;
  final String? brandHint; // Aral, Esso, Shell
  final double approxCentsPerLitre; // e.g. 2–5 ¢/L equivalent
  final List<String> countryCodes;
  final String? infoUrl;

  const LoyaltyCoupon({
    required this.id,
    required this.network,
    required this.titleKey,
    required this.detailKey,
    this.brandHint,
    required this.approxCentsPerLitre,
    required this.countryCodes,
    this.infoUrl,
  });
}

/// Pay-at-pump app with referral / first-fill bonus.
class PayAtPumpOffer {
  final String id;
  final String name;
  final String bonusKey;
  final String url;
  final List<String> countryCodes;

  const PayAtPumpOffer({
    required this.id,
    required this.name,
    required this.bonusKey,
    required this.url,
    required this.countryCodes,
  });
}

class TimeDiscountTip {
  final String messageKey;
  final Map<String, String> params;
  final bool isCheapWindowNow;
  final double estimatedSavePerLitre;
  final double estimatedSaveOnLitres;

  const TimeDiscountTip({
    required this.messageKey,
    required this.params,
    required this.isCheapWindowNow,
    required this.estimatedSavePerLitre,
    required this.estimatedSaveOnLitres,
  });
}

class CrowdDeal {
  final String id;
  final String countryCode;
  final String title;
  final String detail;
  final String? stationHint;
  final String? code;
  final DateTime expiresAt;
  final DateTime createdAt;
  final double? lat;
  final double? lng;

  const CrowdDeal({
    required this.id,
    required this.countryCode,
    required this.title,
    required this.detail,
    this.stationHint,
    this.code,
    required this.expiresAt,
    required this.createdAt,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'countryCode': countryCode,
        'title': title,
        'detail': detail,
        if (stationHint != null) 'stationHint': stationHint,
        if (code != null) 'code': code,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };

  static CrowdDeal? fromMap(Map raw) {
    final id = raw['id']?.toString();
    final title = raw['title']?.toString();
    final detail = raw['detail']?.toString() ?? '';
    final cc = raw['countryCode']?.toString() ?? 'de';
    final exp = DateTime.tryParse(raw['expiresAt']?.toString() ?? '');
    final created = DateTime.tryParse(raw['createdAt']?.toString() ?? '') ??
        DateTime.now();
    if (id == null || title == null || title.isEmpty || exp == null) return null;
    return CrowdDeal(
      id: id,
      countryCode: cc,
      title: title,
      detail: detail,
      stationHint: raw['stationHint']?.toString(),
      code: raw['code']?.toString(),
      expiresAt: exp,
      createdAt: created,
      lat: (raw['lat'] as num?)?.toDouble(),
      lng: (raw['lng'] as num?)?.toDouble(),
    );
  }
}

/// Loyalty coupons, pay-at-pump referrals, TankerKönig time tips, crowdsourced deals.
class FuelDealsService {
  static const _boxName = 'fuelDealsBox';
  static const _localDealsKey = 'localCrowdDeals';
  static const _priceSamplesKey = 'dePriceHourSamples';
  static const _collection = 'community_fuel_deals';
  static const _lastDealReportKey = 'lastCrowdDealAt';
  static const pointsPerDeal = 10;
  static const minDealInterval = Duration(minutes: 15);
  static const defaultLitres = 50.0;

  /// Typical evening vs morning gap (EUR/L) — MTS-K / market pattern for DE.
  static const eveningGapEurPerLitre = 0.12;

  static Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  static bool dealsSupported(String countryCode) {
    final c = countryCode.trim().toLowerCase();
    return c == 'de' ||
        c == 'at' ||
        c == 'us' ||
        c == 'ca' ||
        {
          'fr',
          'nl',
          'be',
          'lu',
          'uk',
          'gb',
          'ie',
          'es',
          'it',
          'pt',
          'ch',
        }.contains(c);
  }

  // ─── 1) Loyalty coupons ───────────────────────────────────────────

  static const List<LoyaltyCoupon> _loyaltyCatalog = [
    LoyaltyCoupon(
      id: 'payback_aral_multi',
      network: 'Payback',
      titleKey: 'deal_payback_title',
      detailKey: 'deal_payback_detail',
      brandHint: 'Aral',
      approxCentsPerLitre: 3,
      countryCodes: ['de'],
      infoUrl: 'https://www.payback.de/',
    ),
    LoyaltyCoupon(
      id: 'deutschlandcard_esso',
      network: 'DeutschlandCard',
      titleKey: 'deal_deutschlandcard_title',
      detailKey: 'deal_deutschlandcard_detail',
      brandHint: 'Esso',
      approxCentsPerLitre: 2.5,
      countryCodes: ['de'],
      infoUrl: 'https://www.deutschlandcard.de/',
    ),
    LoyaltyCoupon(
      id: 'shell_clubsmart_de',
      network: 'Shell ClubSmart',
      titleKey: 'deal_shell_title',
      detailKey: 'deal_shell_detail',
      brandHint: 'Shell',
      approxCentsPerLitre: 2,
      countryCodes: ['de', 'at', 'nl', 'be', 'uk', 'gb'],
      infoUrl: 'https://www.shell.de/fahrer/shell-clubsmart.html',
    ),
    LoyaltyCoupon(
      id: 'shell_fuel_rewards_us',
      network: 'Shell Fuel Rewards',
      titleKey: 'deal_shell_us_title',
      detailKey: 'deal_shell_us_detail',
      brandHint: 'Shell',
      approxCentsPerLitre: 5, // ¢/gal equivalent messaging
      countryCodes: ['us'],
      infoUrl: 'https://www.fuelrewards.com/',
    ),
    LoyaltyCoupon(
      id: 'petro_points_ca',
      network: 'Petro-Points',
      titleKey: 'deal_petro_title',
      detailKey: 'deal_petro_detail',
      brandHint: 'Petro-Canada',
      approxCentsPerLitre: 2,
      countryCodes: ['ca'],
      infoUrl: 'https://www.petro-canada.ca/en/personal/petro-points',
    ),
  ];

  static List<LoyaltyCoupon> loyaltyForCountry(String countryCode) {
    final c = countryCode.trim().toLowerCase();
    return _loyaltyCatalog
        .where((x) => x.countryCodes.contains(c))
        .toList(growable: false);
  }

  // ─── 2) Pay-at-pump referrals ──────────────────────────────────────

  static const List<PayAtPumpOffer> _payAtPumpCatalog = [
    PayAtPumpOffer(
      id: 'ryd',
      name: 'Ryd',
      bonusKey: 'deal_ryd_bonus',
      // Public app / invite landing — replace with your affiliate code when ready.
      url: 'https://www.ryd.one/',
      countryCodes: ['de', 'at'],
    ),
    PayAtPumpOffer(
      id: 'pace',
      name: 'Pace Drive',
      bonusKey: 'deal_pace_bonus',
      url: 'https://www.mypace.io/',
      countryCodes: ['de', 'at', 'nl', 'be'],
    ),
    PayAtPumpOffer(
      id: 'fillgo',
      name: 'Fill & Go',
      bonusKey: 'deal_fillgo_bonus',
      url: 'https://www.eni.com/',
      countryCodes: ['it', 'de'],
    ),
    PayAtPumpOffer(
      id: 'shell_app_us',
      name: 'Shell App',
      bonusKey: 'deal_shell_app_bonus',
      url: 'https://www.shell.us/motorist/shell-app.html',
      countryCodes: ['us'],
    ),
  ];

  static List<PayAtPumpOffer> payAtPumpForCountry(String countryCode) {
    final c = countryCode.trim().toLowerCase();
    return _payAtPumpCatalog
        .where((x) => x.countryCodes.contains(c))
        .toList(growable: false);
  }

  // ─── 3) Time-based discount (DE / TankerKönig pattern) ─────────────

  /// Record a cheapest-price sample for the current local hour (Germany).
  static Future<void> recordGermanyPriceSample(double cheapestEurPerL) async {
    if (cheapestEurPerL <= 0) return;
    final box = await _box();
    final hour = DateTime.now().hour;
    final raw = box.get(_priceSamplesKey);
    final Map<String, dynamic> map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final key = hour.toString();
    final prev = (map[key] as num?)?.toDouble();
    // Exponential smooth so one outlier does not dominate.
    map[key] = prev == null
        ? cheapestEurPerL
        : (prev * 0.7 + cheapestEurPerL * 0.3);
    await box.put(_priceSamplesKey, map);
  }

  static Future<Map<int, double>> _germanyHourAverages() async {
    final box = await _box();
    final raw = box.get(_priceSamplesKey);
    if (raw is! Map) return {};
    final out = <int, double>{};
    raw.forEach((k, v) {
      final h = int.tryParse(k.toString());
      final p = (v as num?)?.toDouble();
      if (h != null && p != null && p > 0) out[h] = p;
    });
    return out;
  }

  /// Build tip from MTS-K evening pattern + optional local TankerKönig samples.
  static Future<TimeDiscountTip?> timeTipForGermany({
    required List stations,
    double litres = defaultLitres,
  }) async {
    final prices = <double>[];
    for (final s in stations) {
      if (s is! Map) continue;
      final p = (s['price'] as num?)?.toDouble();
      if (p != null && p > 0 && p < 5) prices.add(p);
    }
    if (prices.isEmpty) return null;
    prices.sort();
    final cheapest = prices.first;
    await recordGermanyPriceSample(cheapest);

    final hour = DateTime.now().hour;
    final samples = await _germanyHourAverages();
    double morningAvg = 0;
    int morningN = 0;
    double eveningAvg = 0;
    int eveningN = 0;
    samples.forEach((h, p) {
      if (h >= 7 && h <= 10) {
        morningAvg += p;
        morningN++;
      }
      if (h >= 18 && h <= 22) {
        eveningAvg += p;
        eveningN++;
      }
    });
    if (morningN > 0) morningAvg /= morningN;
    if (eveningN > 0) eveningAvg /= eveningN;

    double gap = eveningGapEurPerLitre;
    if (morningN >= 2 && eveningN >= 2 && morningAvg > eveningAvg) {
      gap = (morningAvg - eveningAvg).clamp(0.05, 0.25);
    }

    final savePerL = gap;
    final saveTotal = gap * litres;
    final cents = (gap * 100).round();
    final euros = saveTotal.toStringAsFixed(2);

    final inCheapWindow = hour >= 18 && hour <= 22;
    final morningRush = hour >= 7 && hour <= 11;
    final afternoon = hour >= 12 && hour <= 17;

    if (inCheapWindow) {
      return TimeDiscountTip(
        messageKey: 'deal_time_now_cheap',
        params: {
          'cents': '$cents',
          'litres': litres.toStringAsFixed(0),
          'euros': euros,
        },
        isCheapWindowNow: true,
        estimatedSavePerLitre: savePerL,
        estimatedSaveOnLitres: saveTotal,
      );
    }
    if (morningRush || afternoon) {
      final hoursWait = hour < 18 ? (18 - hour) : 0;
      return TimeDiscountTip(
        messageKey: 'deal_time_wait',
        params: {
          'hours': '$hoursWait',
          'cents': '$cents',
          'litres': litres.toStringAsFixed(0),
          'euros': euros,
          'price': cheapest.toStringAsFixed(2),
        },
        isCheapWindowNow: false,
        estimatedSavePerLitre: savePerL,
        estimatedSaveOnLitres: saveTotal,
      );
    }
    // Night / early morning
    return TimeDiscountTip(
      messageKey: 'deal_time_night',
      params: {
        'cents': '$cents',
        'litres': litres.toStringAsFixed(0),
        'euros': euros,
      },
      isCheapWindowNow: false,
      estimatedSavePerLitre: savePerL,
      estimatedSaveOnLitres: saveTotal,
    );
  }

  /// Optional live check: cheapest around Berlin via TankerKönig (keeps samples fresh).
  static Future<void> refreshGermanySampleNear({
    required double lat,
    required double lng,
    required String fuelType,
  }) async {
    try {
      const apiKey = 'ece7e50d-72fe-4e51-a996-555e56ca910c';
      final type = (fuelType == 'e5' || fuelType == 'e10' || fuelType == 'diesel')
          ? fuelType
          : 'diesel';
      final url =
          'https://creativecommons.tankerkoenig.de/json/list.php?lat=$lat&lng=$lng&rad=5&sort=price&type=$type&apikey=$apiKey';
      final res = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'TankenDE/1.0'})
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return;
      final data = json.decode(res.body);
      if (data is! Map || data['ok'] != true) return;
      final list = data['stations'];
      if (list is! List || list.isEmpty) return;
      double? best;
      for (final s in list) {
        if (s is! Map) continue;
        final p = (s['price'] as num?)?.toDouble();
        if (p != null && p > 0 && (best == null || p < best)) best = p;
      }
      if (best != null) await recordGermanyPriceSample(best);
    } catch (_) {}
  }

  // ─── 4) Crowdsourced deals ────────────────────────────────────────

  static Future<List<CrowdDeal>> fetchCrowdDeals({
    required String countryCode,
    double? lat,
    double? lng,
    double radiusKm = 40,
  }) async {
    final cc = countryCode.trim().toLowerCase();
    final now = DateTime.now();
    final merged = <CrowdDeal>[];

    // Local Hive
    final box = await _box();
    final localRaw = box.get(_localDealsKey);
    if (localRaw is List) {
      for (final item in localRaw) {
        if (item is! Map) continue;
        final d = CrowdDeal.fromMap(Map<String, dynamic>.from(item));
        if (d == null) continue;
        if (d.countryCode != cc) continue;
        if (d.expiresAt.isBefore(now)) continue;
        merged.add(d);
      }
    }

    // Firestore
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .where('countryCode', isEqualTo: cc)
          .limit(40)
          .get()
          .timeout(const Duration(seconds: 8));
      for (final doc in snap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final d = CrowdDeal.fromMap(data);
        if (d == null) continue;
        if (d.expiresAt.isBefore(now)) continue;
        if (lat != null && lng != null && d.lat != null && d.lng != null) {
          final dist = Geolocator.distanceBetween(lat, lng, d.lat!, d.lng!) /
              1000.0;
          if (dist > radiusKm) continue;
        }
        merged.add(d);
      }
    } catch (e) {
      debugPrint('Crowd deals Firestore: $e');
    }

    final seen = <String>{};
    final out = <CrowdDeal>[];
    for (final d in merged) {
      if (seen.add(d.id)) out.add(d);
    }
    out.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    return out;
  }

  static Future<({int points, String messageKey})> submitCrowdDeal({
    required String countryCode,
    required String title,
    required String detail,
    String? stationHint,
    String? code,
    required DateTime expiresAt,
    double? lat,
    double? lng,
    bool premiumUnlocked = true,
  }) async {
    if (!premiumUnlocked) {
      return (points: 0, messageKey: 'deals_premium_required');
    }
    final cc = countryCode.trim().toLowerCase();
    if (!dealsSupported(cc)) {
      return (points: 0, messageKey: 'deal_err_country');
    }
    final t = title.trim();
    if (t.length < 3) {
      return (points: 0, messageKey: 'deal_err_title');
    }
    if (expiresAt.isBefore(DateTime.now())) {
      return (points: 0, messageKey: 'deal_err_expiry');
    }

    final box = await _box();
    final last = box.get(_lastDealReportKey)?.toString();
    if (last != null) {
      final prev = DateTime.tryParse(last);
      if (prev != null &&
          DateTime.now().difference(prev) < minDealInterval) {
        return (points: 0, messageKey: 'deal_err_cooldown');
      }
    }

    final id = 'deal_${DateTime.now().millisecondsSinceEpoch}';
    final deal = CrowdDeal(
      id: id,
      countryCode: cc,
      title: t,
      detail: detail.trim(),
      stationHint: stationHint?.trim(),
      code: code?.trim().isEmpty == true ? null : code?.trim(),
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
      lat: lat,
      lng: lng,
    );

    // Local first
    final localRaw = box.get(_localDealsKey);
    final list = <Map>[];
    if (localRaw is List) {
      for (final item in localRaw) {
        if (item is Map) list.add(Map<String, dynamic>.from(item));
      }
    }
    list.insert(0, deal.toMap());
    while (list.length > 40) {
      list.removeLast();
    }
    await box.put(_localDealsKey, list);
    await box.put(_lastDealReportKey, DateTime.now().toIso8601String());

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .set(deal.toMap())
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Crowd deal upload: $e');
    }

    // Reuse community points box if present
    try {
      final pointsBox = Hive.isBoxOpen('communityFuelBox')
          ? Hive.box('communityFuelBox')
          : await Hive.openBox('communityFuelBox');
      final cur = (pointsBox.get('communityPoints', defaultValue: 0) as num)
          .toInt();
      await pointsBox.put('communityPoints', cur + pointsPerDeal);
    } catch (_) {}

    return (points: pointsPerDeal, messageKey: 'deal_submit_ok');
  }
}
