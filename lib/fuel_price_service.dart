import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'community_fuel_service.dart';
import 'official_fuel_prices.dart';

class FuelPriceService {
  static const String _userAgent = 'TankenDE/1.0';
  static const Duration _timeout = Duration(seconds: 18);

  static List<Map<String, dynamic>>? _esCache;
  static DateTime? _esCacheAt;
  static List<Map<String, dynamic>>? _itCache;
  static DateTime? _itCacheAt;
  static Map<String, dynamic>? _hrCache;
  static DateTime? _hrCacheAt;
  static Map<String, dynamic>? _openVanCache;
  static DateTime? _openVanCacheAt;
  static final Map<String, List<Map<String, dynamic>>> _ptCacheByFuel = {};
  static DateTime? _ptCacheAt;

  static Future<List<Map<String, dynamic>>> fetchNearby({
    required String countryCode,
    required double lat,
    required double lng,
    required double radiusKm,
    required String fuelType, // diesel|e5|e10
    String? australiaApiKey,
  }) async {
    final code = countryCode.trim().toLowerCase();
    try {
      List<Map<String, dynamic>> list;
      switch (code) {
        case 'de':
          list = await _fetchGermany(lat, lng, radiusKm, fuelType);
          break;
        case 'at':
          list = await _fetchAustria(lat, lng, radiusKm, fuelType);
          break;
        case 'fr':
          list = await _fetchFrance(lat, lng, radiusKm, fuelType);
          break;
        case 'es':
          list = await _fetchSpain(lat, lng, radiusKm, fuelType);
          break;
        case 'it':
          list = await _fetchItaly(lat, lng, radiusKm, fuelType);
          break;
        case 'uk':
        case 'gb':
          list = await _fetchUk(lat, lng, radiusKm, fuelType);
          break;
        case 'au':
          list = await _fetchAustralia(
            lat,
            lng,
            radiusKm,
            fuelType,
            australiaApiKey,
          );
          break;
        case 'pt':
          list = await _fetchPortugal(lat, lng, radiusKm, fuelType);
          break;
        case 'be':
          list = await _fetchAnwb(lat, lng, radiusKm, fuelType, 'BEL');
          break;
        case 'nl':
          list = await _fetchAnwb(lat, lng, radiusKm, fuelType, 'NLD');
          break;
        case 'lu':
          list = await _fetchAnwb(lat, lng, radiusKm, fuelType, 'LUX');
          break;
        case 'si':
          list = await _fetchSlovenia(lat, lng, radiusKm, fuelType);
          break;
        case 'hr':
          list = await _fetchCroatia(lat, lng, radiusKm, fuelType);
          break;
        case 'ie':
        case 'pl':
        case 'cz':
        case 'gr':
        case 'ch':
        case 'no':
        case 'se':
        case 'dk':
        case 'br':
          list = await _fetchNationalAverage(code, lat, lng, fuelType);
          break;
        case 'ca':
          list = await _fetchCrowdOrOfficialCa(lat, lng, radiusKm, fuelType);
          break;
        case 'sa':
          list = _officialSaudi(lat, lng, fuelType);
          break;
        case 'ae':
          list = _officialUae(lat, lng, fuelType);
          break;
        case 'cn':
          list = _officialChina(lat, lng, fuelType);
          break;
        case 'us':
          list = await _fetchCrowdOrOfficialUs(lat, lng, radiusKm, fuelType);
          break;
        case 'in':
          list = await _fetchCrowdOrAverage(code, lat, lng, radiusKm, fuelType);
          break;
        default:
          list = await _fetchGermany(lat, lng, radiusKm, fuelType);
      }
      // Dense map for cities where open APIs return few pumps (London, Dubai, …).
      return await _ensureDenseMapCoverage(
        code: code,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        fuelType: fuelType,
        existing: list,
      );
    } catch (e) {
      // Soft-fail: never crash callers
      return [];
    }
  }

  static double haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;

  static Map<String, String> get _headers => {
        'User-Agent': _userAgent,
        'Accept': 'application/json',
      };

  /// Browser CORS block workaround for government CSV mirrors (Italy).
  static Future<http.Response> _httpGet(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final t = timeout ?? _timeout;
    final h = headers ?? _headers;
    try {
      final r = await http.get(Uri.parse(url), headers: h).timeout(t);
      if (r.statusCode == 200 && r.body.length > 100) return r;
    } catch (_) {}
    if (!kIsWeb) {
      return http.get(Uri.parse(url), headers: h).timeout(t);
    }
    final proxies = [
      'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}',
      'https://corsproxy.io/?${Uri.encodeComponent(url)}',
    ];
    for (final p in proxies) {
      try {
        final r = await http.get(Uri.parse(p), headers: {
          'Accept': h['Accept'] ?? '*/*',
        }).timeout(t);
        if (r.statusCode == 200 && r.body.length > 100) return r;
      } catch (_) {}
    }
    return http.Response('', 599);
  }

  static Map<String, dynamic> _station({
    required String id,
    required String name,
    required String brand,
    required String street,
    required String place,
    required String houseNumber,
    required double lat,
    required double lng,
    required double dist,
    required double price,
    bool isOpen = true,
    double? diesel,
    double? e5,
    double? e10,
  }) {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'street': street,
      'place': place,
      'houseNumber': houseNumber,
      'lat': lat,
      'lng': lng,
      'dist': double.parse(dist.toStringAsFixed(2)),
      'price': double.parse(price.toStringAsFixed(2)),
      'isOpen': isOpen,
      if (diesel != null) 'diesel': diesel,
      if (e5 != null) 'e5': e5,
      if (e10 != null) 'e10': e10,
    };
  }

  static List<Map<String, dynamic>> _sortAndCap(
    List<Map<String, dynamic>> list, {
    int limit = 80,
  }) {
    list.sort((a, b) {
      final pa = (a['price'] as num?)?.toDouble() ?? double.infinity;
      final pb = (b['price'] as num?)?.toDouble() ?? double.infinity;
      return pa.compareTo(pb);
    });
    if (list.length > limit) return list.sublist(0, limit);
    return list;
  }

  // ─── DE: Tankerkoenig ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchGermany(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    final rad = radiusKm > 25.0 ? 25.0 : radiusKm;
    const apiKey = 'ece7e50d-72fe-4e51-a996-555e56ca910c';
    final url =
        'https://creativecommons.tankerkoenig.de/json/list.php?lat=$lat&lng=$lng&rad=$rad&sort=price&type=$fuelType&apikey=$apiKey';
    final response =
        await http.get(Uri.parse(url), headers: _headers).timeout(_timeout);
    if (response.statusCode != 200) return [];
    final data = json.decode(response.body);
    if (data['ok'] != true) return [];
    final out = <Map<String, dynamic>>[];
    for (final s in (data['stations'] as List? ?? [])) {
      final price = (s['price'] as num?)?.toDouble();
      if (price == null || price <= 0) continue;
      out.add(_station(
        id: s['id']?.toString() ?? '${s['lat']}_${s['lng']}',
        name: s['name']?.toString() ?? 'Station',
        brand: s['brand']?.toString() ?? s['name']?.toString() ?? '',
        street: s['street']?.toString() ?? '',
        place: s['place']?.toString() ?? '',
        houseNumber: s['houseNumber']?.toString() ?? '',
        lat: (s['lat'] as num?)?.toDouble() ?? lat,
        lng: (s['lng'] as num?)?.toDouble() ?? lng,
        dist: (s['dist'] as num?)?.toDouble() ?? 0,
        price: price,
        isOpen: s['isOpen'] == true,
      ));
    }
    return _sortAndCap(out);
  }

  // ─── AT: E-Control ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchAustria(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    final atFuel = fuelType == 'diesel' ? 'DIE' : 'SUP';
    final uri = Uri.parse(
      'https://api.e-control.at/sprit/1.0/search/gas-stations/by-address'
      '?latitude=$lat&longitude=$lng&fuelType=$atFuel&includeClosed=true',
    );
    final response = await http
        .get(uri, headers: {'Accept': 'application/json', 'User-Agent': _userAgent})
        .timeout(_timeout);
    if (response.statusCode != 200) return [];
    final data = json.decode(response.body);
    if (data is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final s in data) {
      if (s is! Map) continue;
      final loc = s['location'];
      if (loc is! Map) continue;
      final sLat = (loc['latitude'] as num?)?.toDouble();
      final sLng = (loc['longitude'] as num?)?.toDouble();
      if (sLat == null || sLng == null) continue;
      final dist = haversineKm(lat, lng, sLat, sLng);
      if (dist > radiusKm) continue;
      final prices = s['prices'];
      double? amount;
      if (prices is List && prices.isNotEmpty) {
        amount = (prices[0]['amount'] as num?)?.toDouble();
      }
      if (amount == null || amount <= 0) continue;
      final address = loc['address']?.toString() ?? '';
      out.add(_station(
        id: s['id']?.toString() ?? '${sLat}_$sLng',
        name: s['name']?.toString() ?? 'Station',
        brand: s['name']?.toString() ?? '',
        street: address,
        place: loc['postalCode']?.toString() ?? '',
        houseNumber: '',
        lat: sLat,
        lng: sLng,
        dist: dist,
        price: amount,
        isOpen: s['open'] != false,
      ));
    }
    return _sortAndCap(out);
  }

  // ─── FR: data.economie.gouv.fr ──────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchFrance(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      final where =
          "within_distance(geom, GEOM'POINT($lng $lat)', ${radiusKm}km)";
      final uri = Uri.https(
        'data.economie.gouv.fr',
        '/api/explore/v2.1/catalog/datasets/prix-des-carburants-en-france-flux-instantane-v2/records',
        {'limit': '100', 'where': where},
      );
      final response =
          await http.get(uri, headers: _headers).timeout(_timeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body);
      final records = data['results'] ?? data['records'] ?? [];
      if (records is! List) return [];
      final out = <Map<String, dynamic>>[];
      for (final rec in records) {
        if (rec is! Map) continue;
        final fields = (rec['fields'] is Map)
            ? Map<String, dynamic>.from(rec['fields'] as Map)
            : Map<String, dynamic>.from(rec);
        final price = _frPrice(fields, fuelType);
        if (price == null || price <= 0) continue;
        double? sLat;
        double? sLng;
        final geom = fields['geom'] ?? fields['geo_point'] ?? fields['geometry'];
        if (geom is Map) {
          sLat = (geom['lat'] as num?)?.toDouble() ??
              (geom['latitude'] as num?)?.toDouble();
          sLng = (geom['lon'] as num?)?.toDouble() ??
              (geom['lng'] as num?)?.toDouble() ??
              (geom['longitude'] as num?)?.toDouble();
          final coords = geom['coordinates'];
          if ((sLat == null || sLng == null) && coords is List && coords.length >= 2) {
            sLng = (coords[0] as num?)?.toDouble();
            sLat = (coords[1] as num?)?.toDouble();
          }
        }
        sLat ??= (fields['latitude'] as num?)?.toDouble();
        sLng ??= (fields['longitude'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        final dist = haversineKm(lat, lng, sLat, sLng);
        out.add(_station(
          id: fields['id']?.toString() ??
              fields['id_station']?.toString() ??
              '${sLat}_$sLng',
          name: fields['name']?.toString() ??
              fields['enseigne']?.toString() ??
              'Station',
          brand: fields['enseigne']?.toString() ??
              fields['marque']?.toString() ??
              '',
          street: fields['adresse']?.toString() ??
              fields['address']?.toString() ??
              '',
          place: fields['ville']?.toString() ?? '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: price,
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static double? _frPrice(Map fields, String fuelType) {
    num? pick(List<String> keys) {
      for (final k in keys) {
        final v = fields[k];
        if (v is num) return v;
        if (v is String) {
          final p = double.tryParse(v.replaceAll(',', '.'));
          if (p != null) return p;
        }
      }
      return null;
    }

    switch (fuelType) {
      case 'diesel':
        return pick(['gazole_prix', 'prix_gazole', 'Gazole', 'gazole'])
            ?.toDouble();
      case 'e10':
        return pick(['e10_prix', 'prix_e10', 'E10', 'e10', 'sp95_e10_prix'])
            ?.toDouble();
      case 'e5':
      default:
        return pick([
          'sp95_prix',
          'prix_sp95',
          'SP95',
          'sp95',
          'sp98_prix',
          'prix_sp98',
          'SP98',
        ])?.toDouble();
    }
  }

  // ─── ES: MITECO ─────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchSpain(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    final now = DateTime.now();
    if (_esCache == null ||
        _esCacheAt == null ||
        now.difference(_esCacheAt!).inMinutes >= 20) {
      final uri = Uri.parse(
        'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/',
      );
      final response = await _httpGet(
        uri.toString(),
        headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
        timeout: const Duration(seconds: 45),
      );
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body);
      final list = data['ListaEESSPrecio'];
      if (list is! List) return [];
      _esCache = list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _esCacheAt = now;
    }

    final out = <Map<String, dynamic>>[];
    for (final s in _esCache!) {
      final sLat = _esDouble(s['Latitud'] ?? s['latitud'] ?? _esField(s, 'latitud'));
      final sLng = _esDouble(
        s['Longitud (WGS84)'] ??
            s['Longitud_(WGS84)'] ??
            s['Longitud'] ??
            s['longitud'] ??
            _esField(s, 'longitud'),
      );
      if (sLat == null || sLng == null) continue;
      final dist = haversineKm(lat, lng, sLat, sLng);
      if (dist > radiusKm) continue;
      final price = _esPrice(s, fuelType);
      if (price == null || price <= 0) continue;
      out.add(_station(
        id: s['IDEESS']?.toString() ?? '${sLat}_$sLng',
        name: s['Rótulo']?.toString() ??
            s['Rotulo']?.toString() ??
            'Estación',
        brand: s['Rótulo']?.toString() ?? s['Rotulo']?.toString() ?? '',
        street: s['Dirección']?.toString() ??
            s['Direccion']?.toString() ??
            '',
        place: s['Municipio']?.toString() ?? '',
        houseNumber: '',
        lat: sLat,
        lng: sLng,
        dist: dist,
        price: price,
      ));
    }
    return _sortAndCap(out);
  }

  static double? _esDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim().replaceAll(',', '.'));
  }

  /// Find ES API field by normalized name (spaces/encoding vary).
  static dynamic _esField(Map s, String needle) {
    final n = needle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final e in s.entries) {
      final k =
          e.key.toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (k == n || k.contains(n)) return e.value;
    }
    return null;
  }

  static double? _esPrice(Map s, String fuelType) {
    String? key;
    switch (fuelType) {
      case 'diesel':
        key = _firstKey(s, [
          'Precio Gasoleo A',
          'Precio_x0020_Gasoleo_x0020_A',
          'PrecioGasoleoA',
        ]);
        break;
      case 'e10':
        key = _firstKey(s, [
          'Precio Gasolina 95 E10',
          'Precio_x0020_Gasolina_x0020_95_x0020_E10',
          'PrecioGasolina95E10',
        ]);
        break;
      case 'e5':
      default:
        key = _firstKey(s, [
          'Precio Gasolina 95 E5',
          'Precio_x0020_Gasolina_x0020_95_x0020_E5',
          'PrecioGasolina95E5',
          'Precio Gasolina 95',
        ]);
    }
    if (key == null) return null;
    return _esDouble(s[key]);
  }

  static String? _firstKey(Map s, List<String> candidates) {
    for (final k in candidates) {
      if (s.containsKey(k) &&
          s[k] != null &&
          s[k].toString().trim().isNotEmpty) {
        return k;
      }
    }
    // Fuzzy: ignore spaces / encoding
    for (final entry in s.entries) {
      final norm = entry.key
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      for (final c in candidates) {
        final cn =
            c.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (norm == cn || norm.contains(cn)) return entry.key.toString();
      }
    }
    return null;
  }

  // ─── IT: Osservaprezzi zone API (+ asset/CSV fallback for web CORS) ─
  static Future<List<Map<String, dynamic>>> _fetchItaly(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      if (!kIsWeb) {
        final live = await _fetchItalyZone(lat, lng, radiusKm, fuelType);
        if (live.isNotEmpty) return live;
      }

      final now = DateTime.now();
      if (_itCache == null ||
          _itCacheAt == null ||
          now.difference(_itCacheAt!).inMinutes >= 20) {
        var stations = await _loadItalyFromAsset();
        if (stations.isEmpty && !kIsWeb) {
          stations = await _loadItalyJoined();
        }
        if (stations.isEmpty) return [];
        _itCache = stations;
        _itCacheAt = now;
      }
      final out = <Map<String, dynamic>>[];
      for (final s in _itCache!) {
        final sLat = (s['lat'] as num?)?.toDouble();
        final sLng = (s['lng'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        final dist = haversineKm(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        final price = (s[fuelType] as num?)?.toDouble();
        if (price == null || price <= 0) continue;
        out.add(_station(
          id: s['id']?.toString() ?? '${sLat}_$sLng',
          name: s['name']?.toString() ?? 'Stazione',
          brand: s['brand']?.toString() ?? '',
          street: s['street']?.toString() ?? '',
          place: s['place']?.toString() ?? '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: price,
          diesel: (s['diesel'] as num?)?.toDouble(),
          e5: (s['e5'] as num?)?.toDouble(),
          e10: (s['e10'] as num?)?.toDouble(),
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchItalyZone(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      final meters = (radiusKm * 1000).round().clamp(500, 25000);
      final uri = Uri.parse('https://carburanti.mise.gov.it/ospzApi/search/zone');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': _userAgent,
            },
            body: json.encode({
              'points': [
                {'lat': lat, 'lng': lng},
              ],
              'radius': meters,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body);
      final results = data is Map ? data['results'] : null;
      if (results is! List) return [];
      final out = <Map<String, dynamic>>[];
      for (final item in results) {
        if (item is! Map) continue;
        final loc = item['location'];
        if (loc is! Map) continue;
        final sLat = (loc['lat'] as num?)?.toDouble();
        final sLng = (loc['lng'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        final fuels = item['fuels'];
        if (fuels is! List) continue;
        double? diesel;
        double? e5;
        double? e10;
        for (final f in fuels) {
          if (f is! Map) continue;
          final name = (f['name'] ?? '').toString().toLowerCase();
          final price = (f['price'] as num?)?.toDouble();
          if (price == null || price <= 0) continue;
          final isSelf = f['isSelf'] == true;
          if (name.contains('gasolio') || name.contains('diesel')) {
            if (diesel == null || isSelf) diesel = price;
          } else if (name.contains('e10')) {
            if (e10 == null || isSelf) e10 = price;
          } else if (name.contains('benzina') || name.contains('verde')) {
            if (e5 == null || isSelf) e5 = price;
          }
        }
        final price = switch (fuelType) {
          'diesel' => diesel,
          'e10' => e10 ?? e5,
          _ => e5 ?? e10,
        };
        if (price == null || price <= 0) continue;
        final dist = (item['distance'] is num)
            ? (item['distance'] as num).toDouble()
            : haversineKm(lat, lng, sLat, sLng);
        out.add(_station(
          id: item['id']?.toString() ?? '${sLat}_$sLng',
          name: item['name']?.toString() ?? 'Stazione',
          brand: item['brand']?.toString() ?? '',
          street: item['address']?.toString() ?? '',
          place: '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: price,
          diesel: diesel,
          e5: e5,
          e10: e10,
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _loadItalyFromAsset() async {
    try {
      final raw = await rootBundle.loadString('assets/italy_fuel_cache.json');
      final data = json.decode(raw);
      if (data is! List) return [];
      final out = <Map<String, dynamic>>[];
      for (final item in data) {
        if (item is! Map) continue;
        final sLat = (item['la'] as num?)?.toDouble();
        final sLng = (item['lo'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        out.add({
          'id': item['i']?.toString() ?? '${sLat}_$sLng',
          'name': item['n']?.toString() ?? 'Stazione',
          'brand': item['b']?.toString() ?? '',
          'street': item['a']?.toString() ?? '',
          'place': item['p']?.toString() ?? '',
          'lat': sLat,
          'lng': sLng,
          if (item['d'] != null) 'diesel': (item['d'] as num).toDouble(),
          if (item['e5'] != null) 'e5': (item['e5'] as num).toDouble(),
          if (item['e10'] != null) 'e10': (item['e10'] as num).toDouble(),
        });
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _loadItalyJoined() async {
    // MIMIT (ex-MISE) open CSV feeds; delimiter is '|', first line is a date banner.
    const anagraficaUrls = [
      'https://www.mimit.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv',
      'https://www.mise.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv',
    ];
    const prezzoUrls = [
      'https://www.mimit.gov.it/images/exportCSV/prezzo_alle_8.csv',
      'https://www.mise.gov.it/images/exportCSV/prezzo_alle_8.csv',
    ];

    String? anaBody;
    String? prezzoBody;
    for (final url in anagraficaUrls) {
      try {
        final r = await _httpGet(
          url,
          headers: {
            'User-Agent': _userAgent,
            'Accept': 'text/csv,text/plain,*/*',
          },
          timeout: const Duration(seconds: 60),
        );
        if (r.statusCode == 200 && r.body.length > 100) {
          anaBody = r.body;
          break;
        }
      } catch (_) {}
    }
    for (final url in prezzoUrls) {
      try {
        final r = await _httpGet(
          url,
          headers: {
            'User-Agent': _userAgent,
            'Accept': 'text/csv,text/plain,*/*',
          },
          timeout: const Duration(seconds: 60),
        );
        if (r.statusCode == 200 && r.body.length > 100) {
          prezzoBody = r.body;
          break;
        }
      } catch (_) {}
    }
    if (anaBody == null || prezzoBody == null) return [];

    final plants = <String, Map<String, dynamic>>{};
    final anaLines = const LineSplitter().convert(anaBody);
    for (final lineRaw in anaLines) {
      final line = lineRaw.trim();
      if (line.isEmpty) continue;
      final lower = line.toLowerCase();
      if (lower.startsWith('estrazione') || lower.contains('idimpianto')) {
        continue;
      }
      final parts = _itSplitCsvLine(line);
      if (parts.length < 10) continue;
      final id = parts[0].trim();
      final lat = double.tryParse(parts[8].trim().replaceAll(',', '.'));
      final lng = double.tryParse(parts[9].trim().replaceAll(',', '.'));
      if (id.isEmpty || lat == null || lng == null) continue;
      plants[id] = {
        'id': id,
        'brand': parts[2].trim(),
        'name': parts[4].trim().isNotEmpty
            ? parts[4].trim()
            : (parts[2].trim().isNotEmpty ? parts[2].trim() : 'Stazione'),
        'street': parts[5].trim(),
        'place': parts[6].trim(),
        'lat': lat,
        'lng': lng,
      };
    }

    final prezzoLines = const LineSplitter().convert(prezzoBody);
    for (final lineRaw in prezzoLines) {
      final line = lineRaw.trim();
      if (line.isEmpty) continue;
      final lower = line.toLowerCase();
      if (lower.startsWith('estrazione') || lower.contains('idimpianto')) {
        continue;
      }
      final parts = _itSplitCsvLine(line);
      if (parts.length < 3) continue;
      final id = parts[0].trim();
      final plant = plants[id];
      if (plant == null) continue;
      final desc = parts[1].toLowerCase();
      final price = double.tryParse(parts[2].trim().replaceAll(',', '.'));
      if (price == null || price <= 0) continue;
      if (desc.contains('gasolio') || desc.contains('diesel')) {
        plant['diesel'] = price;
      } else if (desc.contains('e10')) {
        plant['e10'] = price;
      } else if (desc.contains('benzina') ||
          desc.contains('verde') ||
          desc.contains('e5')) {
        plant['e5'] ??= price;
      }
    }
    return plants.values.toList();
  }

  /// Italy MIMIT CSVs use '|'; older mirrors may still use ';'.
  static List<String> _itSplitCsvLine(String line) {
    if (line.contains('|')) return line.split('|');
    return line.split(';');
  }

  // ─── UK: CMA retailer JSONs ─────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchUk(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    const urls = [
      'https://storelocator.asda.com/fuel_prices_data.json',
      'https://www.bp.com/en_gb/united-kingdom/home/fuelprices/fuel_prices_data.json',
      'https://fuelprices.esso.co.uk/latitude/fuel_prices_data.json',
      'https://www.morrisons.com/fuel-prices/fuel.json',
      'https://www.shell.co.uk/fuel-prices-data/_jcr_content.feed.json',
      'https://www.shell.co.uk/fuel-prices-data.json',
      'https://www.sainsburys.co.uk/gol-ui/fuel-prices/fuel_prices_data.json',
      'https://www.tesco.com/fuel_prices/fuel_prices_data.json',
    ];

    final futures = urls.map((url) async {
      try {
        final r = await http
            .get(Uri.parse(url), headers: _headers)
            .timeout(_timeout);
        if (r.statusCode != 200) return <Map<String, dynamic>>[];
        return _parseCmaStations(r.body, lat, lng, radiusKm, fuelType);
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    });

    final chunks = await Future.wait(futures);
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final chunk in chunks) {
      for (final s in chunk) {
        final key = s['id']?.toString() ?? '${s['lat']}_${s['lng']}';
        if (seen.add(key)) out.add(s);
      }
    }
    return _sortAndCap(out);
  }

  static List<Map<String, dynamic>> _parseCmaStations(
    String body,
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) {
    dynamic data;
    try {
      data = json.decode(body);
    } catch (_) {
      return [];
    }
    List? stations;
    if (data is Map) {
      stations = data['stations'] as List? ?? data['Sites'] as List?;
    } else if (data is List) {
      stations = data;
    }
    if (stations == null) return [];

    final priceKey = fuelType == 'diesel'
        ? 'B7'
        : fuelType == 'e10'
            ? 'E10'
            : 'E5';

    final out = <Map<String, dynamic>>[];
    for (final s in stations) {
      if (s is! Map) continue;
      final loc = s['location'] ?? s['Location'];
      double? sLat;
      double? sLng;
      if (loc is Map) {
        sLat = (loc['latitude'] as num?)?.toDouble() ??
            (loc['lat'] as num?)?.toDouble();
        sLng = (loc['longitude'] as num?)?.toDouble() ??
            (loc['lng'] as num?)?.toDouble();
      }
      sLat ??= (s['latitude'] as num?)?.toDouble();
      sLng ??= (s['longitude'] as num?)?.toDouble();
      if (sLat == null || sLng == null) continue;
      final dist = haversineKm(lat, lng, sLat, sLng);
      if (dist > radiusKm) continue;
      final prices = s['prices'] ?? s['Prices'];
      double? price;
      if (prices is Map) {
        final raw = prices[priceKey] ??
            prices[priceKey.toLowerCase()] ??
            (fuelType == 'diesel' ? prices['B7'] : null);
        if (raw is num) price = raw.toDouble();
        if (raw is String) price = double.tryParse(raw);
      }
      if (price == null || price <= 0) continue;
      // CMA often uses pence
      if (price > 20) price = price / 100.0;
      final addr = s['address'] ?? s['Address'] ?? '';
      out.add(_station(
        id: s['site_id']?.toString() ??
            s['id']?.toString() ??
            '${sLat}_$sLng',
        name: s['brand']?.toString() ??
            s['name']?.toString() ??
            'Station',
        brand: s['brand']?.toString() ?? '',
        street: addr.toString(),
        place: s['postcode']?.toString() ?? '',
        houseNumber: '',
        lat: sLat,
        lng: sLng,
        dist: dist,
        price: price,
      ));
    }
    return out;
  }

  // ─── AU: NSW FuelCheck (+ optional WA FuelWatch) ────────────────────
  static Future<List<Map<String, dynamic>>> _fetchAustralia(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
    String? australiaApiKey,
  ) async {
    final key = australiaApiKey?.trim() ?? '';
    if (key.isEmpty) {
      // Soft bonus: WA FuelWatch RSS near Perth when no key
      if (_nearPerth(lat, lng)) {
        final wa = await _fetchWaFuelWatch(lat, lng, radiusKm, fuelType);
        if (wa.isNotEmpty) return wa;
      }
      return [];
    }

    try {
      final auFuel = fuelType == 'diesel'
          ? 'DL'
          : fuelType == 'e10'
              ? 'E10'
              : 'P95';
      final uri = Uri.parse(
        'https://api.onegov.nsw.gov.au/FuelCheckApp/v1/fuel/prices/nearby'
        '?latitude=$lat&longitude=$lng&radius=$radiusKm&fueltype=$auFuel',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
          'Authorization': 'apikey $key',
          'apikey': key,
        },
      ).timeout(_timeout);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body);
      final list = data is List
          ? data
          : (data['stations'] ?? data['Prices'] ?? data['result'] ?? []);
      if (list is! List) return [];
      final out = <Map<String, dynamic>>[];
      for (final s in list) {
        if (s is! Map) continue;
        final loc = s['location'];
        double? sLat;
        double? sLng;
        if (loc is Map) {
          sLat = (loc['latitude'] as num?)?.toDouble();
          sLng = (loc['longitude'] as num?)?.toDouble();
        }
        sLat ??= (s['lat'] as num?)?.toDouble() ??
            (s['Latitude'] as num?)?.toDouble();
        sLng ??= (s['lng'] as num?)?.toDouble() ??
            (s['Longitude'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        final dist = (s['distance'] as num?)?.toDouble() ??
            haversineKm(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        final price = (s['price'] as num?)?.toDouble() ??
            (s['Price'] as num?)?.toDouble() ??
            (s['Amount'] as num?)?.toDouble();
        if (price == null || price <= 0) continue;
        // NSW often cents/litre
        final normalized = price > 20 ? price / 100.0 : price;
        out.add(_station(
          id: s['stationcode']?.toString() ??
              s['id']?.toString() ??
              '${sLat}_$sLng',
          name: s['name']?.toString() ??
              s['Name']?.toString() ??
              'Station',
          brand: s['brand']?.toString() ?? s['Brand']?.toString() ?? '',
          street: s['address']?.toString() ?? '',
          place: s['suburb']?.toString() ?? '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: normalized,
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static bool _nearPerth(double lat, double lng) {
    return haversineKm(lat, lng, -31.9505, 115.8605) < 120;
  }

  static Future<List<Map<String, dynamic>>> _fetchWaFuelWatch(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      final product = fuelType == 'diesel'
          ? '4'
          : fuelType == 'e10'
              ? '5'
              : '1';
      final uri = Uri.parse(
        'https://www.fuelwatch.wa.gov.au/fuelwatch/rss?Product=$product',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode != 200) return [];
      // Minimal RSS item scrape — soft-fail OK
      final items = RegExp(
        r'<item>(.*?)</item>',
        dotAll: true,
      ).allMatches(response.body);
      final out = <Map<String, dynamic>>[];
      for (final m in items) {
        final item = m.group(1) ?? '';
        String tag(String name) {
          final mm = RegExp('<$name>(.*?)</$name>', dotAll: true)
              .firstMatch(item);
          return mm?.group(1)?.trim() ?? '';
        }

        final title = tag('title');
        final priceStr = tag('description');
        final priceMatch =
            RegExp(r'([\d.]+)').firstMatch(priceStr);
        final price = double.tryParse(priceMatch?.group(1) ?? '');
        if (price == null || price <= 0) continue;
        // FuelWatch RSS lacks precise coords; pin near Perth CBD with tiny jitter skip
        final sLat = -31.9505;
        final sLng = 115.8605;
        final dist = haversineKm(lat, lng, sLat, sLng);
        if (dist > radiusKm + 50) continue;
        final normalized = price > 20 ? price / 100.0 : price;
        out.add(_station(
          id: 'wa_${title.hashCode}',
          name: title.isEmpty ? 'FuelWatch' : title,
          brand: 'FuelWatch WA',
          street: tag('address'),
          place: 'WA',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: normalized,
        ));
      }
      return _sortAndCap(out, limit: 40);
    } catch (_) {
      return [];
    }
  }

  // ─── PT: DGEG Preços Combustíveis ───────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchPortugal(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      final fuelId = switch (fuelType) {
        'diesel' => '2101',
        'e10' => '3201',
        _ => '3201',
      };
      final now = DateTime.now();
      if (_ptCacheAt == null ||
          now.difference(_ptCacheAt!).inMinutes >= 30 ||
          !_ptCacheByFuel.containsKey(fuelId)) {
        final all = <Map<String, dynamic>>[];
        for (var page = 1; page <= 25; page++) {
          final uri = Uri.parse(
            'https://precoscombustiveis.dgeg.gov.pt/api/PrecoComb/PesquisarPostos'
            '?idsTiposComb=$fuelId&qtdPorPagina=500&pagina=$page',
          );
          final response = await _httpGet(
            uri.toString(),
            timeout: const Duration(seconds: 30),
          );
          if (response.statusCode != 200) break;
          final data = json.decode(response.body);
          final list = data is Map ? data['resultado'] : null;
          if (list is! List || list.isEmpty) break;
          for (final s in list) {
            if (s is Map) all.add(Map<String, dynamic>.from(s));
          }
          if (list.length < 500) break;
        }
        _ptCacheByFuel[fuelId] = all;
        _ptCacheAt = now;
      }

      final out = <Map<String, dynamic>>[];
      for (final s in _ptCacheByFuel[fuelId] ?? const []) {
        final sLat = (s['Latitude'] as num?)?.toDouble();
        final sLng = (s['Longitude'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        final dist = haversineKm(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        final price = _parseLocalizedPrice(s['Preco']);
        if (price == null || price <= 0) continue;
        out.add(_station(
          id: s['Id']?.toString() ?? '${sLat}_$sLng',
          name: s['Nome']?.toString() ?? 'Posto',
          brand: s['Marca']?.toString() ?? '',
          street: s['Morada']?.toString() ?? '',
          place: s['Municipio']?.toString() ?? '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: price,
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static double? _parseLocalizedPrice(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    final m = RegExp(r'[-+]?\d+[.,]?\d*').firstMatch(raw.toString());
    if (m == null) return null;
    return double.tryParse(m.group(0)!.replaceAll(',', '.'));
  }

  // ─── BE / NL / LU: ANWB fuel stations ───────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchAnwb(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
    String iso3,
  ) async {
    try {
      final rad = radiusKm.clamp(3.0, 40.0);
      final dLat = rad / 111.0;
      final dLng = rad / (111.0 * math.cos(_rad(lat)).abs().clamp(0.2, 1.0));
      final bbox =
          '${lat - dLat},${lng - dLng},${lat + dLat},${lng + dLng}';
      final uri = Uri.parse(
        'https://api.anwb.nl/routing/points-of-interest/v3/all'
        '?type-filter=FUEL_STATION&bounding-box-filter=$bbox',
      );
      final response = await http
          .get(uri, headers: {
            'Accept': 'application/json',
            'User-Agent':
                'Mozilla/5.0 (compatible; TankenDE/1.0)',
          })
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body);
      final list = data is Map ? data['value'] : null;
      if (list is! List) return [];
      final out = <Map<String, dynamic>>[];
      for (final s in list) {
        if (s is! Map) continue;
        final addr = s['address'];
        final iso = addr is Map
            ? (addr['iso3CountryCode']?.toString() ?? '')
            : '';
        if (iso.isNotEmpty && iso != iso3) continue;
        final coords = s['coordinates'];
        if (coords is! Map) continue;
        final sLat = (coords['latitude'] as num?)?.toDouble();
        final sLng = (coords['longitude'] as num?)?.toDouble();
        if (sLat == null || sLng == null) continue;
        final dist = haversineKm(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        final price = _anwbPrice(s['prices'], fuelType);
        if (price == null || price <= 0) continue;
        out.add(_station(
          id: s['id']?.toString() ?? '${sLat}_$sLng',
          name: s['title']?.toString() ?? 'Station',
          brand: (s['title']?.toString() ?? '').split(' ').first,
          street: addr is Map
              ? (addr['streetAddress']?.toString() ?? '')
              : '',
          place: addr is Map ? (addr['city']?.toString() ?? '') : '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: price,
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static double? _anwbPrice(dynamic prices, String fuelType) {
    if (prices is! List) return null;
    String want;
    switch (fuelType) {
      case 'diesel':
        want = 'DIESEL';
        break;
      case 'e10':
        want = 'EURO95';
        break;
      case 'e5':
      default:
        want = 'EURO98';
    }
    double? fallback;
    for (final p in prices) {
      if (p is! Map) continue;
      final type = (p['fuelType'] ?? '').toString().toUpperCase();
      final value = (p['value'] as num?)?.toDouble();
      if (value == null || value <= 0) continue;
      if (type == want) return value;
      if (fuelType == 'e5' && type == 'EURO95') fallback ??= value;
      if (fuelType == 'diesel' && type.contains('DIESEL')) fallback ??= value;
    }
    return fallback;
  }

  // ─── SI: goriva.si ──────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _fetchSlovenia(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      final meters = (radiusKm * 1000).round().clamp(1000, 50000);
      final uri = Uri.parse(
        'https://goriva.si/api/v1/search/'
        '?position=$lat,$lng&radius=$meters&franchise=&name=&o=',
      );
      final out = <Map<String, dynamic>>[];
      String? next = uri.toString();
      var pages = 0;
      while (next != null && pages < 5) {
        pages++;
        final response = await http
            .get(Uri.parse(next), headers: _headers)
            .timeout(_timeout);
        if (response.statusCode != 200) break;
        final data = json.decode(response.body);
        final results = data is Map ? data['results'] : null;
        if (results is! List) break;
        for (final s in results) {
          if (s is! Map) continue;
          final sLat = (s['lat'] as num?)?.toDouble();
          final sLng = (s['lng'] as num?)?.toDouble();
          if (sLat == null || sLng == null) continue;
          final dist = haversineKm(lat, lng, sLat, sLng);
          if (dist > radiusKm) continue;
          final prices = s['prices'];
          if (prices is! Map) continue;
          final price = _siPrice(prices, fuelType);
          if (price == null || price <= 0) continue;
          out.add(_station(
            id: s['pk']?.toString() ?? '${sLat}_$sLng',
            name: s['name']?.toString() ?? 'Postaja',
            brand: '',
            street: s['address']?.toString() ?? '',
            place: '',
            houseNumber: '',
            lat: sLat,
            lng: sLng,
            dist: dist,
            price: price,
          ));
        }
        next = data is Map ? data['next']?.toString() : null;
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  static double? _siPrice(Map prices, String fuelType) {
    switch (fuelType) {
      case 'diesel':
        return (prices['dizel'] as num?)?.toDouble() ??
            (prices['dizel-premium'] as num?)?.toDouble();
      case 'e10':
      case 'e5':
      default:
        return (prices['95'] as num?)?.toDouble() ??
            (prices['98'] as num?)?.toDouble() ??
            (prices['100'] as num?)?.toDouble();
    }
  }

  // ─── HR: MZOE data.json (lat/long swapped in source) ────────────────
  static Future<List<Map<String, dynamic>>> _fetchCroatia(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    try {
      final now = DateTime.now();
      if (_hrCache == null ||
          _hrCacheAt == null ||
          now.difference(_hrCacheAt!).inMinutes >= 30) {
        final response = await _httpGet(
          'https://mzoe-gor.hr/data.json',
          timeout: const Duration(seconds: 40),
        );
        if (response.statusCode != 200) return [];
        final data = json.decode(response.body);
        if (data is! Map) return [];
        _hrCache = Map<String, dynamic>.from(data);
        _hrCacheAt = now;
      }
      final data = _hrCache!;
      final postajas = data['postajas'];
      final gorivos = data['gorivos'];
      final obvezniks = data['obvezniks'];
      if (postajas is! List) return [];

      final gorivoToVrsta = <int, int>{};
      if (gorivos is List) {
        for (final g in gorivos) {
          if (g is! Map) continue;
          final id = g['id'];
          final vrsta = g['vrsta_goriva_id'];
          if (id is num && vrsta is num) {
            gorivoToVrsta[id.toInt()] = vrsta.toInt();
          }
        }
      }
      final brands = <int, String>{};
      if (obvezniks is List) {
        for (final b in obvezniks) {
          if (b is! Map) continue;
          final id = b['id'];
          if (id is num) brands[id.toInt()] = b['naziv']?.toString() ?? '';
        }
      }

      // vrsta: 2=E95, 8=diesel regular, 1=E95 premium, 7=diesel premium
      final wantVrsta = switch (fuelType) {
        'diesel' => {7, 8},
        _ => {1, 2, 5, 6},
      };

      final out = <Map<String, dynamic>>[];
      for (final s in postajas) {
        if (s is! Map) continue;
        // API bug: lat field holds longitude, long holds latitude.
        final sLng = double.tryParse(s['lat']?.toString() ?? '');
        final sLat = double.tryParse(s['long']?.toString() ?? '');
        if (sLat == null || sLng == null) continue;
        final dist = haversineKm(lat, lng, sLat, sLng);
        if (dist > radiusKm) continue;
        final cjenici = s['cjenici'];
        if (cjenici is! List) continue;
        double? best;
        for (final c in cjenici) {
          if (c is! Map) continue;
          final gid = c['gorivo_id'];
          if (gid is! num) continue;
          final vrsta = gorivoToVrsta[gid.toInt()];
          if (vrsta == null || !wantVrsta.contains(vrsta)) continue;
          final price = (c['cijena'] as num?)?.toDouble();
          if (price == null || price <= 0) continue;
          if (best == null || price < best) best = price;
        }
        if (best == null) continue;
        final brandId = s['obveznik_id'];
        out.add(_station(
          id: s['id']?.toString() ?? '${sLat}_$sLng',
          name: s['naziv']?.toString() ?? 'Benzinska',
          brand: brandId is num ? (brands[brandId.toInt()] ?? '') : '',
          street: s['adresa']?.toString() ?? '',
          place: s['mjesto']?.toString() ?? '',
          houseNumber: '',
          lat: sLat,
          lng: sLng,
          dist: dist,
          price: best,
        ));
      }
      return _sortAndCap(out);
    } catch (_) {
      return [];
    }
  }

  // ─── National averages (OpenVan.camp, free CC BY 4.0) ───────────────
  static Future<List<Map<String, dynamic>>> _fetchNationalAverage(
    String countryCode,
    double lat,
    double lng,
    String fuelType,
  ) async {
    try {
      final now = DateTime.now();
      if (_openVanCache == null ||
          _openVanCacheAt == null ||
          now.difference(_openVanCacheAt!).inHours >= 6) {
        final response = await _httpGet(
          'https://openvan.camp/api/fuel/prices',
          timeout: const Duration(seconds: 25),
        );
        if (response.statusCode != 200) return [];
        final data = json.decode(response.body);
        final map = data is Map ? data['data'] : null;
        if (map is! Map) return [];
        _openVanCache = Map<String, dynamic>.from(map);
        _openVanCacheAt = now;
      }
      final cc = countryCode.toUpperCase();
      final entry = _openVanCache![cc];
      if (entry is! Map) return [];
      final prices = entry['prices'];
      if (prices is! Map) return [];
      double? price;
      switch (fuelType) {
        case 'diesel':
          price = (prices['diesel'] as num?)?.toDouble() ??
              (prices['diesel_premium'] as num?)?.toDouble();
          break;
        case 'e10':
          price = (prices['gasoline'] as num?)?.toDouble() ??
              (prices['gasoline_regular'] as num?)?.toDouble();
          break;
        case 'e5':
        default:
          price = (prices['gasoline_premium'] as num?)?.toDouble() ??
              (prices['premium'] as num?)?.toDouble() ??
              (prices['gasoline'] as num?)?.toDouble();
      }
      if (price == null || price <= 0) return [];
      final name = entry['country_name']?.toString() ?? cc;
      return [
        _station(
          id: 'national-avg-$cc',
          name: 'National average — $name',
          brand: 'OpenVan',
          street: 'Country-wide average (not a single pump)',
          place: name,
          houseNumber: '',
          lat: lat,
          lng: lng,
          dist: 0,
          price: price,
        ),
      ];
    } catch (_) {
      return [];
    }
  }

  static List<Map<String, dynamic>> _fromOfficial(
    OfficialFuelSnapshot snap,
    double lat,
    double lng,
    String fuelType, {
    String? titlePrefix,
  }) {
    final price = OfficialFuelPrices.pickPrice(snap.prices, fuelType);
    if (price == null || price <= 0) return [];
    final region = snap.region != null ? ' · ${snap.region}' : '';
    return [
      _station(
        id: 'official-${snap.countryCode}-${snap.periodLabel}',
        name: '${titlePrefix ?? 'Official'} · ${snap.periodLabel}$region',
        brand: snap.sourceName,
        street: snap.note ?? snap.sourceUrl,
        place: snap.countryCode.toUpperCase(),
        houseNumber: '',
        lat: lat,
        lng: lng,
        dist: 0,
        price: price,
      ),
    ];
  }

  static List<Map<String, dynamic>> _officialSaudi(
    double lat,
    double lng,
    String fuelType,
  ) {
    return _fromOfficial(
      OfficialFuelPrices.saudiFixed,
      lat,
      lng,
      fuelType,
      titlePrefix: 'Aramco fixed',
    );
  }

  static List<Map<String, dynamic>> _officialUae(
    double lat,
    double lng,
    String fuelType,
  ) {
    // Nationwide monthly rate — same at every pump. Only current month on map.
    return _fromOfficial(
      OfficialFuelPrices.uaeCurrent,
      lat,
      lng,
      fuelType,
      titlePrefix: 'UAE official',
    );
  }

  static List<Map<String, dynamic>> _officialChina(
    double lat,
    double lng,
    String fuelType,
  ) {
    final snap = OfficialFuelPrices.chinaFor(lat, lng);
    return _fromOfficial(
      snap,
      lat,
      lng,
      fuelType,
      titlePrefix: 'China provincial',
    );
  }

  static Future<List<Map<String, dynamic>>> _fetchCrowdOrAverage(
    String code,
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    final crowd = await CommunityFuelService.fetchNearby(
      countryCode: code,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      fuelType: fuelType,
    );
    if (crowd.isNotEmpty) return _sortAndCap(crowd);
    // Fallback: national average so the map is never empty
    return _fetchNationalAverage(code, lat, lng, fuelType);
  }

  static Future<List<Map<String, dynamic>>> _fetchCrowdOrOfficialUs(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    final crowd = await CommunityFuelService.fetchNearby(
      countryCode: 'us',
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      fuelType: fuelType,
    );
    if (crowd.isNotEmpty) return _sortAndCap(crowd);
    return _fromOfficial(
      OfficialFuelPrices.usaFor(lat, lng),
      lat,
      lng,
      fuelType,
      titlePrefix: 'US regional avg',
    );
  }

  static Future<List<Map<String, dynamic>>> _fetchCrowdOrOfficialCa(
    double lat,
    double lng,
    double radiusKm,
    String fuelType,
  ) async {
    final crowd = await CommunityFuelService.fetchNearby(
      countryCode: 'ca',
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      fuelType: fuelType,
    );
    if (crowd.isNotEmpty) return _sortAndCap(crowd);
    return _fromOfficial(
      OfficialFuelPrices.canadaFor(lat, lng),
      lat,
      lng,
      fuelType,
      titlePrefix: 'Canada provincial',
    );
  }

  /// When APIs only return a few pins (UK CMA / UAE official / national avg),
  /// fill the map with OpenStreetMap fuel POIs stamped with a reference price.
  static Future<List<Map<String, dynamic>>> _ensureDenseMapCoverage({
    required String code,
    required double lat,
    required double lng,
    required double radiusKm,
    required String fuelType,
    required List<Map<String, dynamic>> existing,
  }) async {
    const denseApis = {
      'de', 'at', 'fr', 'es', 'it', 'pt', 'be', 'nl', 'lu', 'si', 'hr',
    };
    if (denseApis.contains(code) && existing.length >= 12) {
      return existing;
    }
    if (existing.length >= 25) return existing;

    double? refPrice;
    // Regulated / regional markets: stamp every pin with the reference rate.
    if (code == 'ae') {
      refPrice = OfficialFuelPrices.pickPrice(
        OfficialFuelPrices.uaeCurrent.prices,
        fuelType,
      );
    } else if (code == 'sa') {
      refPrice = OfficialFuelPrices.pickPrice(
        OfficialFuelPrices.saudiFixed.prices,
        fuelType,
      );
    } else if (code == 'us') {
      refPrice = OfficialFuelPrices.pickPrice(
        OfficialFuelPrices.usaFor(lat, lng).prices,
        fuelType,
      );
    } else if (code == 'ca') {
      refPrice = OfficialFuelPrices.pickPrice(
        OfficialFuelPrices.canadaFor(lat, lng).prices,
        fuelType,
      );
    } else if (code == 'cn') {
      refPrice = OfficialFuelPrices.pickPrice(
        OfficialFuelPrices.chinaFor(lat, lng).prices,
        fuelType,
      );
    }
    if (refPrice == null) {
      for (final s in existing) {
        final p = (s['price'] as num?)?.toDouble();
        if (p != null && p > 0) {
          refPrice = p;
          break;
        }
      }
    }
    if (refPrice == null) {
      final avg = await _fetchNationalAverage(code, lat, lng, fuelType);
      refPrice = avg.isNotEmpty ? (avg.first['price'] as num?)?.toDouble() : null;
    }
    refPrice ??= _fallbackReferencePrice(code, fuelType);
    if (refPrice == null || refPrice <= 0) return existing;

    // Wider search for sparse APIs / big cities so NY/LA/Beijing fill densely.
    final osmRadius = math.max(radiusKm, code == 'cn' || code == 'us' || code == 'ca' ? 12.0 : 8.0);
    final osm = await _fetchOsmFuelStations(lat, lng, osmRadius, refPrice);
    if (osm.isEmpty) {
      if (code == 'ae' || code == 'sa') {
        for (final s in existing) {
          s['price'] = refPrice;
        }
      }
      return existing;
    }

    final seen = <String>{};
    final merged = <Map<String, dynamic>>[];
    for (final s in [...existing, ...osm]) {
      final key = s['id']?.toString() ??
          '${(s['lat'] as num?)?.toStringAsFixed(4)}_'
              '${(s['lng'] as num?)?.toStringAsFixed(4)}';
      if (seen.add(key)) merged.add(s);
    }
    if (code == 'ae' || code == 'sa') {
      for (final s in merged) {
        s['price'] = refPrice;
      }
    }
    return _sortAndCap(merged, limit: 100);
  }

  static double? _fallbackReferencePrice(String code, String fuelType) {
    // Approximate street prices so OSM pins can still render when OpenVan has no row.
    const table = <String, Map<String, double>>{
      'us': {'diesel': 3.85, 'e10': 3.25, 'e5': 3.95, 'e5_98': 4.20},
      'ca': {'diesel': 1.65, 'e10': 1.52, 'e5': 1.72},
      'cn': {'diesel': 7.90, 'e10': 8.20, 'e5': 8.70},
      'in': {'diesel': 90.0, 'e10': 95.0, 'e5': 102.0},
      'ae': {'diesel': 4.30, 'e10': 3.61, 'e5': 3.69, 'e5_98': 3.80},
      'sa': {'diesel': 1.79, 'e10': 2.18, 'e5': 2.33, 'e5_98': 4.64},
      'uk': {'diesel': 1.45, 'e10': 1.38, 'e5': 1.52},
      'au': {'diesel': 1.85, 'e10': 1.75, 'e5': 1.95},
    };
    final row = table[code];
    if (row == null) return null;
    return row[fuelType] ?? row['e10'] ?? row['diesel'];
  }

  static Future<List<Map<String, dynamic>>> _fetchOsmFuelStations(
    double lat,
    double lng,
    double radiusKm,
    double refPrice,
  ) async {
    final meters = (radiusKm * 1000).round().clamp(5000, 30000);
    final query = '''
[out:json][timeout:20];
(
  node(around:$meters,$lat,$lng)["amenity"="fuel"];
  way(around:$meters,$lat,$lng)["amenity"="fuel"];
);
out center 120;
''';
    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass.private.coffee/api/interpreter',
    ];

    final completer = Completer<List<dynamic>>();
    var remaining = endpoints.length;
    for (final endpoint in endpoints) {
      () async {
        try {
          final response = await http
              .post(
                Uri.parse(endpoint),
                headers: {
                  'User-Agent': _userAgent,
                  'Accept': 'application/json',
                },
                body: query,
              )
              .timeout(const Duration(seconds: 20));
          if (response.statusCode != 200) return;
          final decoded = json.decode(response.body);
          final els = decoded is Map ? decoded['elements'] : null;
          if (els is List && els.isNotEmpty && !completer.isCompleted) {
            completer.complete(List<dynamic>.from(els));
          }
        } catch (_) {
          // try next mirror
        } finally {
          remaining--;
          if (remaining <= 0 && !completer.isCompleted) {
            completer.complete(const <dynamic>[]);
          }
        }
      }();
    }

    List<dynamic> elements;
    try {
      elements = await completer.future.timeout(const Duration(seconds: 22));
    } catch (_) {
      return [];
    }
    if (elements.isEmpty) return [];

    final out = <Map<String, dynamic>>[];
    for (final el in elements) {
      if (el is! Map) continue;
      double? sLat = (el['lat'] as num?)?.toDouble();
      double? sLng = (el['lon'] as num?)?.toDouble();
      final center = el['center'];
      if ((sLat == null || sLng == null) && center is Map) {
        sLat = (center['lat'] as num?)?.toDouble();
        sLng = (center['lon'] as num?)?.toDouble();
      }
      if (sLat == null || sLng == null) continue;
      final tags = el['tags'];
      final name = tags is Map
          ? (tags['name'] ?? tags['brand'] ?? tags['operator'] ?? 'Fuel station')
              .toString()
          : 'Fuel station';
      final brand = tags is Map
          ? (tags['brand'] ?? tags['operator'] ?? '').toString()
          : '';
      final street = tags is Map
          ? (tags['addr:street'] ?? '').toString()
          : '';
      final dist = haversineKm(lat, lng, sLat, sLng);
      out.add(_station(
        id: 'osm_${el['type']}_${el['id']}',
        name: name,
        brand: brand.isEmpty ? 'OSM' : brand,
        street: street,
        place: '',
        houseNumber: tags is Map
            ? (tags['addr:housenumber'] ?? '').toString()
            : '',
        lat: sLat,
        lng: sLng,
        dist: dist,
        price: refPrice,
      ));
    }
    return out;
  }
}
