class FuelCity {
  final String display;
  final double lat;
  final double lng;
  final List<String> aliases;

  const FuelCity({
    required this.display,
    required this.lat,
    required this.lng,
    this.aliases = const [],
  });
}

class FuelCountry {
  final String code;
  final String nameEn;
  final String nameFa;
  final String nameDe;
  final String currency;
  final String nominatimCode;
  final double defaultLat;
  final double defaultLng;
  final bool needsApiKey;
  final String? apiKeyRegisterUrl;
  /// `station` = per-pump prices; `national` = country-wide average only.
  final String pricingMode;
  final List<FuelCity> cities;

  const FuelCountry({
    required this.code,
    required this.nameEn,
    required this.nameFa,
    required this.nameDe,
    required this.currency,
    required this.nominatimCode,
    required this.defaultLat,
    required this.defaultLng,
    this.needsApiKey = false,
    this.apiKeyRegisterUrl,
    this.pricingMode = 'station',
    required this.cities,
  });

  String displayName(String lang) {
    if (lang == 'fa') return nameFa;
    if (lang == 'de') return nameDe;
    return nameEn;
  }

  String get flagEmoji {
    switch (code.toUpperCase()) {
      case 'DE':
        return '🇩🇪';
      case 'AT':
        return '🇦🇹';
      case 'FR':
        return '🇫🇷';
      case 'ES':
        return '🇪🇸';
      case 'IT':
        return '🇮🇹';
      case 'UK':
      case 'GB':
        return '🇬🇧';
      case 'AU':
        return '🇦🇺';
      case 'PT':
        return '🇵🇹';
      case 'BE':
        return '🇧🇪';
      case 'NL':
        return '🇳🇱';
      case 'LU':
        return '🇱🇺';
      case 'IE':
        return '🇮🇪';
      case 'PL':
        return '🇵🇱';
      case 'CZ':
        return '🇨🇿';
      case 'SI':
        return '🇸🇮';
      case 'HR':
        return '🇭🇷';
      case 'GR':
        return '🇬🇷';
      case 'CH':
        return '🇨🇭';
      case 'NO':
        return '🇳🇴';
      case 'SE':
        return '🇸🇪';
      case 'DK':
        return '🇩🇰';
      case 'BR':
        return '🇧🇷';
      case 'CA':
        return '🇨🇦';
      case 'SA':
        return '🇸🇦';
      case 'AE':
        return '🇦🇪';
      case 'CN':
        return '🇨🇳';
      case 'US':
        return '🇺🇸';
      case 'IN':
        return '🇮🇳';
      default:
        return '🏳️';
    }
  }

  String get currencySymbol {
    return currencySymbolForCode(currency);
  }
}

/// Internal keys stay `diesel|e10|e5|e5_98` for API mapping; labels are local.
class FuelGrade {
  final String key;
  final String labelEn;
  final String labelFa;
  final String labelDe;

  const FuelGrade({
    required this.key,
    required this.labelEn,
    required this.labelFa,
    required this.labelDe,
  });

  String label(String lang) {
    if (lang == 'fa') return labelFa;
    if (lang == 'de') return labelDe;
    return labelEn;
  }
}

const _gradeDiesel = FuelGrade(
  key: 'diesel',
  labelEn: 'Diesel',
  labelFa: 'دیزل',
  labelDe: 'Diesel',
);
const _gradeE10 = FuelGrade(
  key: 'e10',
  labelEn: 'E10',
  labelFa: 'E10',
  labelDe: 'E10',
);
const _gradeE5 = FuelGrade(
  key: 'e5',
  labelEn: 'E5',
  labelFa: 'E5',
  labelDe: 'E5',
);

/// Country-specific pump grades shown in the fuel dropdown (EV/parking added in UI).
List<FuelGrade> fuelGradesForCountry(String code) {
  switch (code.trim().toLowerCase()) {
    case 'ae':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Diesel',
          labelFa: 'دیزل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'E-Plus 91',
          labelFa: 'ای‌پلاس ۹۱',
          labelDe: 'E-Plus 91',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Special 95',
          labelFa: 'اسپشیال ۹۵',
          labelDe: 'Special 95',
        ),
        FuelGrade(
          key: 'e5_98',
          labelEn: 'Super 98',
          labelFa: 'سوپر ۹۸',
          labelDe: 'Super 98',
        ),
      ];
    case 'sa':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Diesel',
          labelFa: 'دیزل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'Gasoline 91',
          labelFa: 'بنزین ۹۱',
          labelDe: 'Benzin 91',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Gasoline 95',
          labelFa: 'بنزین ۹۵',
          labelDe: 'Benzin 95',
        ),
        FuelGrade(
          key: 'e5_98',
          labelEn: 'Gasoline 98',
          labelFa: 'بنزین ۹۸',
          labelDe: 'Benzin 98',
        ),
      ];
    case 'cn':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Diesel',
          labelFa: 'دیزل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'Gasoline #92',
          labelFa: 'بنزین ۹۲#',
          labelDe: 'Benzin 92#',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Gasoline #95',
          labelFa: 'بنزین ۹۵#',
          labelDe: 'Benzin 95#',
        ),
      ];
    case 'us':
    case 'ca':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Regular',
          labelFa: 'معمولی (Regular)',
          labelDe: 'Regular',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Premium',
          labelFa: 'پرمیوم',
          labelDe: 'Premium',
        ),
      ];
    case 'uk':
    case 'gb':
    case 'ie':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Unleaded (E10)',
          labelFa: 'بنزین بدون سرب (E10)',
          labelDe: 'Super E10',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Super Unleaded',
          labelFa: 'سوپر بدون سرب',
          labelDe: 'Super Plus',
        ),
      ];
    case 'fr':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Gazole',
          labelFa: 'گازوئیل (Gazole)',
          labelDe: 'Diesel (Gazole)',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'SP95-E10',
          labelFa: 'بنزین SP95-E10',
          labelDe: 'SP95-E10',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'SP98',
          labelFa: 'بنزین SP98',
          labelDe: 'SP98',
        ),
      ];
    case 'es':
    case 'pt':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Gasóleo',
          labelFa: 'گازوئیل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'Gasolina 95',
          labelFa: 'بنزین ۹۵',
          labelDe: 'Benzin 95',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Gasolina 98',
          labelFa: 'بنزین ۹۸',
          labelDe: 'Benzin 98',
        ),
      ];
    case 'it':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Gasolio',
          labelFa: 'گازوئیل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'Benzina E10',
          labelFa: 'بنزین E10',
          labelDe: 'Benzin E10',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Benzina',
          labelFa: 'بنزین',
          labelDe: 'Benzin',
        ),
      ];
    case 'be':
    case 'nl':
    case 'lu':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Euro 95 (E10)',
          labelFa: 'یورو ۹۵ (E10)',
          labelDe: 'Euro 95 (E10)',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Euro 98',
          labelFa: 'یورو ۹۸',
          labelDe: 'Euro 98',
        ),
      ];
    case 'au':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Unleaded 91 / E10',
          labelFa: 'بدون سرب ۹۱ / E10',
          labelDe: 'Super 91 / E10',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Premium 95/98',
          labelFa: 'پرمیوم ۹۵/۹۸',
          labelDe: 'Premium 95/98',
        ),
      ];
    case 'in':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Petrol',
          labelFa: 'بنزین (Petrol)',
          labelDe: 'Benzin',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Premium Petrol',
          labelFa: 'بنزین پرمیوم',
          labelDe: 'Premium-Benzin',
        ),
      ];
    case 'br':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Gasolina',
          labelFa: 'بنزین',
          labelDe: 'Benzin',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Etanol',
          labelFa: 'اتانول',
          labelDe: 'Ethanol',
        ),
      ];
    case 'pl':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'ON (Diesel)',
          labelFa: 'دیزل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'Pb95',
          labelFa: 'بنزین ۹۵',
          labelDe: 'Benzin 95',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Pb98',
          labelFa: 'بنزین ۹۸',
          labelDe: 'Benzin 98',
        ),
      ];
    case 'cz':
      return const [
        FuelGrade(
          key: 'diesel',
          labelEn: 'Nafta',
          labelFa: 'دیزل',
          labelDe: 'Diesel',
        ),
        FuelGrade(
          key: 'e10',
          labelEn: 'Natural 95',
          labelFa: 'بنزین ۹۵',
          labelDe: 'Benzin 95',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Natural 98',
          labelFa: 'بنزین ۹۸',
          labelDe: 'Benzin 98',
        ),
      ];
    case 'no':
    case 'se':
    case 'dk':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Bensin 95',
          labelFa: 'بنزین ۹۵',
          labelDe: 'Benzin 95',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Bensin 98',
          labelFa: 'بنزین ۹۸',
          labelDe: 'Benzin 98',
        ),
      ];
    case 'gr':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Unleaded 95',
          labelFa: 'بدون سرب ۹۵',
          labelDe: 'Super 95',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Super 100',
          labelFa: 'سوپر ۱۰۰',
          labelDe: 'Super 100',
        ),
      ];
    case 'si':
    case 'hr':
      return const [
        _gradeDiesel,
        FuelGrade(
          key: 'e10',
          labelEn: 'Super 95',
          labelFa: 'سوپر ۹۵',
          labelDe: 'Super 95',
        ),
        FuelGrade(
          key: 'e5',
          labelEn: 'Super 98',
          labelFa: 'سوپر ۹۸',
          labelDe: 'Super 98',
        ),
      ];
    case 'de':
    case 'at':
    case 'ch':
    default:
      return const [_gradeDiesel, _gradeE10, _gradeE5];
  }
}

/// Remap saved fuel key when entering a country that does not offer it.
String normalizeFuelTypeForCountry(String fuelType, String countryCode) {
  if (fuelType == 'ev' || fuelType == 'parking') return fuelType;
  final grades = fuelGradesForCountry(countryCode);
  if (grades.any((g) => g.key == fuelType)) return fuelType;
  if (fuelType == 'e5_98') {
    final e5 = grades.where((g) => g.key == 'e5');
    if (e5.isNotEmpty) return e5.first.key;
  }
  return grades.isNotEmpty ? grades.first.key : 'diesel';
}

/// How map prices should be explained to the user (not live per-pump).
enum FuelPriceScope {
  station,
  nationalAverage,
  monthlyOfficial,
  fixedOfficial,
  provincial,
  crowdOrAverage,
}

FuelPriceScope fuelPriceScopeFor(String countryCode) {
  switch (countryCode.trim().toLowerCase()) {
    case 'ae':
      return FuelPriceScope.monthlyOfficial;
    case 'sa':
      return FuelPriceScope.fixedOfficial;
    case 'cn':
    case 'ca':
      return FuelPriceScope.provincial;
    case 'us':
    case 'in':
      return FuelPriceScope.crowdOrAverage;
    case 'ie':
    case 'pl':
    case 'cz':
    case 'gr':
    case 'ch':
    case 'no':
    case 'se':
    case 'dk':
    case 'br':
      return FuelPriceScope.nationalAverage;
    default:
      // Germany + most EU station APIs
      return FuelPriceScope.station;
  }
}

/// Volume unit used for displayed pump prices.
enum FuelVolumeUnit { liter, usGallon }

FuelVolumeUnit fuelVolumeUnitFor(String countryCode) {
  switch (countryCode.trim().toLowerCase()) {
    case 'us':
      return FuelVolumeUnit.usGallon;
    default:
      return FuelVolumeUnit.liter;
  }
}

String fuelVolumeUnitTranslationKey(String countryCode) {
  return fuelVolumeUnitFor(countryCode) == FuelVolumeUnit.usGallon
      ? 'price_unit_gallon'
      : 'price_unit_liter';
}

String currencySymbolForCode(String currency) {
  switch (currency.toUpperCase()) {
    case 'GBP':
      return '£';
    case 'AUD':
      return 'A\$';
    case 'USD':
      return '\$';
    case 'CAD':
      return 'C\$';
    case 'CHF':
      return 'CHF ';
    case 'PLN':
      return 'zł';
    case 'CZK':
      return 'Kč';
    case 'SEK':
    case 'NOK':
    case 'DKK':
      return 'kr';
    case 'HUF':
      return 'Ft';
    case 'RON':
      return 'lei';
    case 'BRL':
      return 'R\$';
    case 'SAR':
      return '﷼';
    case 'AED':
      return 'د.إ';
    case 'CNY':
      return '¥';
    case 'INR':
      return '₹';
    case 'EUR':
    default:
      return '€';
  }
}

/// Parse a station price that may be num or string (optionally with currency).
double? parseFuelPriceValue(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  final match = RegExp(r'[-+]?\d+[.,]?\d*').firstMatch(s);
  if (match == null) return null;
  return double.tryParse(match.group(0)!.replaceAll(',', '.'));
}

/// Local currency + exactly 2 decimal places, with volume unit:
/// e.g. €1.89/L (DE/EU/CA) or $3.25/gal (USA).
String formatFuelPrice(
  dynamic raw, {
  String? countryCode,
  String? currencyCode,
  bool includeUnit = true,
}) {
  final value = parseFuelPriceValue(raw);
  if (value == null || value <= 0) return '—';
  final cc = (countryCode ?? '').trim().toLowerCase();
  final code = (currencyCode ??
          countryByCode(cc)?.currency ??
          'EUR')
      .toUpperCase();
  final money = '${currencySymbolForCode(code)}${value.toStringAsFixed(2)}';
  if (!includeUnit) return money;
  final unit =
      fuelVolumeUnitFor(cc) == FuelVolumeUnit.usGallon ? '/gal' : '/L';
  return '$money$unit';
}

String currencyLabelForCountry(String? countryCode) {
  return countryByCode(countryCode ?? '')?.currency ?? 'EUR';
}

/// Short unit suffix for list/map captions: `/L` or `/gal`.
String fuelUnitSuffixForCountry(String? countryCode) {
  return fuelVolumeUnitFor(countryCode ?? '') == FuelVolumeUnit.usGallon
      ? '/gal'
      : '/L';
}

String foldQuery(String input) {
  var s = input.trim().toLowerCase();
  const map = {
    'ä': 'a',
    'ö': 'o',
    'ü': 'u',
    'ß': 'ss',
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'å': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'ñ': 'n',
    'ç': 'c',
    'ś': 's',
    'ł': 'l',
    'ż': 'z',
    'ź': 'z',
    'ć': 'c',
    'ń': 'n',
  };
  final buf = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    buf.write(map[ch] ?? ch);
  }
  return buf.toString().replaceAll(RegExp(r'\s+'), ' ');
}

FuelCountry? countryByCode(String code) {
  final c = code.trim().toLowerCase();
  if (c == 'gb') {
    for (final country in supportedFuelCountries) {
      if (country.code == 'uk') return country;
    }
  }
  for (final country in supportedFuelCountries) {
    if (country.code == c) return country;
  }
  return null;
}

List<Map<String, String>> matchCountryCities(
  String countryCode,
  String query, {
  int limit = 8,
}) {
  final country = countryByCode(countryCode);
  if (country == null) return [];
  return _scoreCities(country, query)
      .take(limit)
      .map((e) => _cityToPlace(e.value, country))
      .toList();
}

/// Search cities across all supported countries (Paris/Wien work even if UI is on DE).
List<Map<String, String>> matchAllCountriesCities(
  String query, {
  int limit = 8,
  String? preferCountryCode,
}) {
  final q = foldQuery(query);
  if (q.isEmpty) return [];

  final scored = <MapEntry<int, MapEntry<FuelCountry, FuelCity>>>[];
  for (final country in supportedFuelCountries) {
    for (final entry in _scoreCities(country, query)) {
      var score = entry.key;
      if (preferCountryCode != null &&
          country.code == preferCountryCode.toLowerCase()) {
        score += 5; // slight preference for currently selected country
      }
      scored.add(MapEntry(score, MapEntry(country, entry.value)));
    }
  }
  scored.sort((a, b) => b.key.compareTo(a.key));
  return scored.take(limit).map((e) {
    final country = e.value.key;
    final city = e.value.value;
    return _cityToPlace(city, country);
  }).toList();
}

List<MapEntry<int, FuelCity>> _scoreCities(FuelCountry country, String query) {
  final q = foldQuery(query);
  if (q.isEmpty) return [];
  final scored = <MapEntry<int, FuelCity>>[];
  for (final city in country.cities) {
    final names = [city.display, ...city.aliases];
    int best = 0;
    for (final name in names) {
      final folded = foldQuery(name);
      if (folded.isEmpty) continue;
      if (folded == q) {
        best = 100;
        break;
      }
      if (q.length >= 2 && folded.startsWith(q)) {
        best = best < 80 ? 80 : best;
      } else if (q.length >= 3 && folded.contains(q)) {
        best = best < 50 ? 50 : best;
      }
    }
    if (best > 0) scored.add(MapEntry(best, city));
  }
  scored.sort((a, b) => b.key.compareTo(a.key));
  return scored;
}

/// True when query exactly matches a known city name/alias (e.g. LA, NY, پکن).
bool hasStrongCityMatch(String query) {
  final q = foldQuery(query);
  if (q.length < 2) return false;
  for (final country in supportedFuelCountries) {
    for (final entry in _scoreCities(country, query)) {
      if (entry.key >= 80) return true;
    }
  }
  return false;
}

Map<String, String> _cityToPlace(FuelCity city, FuelCountry country) {
  return <String, String>{
    'display_name': '${city.display}, ${country.nameEn}',
    'lat': city.lat.toString(),
    'lon': city.lng.toString(),
    'country_code': country.code,
  };
}

/// Rough country detection from map center for multi-country fuel/EV loads.
String? detectCountryCodeFromLatLng(double lat, double lng) {
  bool inBox(double minLat, double maxLat, double minLng, double maxLng) =>
      lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;

  // Tiny / specific regions first.
  if (inBox(49.40, 50.25, 5.70, 6.55)) return 'lu';
  if (inBox(45.80, 47.85, 5.90, 10.55)) return 'ch';
  if (inBox(45.40, 46.90, 13.35, 16.65)) return 'si';
  if (inBox(46.35, 49.05, 9.45, 17.25)) return 'at';
  if (inBox(42.30, 46.60, 13.40, 19.50)) return 'hr';
  if (inBox(51.30, 55.50, -10.60, -5.90)) return 'ie';
  if (inBox(49.80, 60.95, -8.70, 2.00)) return 'uk';
  if (inBox(54.50, 57.80, 8.00, 15.20)) return 'dk';
  if (inBox(49.45, 51.55, 2.50, 6.45)) return 'be';
  if (inBox(50.70, 53.60, 3.30, 7.30)) return 'nl';
  if (inBox(36.90, 42.20, -9.60, -6.10)) return 'pt';
  if (inBox(35.90, 43.85, -9.50, 4.50)) return 'es';
  if (inBox(34.80, 41.80, 19.30, 29.70)) return 'gr';
  if (inBox(36.55, 47.15, 6.55, 18.60)) return 'it';
  if (inBox(48.50, 51.10, 12.00, 18.90)) return 'cz';
  if (inBox(49.00, 54.90, 14.10, 24.20)) return 'pl';
  if (inBox(55.20, 69.10, 10.90, 24.20)) return 'se';
  if (inBox(57.90, 71.20, 4.50, 31.50)) return 'no';
  // Gulf / Asia / Americas
  if (inBox(22.6, 26.1, 51.5, 56.5)) return 'ae';
  if (inBox(16.0, 32.5, 34.5, 55.7)) return 'sa';
  if (inBox(6.5, 35.7, 68.0, 97.5)) return 'in';
  if (inBox(18.0, 53.6, 73.5, 135.1)) return 'cn';
  // Toronto / GTA / southern Ontario — before contiguous US (same bbox otherwise).
  if (inBox(43.0, 46.6, -81.5, -74.0)) return 'ca';
  // Southern Quebec (Montréal …) — before contiguous US.
  if (inBox(45.0, 50.5, -74.6, -63.0)) return 'ca';
  // Contiguous USA (south of 49th parallel)
  if (inBox(24.5, 49.0, -125.0, -66.9)) return 'us';
  // Alaska
  if (inBox(51.0, 71.5, -179.0, -129.0)) return 'us';
  // Hawaii
  if (inBox(18.5, 22.5, -160.5, -154.5)) return 'us';
  if (inBox(-34.0, 5.5, -74.0, -34.0)) return 'br';
  // Rest of Canada (after US carve-out)
  if (inBox(41.7, 83.2, -141.0, -52.0)) return 'ca';
  if (inBox(-44.0, -10.0, 112.0, 154.0)) return 'au';
  // France west of Rhine belt; Germany east.
  if (inBox(41.3, 51.15, -5.2, 8.2)) return 'fr';
  if (inBox(47.2, 55.15, 5.8, 15.1)) return 'de';
  if (inBox(41.3, 51.2, -5.2, 9.6)) return 'fr';
  return null;
}

const List<FuelCountry> supportedFuelCountries = [
  FuelCountry(
    code: 'de',
    nameEn: 'Germany',
    nameFa: 'آلمان',
    nameDe: 'Deutschland',
    currency: 'EUR',
    nominatimCode: 'de',
    defaultLat: 52.5200,
    defaultLng: 13.4050,
    cities: [
      FuelCity(display: 'Berlin', lat: 52.5200, lng: 13.4050, aliases: ['برلین', 'Berlin']),
      FuelCity(display: 'Hamburg', lat: 53.5511, lng: 9.9937, aliases: ['هامبورگ', 'Hamburg']),
      FuelCity(display: 'München', lat: 48.1351, lng: 11.5820, aliases: ['Munich', 'مونیخ', 'Muenchen']),
      FuelCity(display: 'Köln', lat: 50.9375, lng: 6.9603, aliases: ['Cologne', 'کلن', 'Koeln']),
      FuelCity(display: 'Frankfurt', lat: 50.1109, lng: 8.6821, aliases: ['Frankfurt am Main', 'فرانکفورت']),
      FuelCity(display: 'Stuttgart', lat: 48.7758, lng: 9.1829, aliases: ['اشتوتگارت']),
      FuelCity(display: 'Düsseldorf', lat: 51.2277, lng: 6.7735, aliases: ['Dusseldorf', 'دوسلدورف']),
      FuelCity(display: 'Dortmund', lat: 51.5136, lng: 7.4653, aliases: ['دورتموند']),
      FuelCity(display: 'Essen', lat: 51.4556, lng: 7.0116, aliases: ['اسن']),
      FuelCity(display: 'Leipzig', lat: 51.3397, lng: 12.3731, aliases: ['لایپزیگ']),
      FuelCity(display: 'Bremen', lat: 53.0793, lng: 8.8017, aliases: ['برمن']),
      FuelCity(display: 'Dresden', lat: 51.0504, lng: 13.7373, aliases: ['درسدن']),
      FuelCity(display: 'Hannover', lat: 52.3759, lng: 9.7320, aliases: ['Hanover', 'هانوفر']),
      FuelCity(display: 'Nürnberg', lat: 49.4521, lng: 11.0767, aliases: ['Nuremberg', 'نورنبرگ', 'Nuernberg']),
      FuelCity(display: 'Duisburg', lat: 51.4344, lng: 6.7623, aliases: ['دویسبورگ']),
      FuelCity(display: 'Bochum', lat: 51.4818, lng: 7.2162, aliases: ['بوchum']),
      FuelCity(display: 'Wuppertal', lat: 51.2562, lng: 7.1508, aliases: ['ووپرتال']),
      FuelCity(display: 'Bielefeld', lat: 52.0302, lng: 8.5325, aliases: ['بیله‌فلد']),
      FuelCity(display: 'Bonn', lat: 50.7374, lng: 7.0982, aliases: ['بن']),
      FuelCity(display: 'Münster', lat: 51.9607, lng: 7.6261, aliases: ['Munster', 'مونستر']),
      FuelCity(display: 'Karlsruhe', lat: 49.0069, lng: 8.4037, aliases: ['کارلسروهه']),
      FuelCity(display: 'Mannheim', lat: 49.4875, lng: 8.4660, aliases: ['مانهایم']),
      FuelCity(display: 'Augsburg', lat: 48.3705, lng: 10.8978, aliases: ['آگسبورگ']),
      FuelCity(display: 'Wiesbaden', lat: 50.0782, lng: 8.2398, aliases: ['ویسبادن']),
      FuelCity(display: 'Freiburg', lat: 47.9990, lng: 7.8421, aliases: ['فرایبورگ']),
      FuelCity(display: 'Erfurt', lat: 50.9848, lng: 11.0299, aliases: ['ارفورت']),
      FuelCity(display: 'Rostock', lat: 54.0924, lng: 12.0991, aliases: ['روستوک']),
      FuelCity(display: 'Kassel', lat: 51.3127, lng: 9.4797, aliases: ['کاسل']),
      FuelCity(display: 'Mainz', lat: 49.9929, lng: 8.2473, aliases: ['ماینتس']),
      FuelCity(display: 'Kiel', lat: 54.3233, lng: 10.1228, aliases: ['کیل']),
    ],
  ),
  FuelCountry(
    code: 'at',
    nameEn: 'Austria',
    nameFa: 'اتریش',
    nameDe: 'Österreich',
    currency: 'EUR',
    nominatimCode: 'at',
    defaultLat: 48.2082,
    defaultLng: 16.3738,
    cities: [
      FuelCity(display: 'Wien', lat: 48.2082, lng: 16.3738, aliases: ['Vienna', 'وین']),
      FuelCity(display: 'Graz', lat: 47.0707, lng: 15.4395, aliases: ['گراتس']),
      FuelCity(display: 'Linz', lat: 48.3069, lng: 14.2858, aliases: ['لینتس']),
      FuelCity(display: 'Salzburg', lat: 47.8095, lng: 13.0550, aliases: ['سالزبورگ']),
      FuelCity(display: 'Innsbruck', lat: 47.2692, lng: 11.4041, aliases: ['اینسبروک']),
      FuelCity(display: 'Klagenfurt', lat: 46.6247, lng: 14.3053, aliases: ['کلاگنفورت']),
      FuelCity(display: 'Villach', lat: 46.6111, lng: 13.8558, aliases: ['فیلاخ']),
      FuelCity(display: 'Wels', lat: 48.1575, lng: 14.0289, aliases: ['ولس']),
      FuelCity(display: 'Sankt Pölten', lat: 48.2047, lng: 15.6256, aliases: ['St. Pölten', 'سنت پولتن']),
      FuelCity(display: 'Dornbirn', lat: 47.4125, lng: 9.7417, aliases: ['دورنبیرن']),
      FuelCity(display: 'Wiener Neustadt', lat: 47.8156, lng: 16.2450, aliases: ['ویینر نوی‌اشتات']),
      FuelCity(display: 'Steyr', lat: 48.0428, lng: 14.4214, aliases: ['اشتایر']),
      FuelCity(display: 'Feldkirch', lat: 47.2381, lng: 9.5981, aliases: ['فلدکیرش']),
      FuelCity(display: 'Bregenz', lat: 47.5031, lng: 9.7471, aliases: ['برگنتس']),
      FuelCity(display: 'Leonding', lat: 48.2764, lng: 14.2531, aliases: ['لئوندینگ']),
      FuelCity(display: 'Klosterneuburg', lat: 48.3056, lng: 16.3256, aliases: ['کلسترنویبورگ']),
      FuelCity(display: 'Baden', lat: 48.0021, lng: 16.2308, aliases: ['بادن']),
      FuelCity(display: 'Wolfsberg', lat: 46.8406, lng: 14.8442, aliases: ['ولفسببرگ']),
      FuelCity(display: 'Leoben', lat: 47.3833, lng: 15.1000, aliases: ['لئوبن']),
      FuelCity(display: 'Krems', lat: 48.4097, lng: 15.6039, aliases: ['کرمس']),
    ],
  ),
  FuelCountry(
    code: 'fr',
    nameEn: 'France',
    nameFa: 'فرانسه',
    nameDe: 'Frankreich',
    currency: 'EUR',
    nominatimCode: 'fr',
    defaultLat: 48.8566,
    defaultLng: 2.3522,
    cities: [
      FuelCity(display: 'Paris', lat: 48.8566, lng: 2.3522, aliases: ['پاریس']),
      FuelCity(display: 'Lyon', lat: 45.7640, lng: 4.8357, aliases: ['لیون']),
      FuelCity(display: 'Marseille', lat: 43.2965, lng: 5.3698, aliases: ['مارسی']),
      FuelCity(display: 'Toulouse', lat: 43.6047, lng: 1.4442, aliases: ['تولوز']),
      FuelCity(display: 'Nice', lat: 43.7102, lng: 7.2620, aliases: ['نیس']),
      FuelCity(display: 'Bordeaux', lat: 44.8378, lng: -0.5792, aliases: ['بوردو']),
      FuelCity(display: 'Nantes', lat: 47.2184, lng: -1.5536, aliases: ['نانت']),
      FuelCity(display: 'Strasbourg', lat: 48.5734, lng: 7.7521, aliases: ['استراسبورگ']),
      FuelCity(display: 'Lille', lat: 50.6292, lng: 3.0573, aliases: ['لیل']),
      FuelCity(display: 'Rennes', lat: 48.1173, lng: -1.6778, aliases: ['رن']),
      FuelCity(display: 'Reims', lat: 49.2583, lng: 4.0317, aliases: ['رنس']),
      FuelCity(display: 'Saint-Étienne', lat: 45.4397, lng: 4.3872, aliases: ['Saint Etienne', 'سنت اتین']),
      FuelCity(display: 'Le Havre', lat: 49.4944, lng: 0.1079, aliases: ['لو هاور']),
      FuelCity(display: 'Toulon', lat: 43.1242, lng: 5.9280, aliases: ['تولون']),
      FuelCity(display: 'Grenoble', lat: 45.1885, lng: 5.7245, aliases: ['گرونوبل']),
      FuelCity(display: 'Dijon', lat: 47.3220, lng: 5.0415, aliases: ['دیژون']),
      FuelCity(display: 'Angers', lat: 47.4784, lng: -0.5632, aliases: ['آنژه']),
      FuelCity(display: 'Nîmes', lat: 43.8367, lng: 4.3601, aliases: ['Nimes', 'نیم']),
      FuelCity(display: 'Villeurbanne', lat: 45.7719, lng: 4.8902, aliases: ['ویوربان']),
      FuelCity(display: 'Clermont-Ferrand', lat: 45.7772, lng: 3.0870, aliases: ['کلرمون فران']),
      FuelCity(display: 'Le Mans', lat: 48.0061, lng: 0.1996, aliases: ['لو مان']),
      FuelCity(display: 'Aix-en-Provence', lat: 43.5297, lng: 5.4474, aliases: ['اکس ان پرووانس']),
      FuelCity(display: 'Brest', lat: 48.3905, lng: -4.4860, aliases: ['برست']),
      FuelCity(display: 'Tours', lat: 47.3941, lng: 0.6848, aliases: ['تور']),
      FuelCity(display: 'Amiens', lat: 49.8941, lng: 2.2958, aliases: ['آمیان']),
      FuelCity(display: 'Limoges', lat: 45.8336, lng: 1.2611, aliases: ['لیموژ']),
      FuelCity(display: 'Perpignan', lat: 42.6887, lng: 2.8948, aliases: ['پرپینان']),
      FuelCity(display: 'Metz', lat: 49.1193, lng: 6.1757, aliases: ['متس']),
      FuelCity(display: 'Besançon', lat: 47.2378, lng: 6.0241, aliases: ['Besancon', 'بزانسون']),
      FuelCity(display: 'Orléans', lat: 47.9029, lng: 1.9093, aliases: ['Orleans', 'اورلئان']),
    ],
  ),
  FuelCountry(
    code: 'es',
    nameEn: 'Spain',
    nameFa: 'اسپانیا',
    nameDe: 'Spanien',
    currency: 'EUR',
    nominatimCode: 'es',
    defaultLat: 40.4168,
    defaultLng: -3.7038,
    cities: [
      FuelCity(display: 'Madrid', lat: 40.4168, lng: -3.7038, aliases: ['مادرید']),
      FuelCity(display: 'Barcelona', lat: 41.3874, lng: 2.1686, aliases: ['بارسلونا']),
      FuelCity(display: 'Valencia', lat: 39.4699, lng: -0.3763, aliases: ['والنسیا']),
      FuelCity(display: 'Sevilla', lat: 37.3891, lng: -5.9845, aliases: ['Seville', 'سویا']),
      FuelCity(display: 'Zaragoza', lat: 41.6488, lng: -0.8891, aliases: ['ساراگوسا']),
      FuelCity(display: 'Málaga', lat: 36.7213, lng: -4.4214, aliases: ['Malaga', 'مالاگا']),
      FuelCity(display: 'Murcia', lat: 37.9922, lng: -1.1307, aliases: ['مورسیا']),
      FuelCity(display: 'Palma', lat: 39.5696, lng: 2.6502, aliases: ['Palma de Mallorca', 'پالما']),
      FuelCity(display: 'Las Palmas', lat: 28.1235, lng: -15.4363, aliases: ['لاس پالماس']),
      FuelCity(display: 'Bilbao', lat: 43.2630, lng: -2.9350, aliases: ['بیلبائو']),
      FuelCity(display: 'Alicante', lat: 38.3452, lng: -0.4810, aliases: ['آلیکانته']),
      FuelCity(display: 'Córdoba', lat: 37.8882, lng: -4.7794, aliases: ['Cordoba', 'کوردوبا']),
      FuelCity(display: 'Valladolid', lat: 41.6523, lng: -4.7245, aliases: ['وایادولید']),
      FuelCity(display: 'Vigo', lat: 42.2406, lng: -8.7207, aliases: ['ویگو']),
      FuelCity(display: 'Gijón', lat: 43.5322, lng: -5.6611, aliases: ['Gijon', 'خیخون']),
      FuelCity(display: 'Hospitalet', lat: 41.3597, lng: 2.0997, aliases: ["L'Hospitalet", 'هوسپیتالت']),
      FuelCity(display: 'Vitoria-Gasteiz', lat: 42.8467, lng: -2.6716, aliases: ['Vitoria', 'ویتوریا']),
      FuelCity(display: 'A Coruña', lat: 43.3623, lng: -8.4115, aliases: ['La Coruna', 'لاکورونیا']),
      FuelCity(display: 'Granada', lat: 37.1773, lng: -3.5986, aliases: ['گرانادا']),
      FuelCity(display: 'Elche', lat: 38.2699, lng: -0.6980, aliases: ['الچه']),
      FuelCity(display: 'Oviedo', lat: 43.3614, lng: -5.8593, aliases: ['اوویiedo']),
      FuelCity(display: 'Badalona', lat: 41.4469, lng: 2.2450, aliases: ['بادلونا']),
      FuelCity(display: 'Cartagena', lat: 37.6257, lng: -0.9966, aliases: ['کارتاخنا']),
      FuelCity(display: 'Terrassa', lat: 41.5631, lng: 2.0089, aliases: ['تراسا']),
      FuelCity(display: 'Jerez', lat: 36.6866, lng: -6.1372, aliases: ['Jerez de la Frontera', 'خرس']),
      FuelCity(display: 'Sabadell', lat: 41.5463, lng: 2.1074, aliases: ['سابادل']),
      FuelCity(display: 'Móstoles', lat: 40.3228, lng: -3.8649, aliases: ['Mostoles', 'موستولس']),
      FuelCity(display: 'Alcalá de Henares', lat: 40.4818, lng: -3.3635, aliases: ['Alcala', 'آلکالا']),
      FuelCity(display: 'Pamplona', lat: 42.8125, lng: -1.6458, aliases: ['پامپلونا']),
      FuelCity(display: 'Fuenlabrada', lat: 40.2842, lng: -3.7949, aliases: ['فوئنلابرادا']),
    ],
  ),
  FuelCountry(
    code: 'it',
    nameEn: 'Italy',
    nameFa: 'ایتالیا',
    nameDe: 'Italien',
    currency: 'EUR',
    nominatimCode: 'it',
    defaultLat: 41.9028,
    defaultLng: 12.4964,
    cities: [
      FuelCity(display: 'Roma', lat: 41.9028, lng: 12.4964, aliases: ['Rome', 'رم']),
      FuelCity(display: 'Milano', lat: 45.4642, lng: 9.1900, aliases: ['Milan', 'میلان']),
      FuelCity(display: 'Napoli', lat: 40.8518, lng: 14.2681, aliases: ['Naples', 'ناپل']),
      FuelCity(display: 'Torino', lat: 45.0703, lng: 7.6869, aliases: ['Turin', 'تورین']),
      FuelCity(display: 'Palermo', lat: 38.1157, lng: 13.3615, aliases: ['پالرمو']),
      FuelCity(display: 'Genova', lat: 44.4056, lng: 8.9463, aliases: ['Genoa', 'جنوا']),
      FuelCity(display: 'Bologna', lat: 44.4949, lng: 11.3426, aliases: ['بولونیا']),
      FuelCity(display: 'Firenze', lat: 43.7696, lng: 11.2558, aliases: ['Florence', 'فلورانس']),
      FuelCity(display: 'Bari', lat: 41.1171, lng: 16.8719, aliases: ['باری']),
      FuelCity(display: 'Catania', lat: 37.5079, lng: 15.0830, aliases: ['کاتانیا']),
      FuelCity(display: 'Venezia', lat: 45.4408, lng: 12.3155, aliases: ['Venice', 'ونیز']),
      FuelCity(display: 'Verona', lat: 45.4384, lng: 10.9916, aliases: ['ورونا']),
      FuelCity(display: 'Messina', lat: 38.1938, lng: 15.5540, aliases: ['مسینا']),
      FuelCity(display: 'Padova', lat: 45.4064, lng: 11.8768, aliases: ['Padua', 'پادوا']),
      FuelCity(display: 'Trieste', lat: 45.6495, lng: 13.7768, aliases: ['تریسته']),
      FuelCity(display: 'Brescia', lat: 45.5416, lng: 10.2118, aliases: ['برشا']),
      FuelCity(display: 'Parma', lat: 44.8015, lng: 10.3279, aliases: ['پارما']),
      FuelCity(display: 'Taranto', lat: 40.4644, lng: 17.2470, aliases: ['تارانتو']),
      FuelCity(display: 'Prato', lat: 43.8777, lng: 11.1023, aliases: ['پراتو']),
      FuelCity(display: 'Modena', lat: 44.6471, lng: 10.9252, aliases: ['مودنا']),
      FuelCity(display: 'Reggio Calabria', lat: 38.1113, lng: 15.6473, aliases: ['رجیو کالابریا']),
      FuelCity(display: 'Reggio Emilia', lat: 44.6989, lng: 10.6297, aliases: ['رجیو امیلیا']),
      FuelCity(display: 'Perugia', lat: 43.1107, lng: 12.3908, aliases: ['پروجا']),
      FuelCity(display: 'Livorno', lat: 43.5485, lng: 10.3106, aliases: ['لیورنو']),
      FuelCity(display: 'Ravenna', lat: 44.4184, lng: 12.2035, aliases: ['راونا']),
      FuelCity(display: 'Cagliari', lat: 39.2238, lng: 9.1217, aliases: ['کالیاری']),
      FuelCity(display: 'Foggia', lat: 41.4622, lng: 15.5446, aliases: ['فوجا']),
      FuelCity(display: 'Rimini', lat: 44.0678, lng: 12.5695, aliases: ['ریمینی']),
      FuelCity(display: 'Salerno', lat: 40.6824, lng: 14.7681, aliases: ['سالرنو']),
      FuelCity(display: 'Ferrara', lat: 44.8381, lng: 11.6198, aliases: ['فرارا']),
    ],
  ),
  FuelCountry(
    code: 'uk',
    nameEn: 'United Kingdom',
    nameFa: 'بریتانیا',
    nameDe: 'Vereinigtes Königreich',
    currency: 'GBP',
    nominatimCode: 'gb',
    defaultLat: 51.5074,
    defaultLng: -0.1278,
    cities: [
      FuelCity(display: 'London', lat: 51.5074, lng: -0.1278, aliases: ['لندن']),
      FuelCity(display: 'Manchester', lat: 53.4808, lng: -2.2426, aliases: ['منچستر']),
      FuelCity(display: 'Birmingham', lat: 52.4862, lng: -1.8904, aliases: ['بیرمنگام']),
      FuelCity(display: 'Leeds', lat: 53.8008, lng: -1.5491, aliases: ['لیدز']),
      FuelCity(display: 'Glasgow', lat: 55.8642, lng: -4.2518, aliases: ['گلاسگو']),
      FuelCity(display: 'Edinburgh', lat: 55.9533, lng: -3.1883, aliases: ['ادینبرو']),
      FuelCity(display: 'Liverpool', lat: 53.4084, lng: -2.9916, aliases: ['لیورپول']),
      FuelCity(display: 'Bristol', lat: 51.4545, lng: -2.5879, aliases: ['بریستول']),
      FuelCity(display: 'Cardiff', lat: 51.4816, lng: -3.1791, aliases: ['کاردیف']),
      FuelCity(display: 'Belfast', lat: 54.5973, lng: -5.9301, aliases: ['بلفاست']),
      FuelCity(display: 'Sheffield', lat: 53.3811, lng: -1.4701, aliases: ['شفیلد']),
      FuelCity(display: 'Newcastle', lat: 54.9783, lng: -1.6178, aliases: ['Newcastle upon Tyne', 'نیوکاسل']),
      FuelCity(display: 'Nottingham', lat: 52.9548, lng: -1.1581, aliases: ['ناتینگهام']),
      FuelCity(display: 'Southampton', lat: 50.9097, lng: -1.4044, aliases: ['ساوتهمپتون']),
      FuelCity(display: 'Leicester', lat: 52.6369, lng: -1.1398, aliases: ['لستر']),
      FuelCity(display: 'Coventry', lat: 52.4068, lng: -1.5197, aliases: ['کاونتری']),
      FuelCity(display: 'Bradford', lat: 53.7960, lng: -1.7594, aliases: ['برادفورد']),
      FuelCity(display: 'Brighton', lat: 50.8225, lng: -0.1372, aliases: ['برایتون']),
      FuelCity(display: 'Hull', lat: 53.7676, lng: -0.3274, aliases: ['Kingston upon Hull', 'هال']),
      FuelCity(display: 'Plymouth', lat: 50.3755, lng: -4.1427, aliases: ['پلیموث']),
      FuelCity(display: 'Stoke-on-Trent', lat: 53.0027, lng: -2.1794, aliases: ['استوک']),
      FuelCity(display: 'Wolverhampton', lat: 52.5862, lng: -2.1288, aliases: ['ولورهمپتون']),
      FuelCity(display: 'Derby', lat: 52.9225, lng: -1.4746, aliases: ['دربی']),
      FuelCity(display: 'Swansea', lat: 51.6214, lng: -3.9436, aliases: ['سوانزی']),
      FuelCity(display: 'Aberdeen', lat: 57.1497, lng: -2.0943, aliases: ['آبردین']),
      FuelCity(display: 'Oxford', lat: 51.7520, lng: -1.2577, aliases: ['آکسفورد']),
      FuelCity(display: 'Cambridge', lat: 52.2053, lng: 0.1218, aliases: ['کمبریج']),
      FuelCity(display: 'Reading', lat: 51.4543, lng: -0.9781, aliases: ['ریدینگ']),
      FuelCity(display: 'Milton Keynes', lat: 52.0406, lng: -0.7594, aliases: ['میلتون کینز']),
      FuelCity(display: 'York', lat: 53.9591, lng: -1.0815, aliases: ['یورک']),
    ],
  ),
  FuelCountry(
    code: 'au',
    nameEn: 'Australia',
    nameFa: 'استرالیا',
    nameDe: 'Australien',
    currency: 'AUD',
    nominatimCode: 'au',
    defaultLat: -33.8688,
    defaultLng: 151.2093,
    needsApiKey: true,
    apiKeyRegisterUrl: 'https://api.nsw.gov.au/',
    cities: [
      FuelCity(display: 'Sydney', lat: -33.8688, lng: 151.2093, aliases: ['سیدنی']),
      FuelCity(display: 'Melbourne', lat: -37.8136, lng: 144.9631, aliases: ['ملبورن']),
      FuelCity(display: 'Brisbane', lat: -27.4698, lng: 153.0251, aliases: ['بریزبن']),
      FuelCity(display: 'Perth', lat: -31.9505, lng: 115.8605, aliases: ['پرت']),
      FuelCity(display: 'Adelaide', lat: -34.9285, lng: 138.6007, aliases: ['آدلاید']),
      FuelCity(display: 'Canberra', lat: -35.2809, lng: 149.1300, aliases: ['کانبرا']),
      FuelCity(display: 'Hobart', lat: -42.8821, lng: 147.3272, aliases: ['هوبارت']),
      FuelCity(display: 'Darwin', lat: -12.4634, lng: 130.8456, aliases: ['داروین']),
      FuelCity(display: 'Newcastle', lat: -32.9283, lng: 151.7817, aliases: ['نیوکاسل']),
      FuelCity(display: 'Gold Coast', lat: -28.0167, lng: 153.4000, aliases: ['گلد کوست']),
      FuelCity(display: 'Wollongong', lat: -34.4278, lng: 150.8931, aliases: ['وولونگونگ']),
      FuelCity(display: 'Geelong', lat: -38.1499, lng: 144.3617, aliases: ['جیلانگ']),
      FuelCity(display: 'Townsville', lat: -19.2590, lng: 146.8169, aliases: ['تاونزویل']),
      FuelCity(display: 'Cairns', lat: -16.9186, lng: 145.7781, aliases: ['کیرنز']),
      FuelCity(display: 'Toowoomba', lat: -27.5598, lng: 151.9507, aliases: ['توومبا']),
      FuelCity(display: 'Ballarat', lat: -37.5622, lng: 143.8503, aliases: ['بالارات']),
      FuelCity(display: 'Bendigo', lat: -36.7570, lng: 144.2794, aliases: ['بندایگو']),
      FuelCity(display: 'Albury', lat: -36.0737, lng: 146.9135, aliases: ['البوری']),
      FuelCity(display: 'Launceston', lat: -41.4332, lng: 147.1441, aliases: ['لانسستون']),
      FuelCity(display: 'Mackay', lat: -21.1411, lng: 149.1860, aliases: ['مکی']),
      FuelCity(display: 'Rockhampton', lat: -23.3781, lng: 150.5136, aliases: ['راکهمپتون']),
      FuelCity(display: 'Bunbury', lat: -33.3271, lng: 115.6414, aliases: ['بانبری']),
      FuelCity(display: 'Coffs Harbour', lat: -30.2963, lng: 153.1135, aliases: ['کافز هاربر']),
      FuelCity(display: 'Wagga Wagga', lat: -35.1082, lng: 147.3598, aliases: ['واگا واگا']),
      FuelCity(display: 'Hervey Bay', lat: -25.2882, lng: 152.7677, aliases: ['هروی بی']),
      FuelCity(display: 'Mildura', lat: -34.1855, lng: 142.1625, aliases: ['میلدورا']),
      FuelCity(display: 'Shepparton', lat: -36.3806, lng: 145.3980, aliases: ['شپارتون']),
      FuelCity(display: 'Port Macquarie', lat: -31.4333, lng: 152.9000, aliases: ['پورت مک‌کواری']),
      FuelCity(display: 'Gladstone', lat: -23.8485, lng: 151.2578, aliases: ['گلداستون']),
      FuelCity(display: 'Orange', lat: -33.2833, lng: 149.1000, aliases: ['اورنج']),
    ],
  ),
  FuelCountry(
    code: 'pt',
    nameEn: 'Portugal',
    nameFa: 'پرتغال',
    nameDe: 'Portugal',
    currency: 'EUR',
    nominatimCode: 'pt',
    defaultLat: 38.7223,
    defaultLng: -9.1393,
    cities: [
      FuelCity(display: 'Lisboa', lat: 38.7223, lng: -9.1393, aliases: ['Lisbon', 'لیسبون']),
      FuelCity(display: 'Porto', lat: 41.1579, lng: -8.6291, aliases: ['پورتو']),
      FuelCity(display: 'Braga', lat: 41.5454, lng: -8.4265, aliases: ['براگا']),
      FuelCity(display: 'Coimbra', lat: 40.2033, lng: -8.4103, aliases: ['کوییمبرا']),
      FuelCity(display: 'Faro', lat: 37.0194, lng: -7.9322, aliases: ['فارو']),
      FuelCity(display: 'Aveiro', lat: 40.6405, lng: -8.6538, aliases: ['آویرو']),
      FuelCity(display: 'Setúbal', lat: 38.5244, lng: -8.8882, aliases: ['ستوبال']),
      FuelCity(display: 'Funchal', lat: 32.6669, lng: -16.9241, aliases: ['فونشال']),
    ],
  ),
  FuelCountry(
    code: 'be',
    nameEn: 'Belgium',
    nameFa: 'بلژیک',
    nameDe: 'Belgien',
    currency: 'EUR',
    nominatimCode: 'be',
    defaultLat: 50.8503,
    defaultLng: 4.3517,
    cities: [
      FuelCity(display: 'Bruxelles', lat: 50.8503, lng: 4.3517, aliases: ['Brussels', 'بروکسل']),
      FuelCity(display: 'Antwerpen', lat: 51.2194, lng: 4.4025, aliases: ['Antwerp', 'آنتورپ']),
      FuelCity(display: 'Gent', lat: 51.0543, lng: 3.7174, aliases: ['Ghent', 'گنت']),
      FuelCity(display: 'Liège', lat: 50.6326, lng: 5.5797, aliases: ['Liege', 'لیژ']),
      FuelCity(display: 'Brugge', lat: 51.2093, lng: 3.2247, aliases: ['Bruges', 'بروژ']),
      FuelCity(display: 'Charleroi', lat: 50.4108, lng: 4.4446, aliases: ['شارلوا']),
      FuelCity(display: 'Namur', lat: 50.4674, lng: 4.8720, aliases: ['نامور']),
      FuelCity(display: 'Leuven', lat: 50.8798, lng: 4.7005, aliases: ['لوون']),
    ],
  ),
  FuelCountry(
    code: 'nl',
    nameEn: 'Netherlands',
    nameFa: 'هلند',
    nameDe: 'Niederlande',
    currency: 'EUR',
    nominatimCode: 'nl',
    defaultLat: 52.3676,
    defaultLng: 4.9041,
    cities: [
      FuelCity(display: 'Amsterdam', lat: 52.3676, lng: 4.9041, aliases: ['آمستردام']),
      FuelCity(display: 'Rotterdam', lat: 51.9244, lng: 4.4777, aliases: ['روتردام']),
      FuelCity(display: 'Den Haag', lat: 52.0705, lng: 4.3007, aliases: ['The Hague', 'لاهه']),
      FuelCity(display: 'Utrecht', lat: 52.0907, lng: 5.1214, aliases: ['اوترخت']),
      FuelCity(display: 'Eindhoven', lat: 51.4416, lng: 5.4697, aliases: ['آیندهوون']),
      FuelCity(display: 'Groningen', lat: 53.2194, lng: 6.5665, aliases: ['گرونینگن']),
      FuelCity(display: 'Maastricht', lat: 50.8514, lng: 5.6909, aliases: ['ماستریخت']),
      FuelCity(display: 'Haarlem', lat: 52.3874, lng: 4.6462, aliases: ['هارلم']),
    ],
  ),
  FuelCountry(
    code: 'lu',
    nameEn: 'Luxembourg',
    nameFa: 'لوکزامبورگ',
    nameDe: 'Luxemburg',
    currency: 'EUR',
    nominatimCode: 'lu',
    defaultLat: 49.6116,
    defaultLng: 6.1319,
    cities: [
      FuelCity(display: 'Luxembourg', lat: 49.6116, lng: 6.1319, aliases: ['لوکزامبورگ']),
      FuelCity(display: 'Esch-sur-Alzette', lat: 49.4958, lng: 5.9806, aliases: ['اش']),
      FuelCity(display: 'Differdange', lat: 49.5242, lng: 5.8914, aliases: ['دیفردانژ']),
      FuelCity(display: 'Dudelange', lat: 49.4806, lng: 6.0875, aliases: ['دودلانژ']),
    ],
  ),
  FuelCountry(
    code: 'ie',
    nameEn: 'Ireland',
    nameFa: 'ایرلند',
    nameDe: 'Irland',
    currency: 'EUR',
    nominatimCode: 'ie',
    defaultLat: 53.3498,
    defaultLng: -6.2603,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Dublin', lat: 53.3498, lng: -6.2603, aliases: ['دوبلین']),
      FuelCity(display: 'Cork', lat: 51.8985, lng: -8.4756, aliases: ['کرک']),
      FuelCity(display: 'Limerick', lat: 52.6638, lng: -8.6267, aliases: ['لیمریک']),
      FuelCity(display: 'Galway', lat: 53.2707, lng: -9.0568, aliases: ['گالوی']),
      FuelCity(display: 'Waterford', lat: 52.2593, lng: -7.1101, aliases: ['واترفورد']),
    ],
  ),
  FuelCountry(
    code: 'pl',
    nameEn: 'Poland',
    nameFa: 'لهستان',
    nameDe: 'Polen',
    currency: 'PLN',
    nominatimCode: 'pl',
    defaultLat: 52.2297,
    defaultLng: 21.0122,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Warszawa', lat: 52.2297, lng: 21.0122, aliases: ['Warsaw', 'ورشو']),
      FuelCity(display: 'Kraków', lat: 50.0647, lng: 19.9450, aliases: ['Krakow', 'کراکوف']),
      FuelCity(display: 'Gdańsk', lat: 54.3520, lng: 18.6466, aliases: ['Gdansk', 'گدانسک']),
      FuelCity(display: 'Wrocław', lat: 51.1079, lng: 17.0385, aliases: ['Wroclaw', 'وروتسواف']),
      FuelCity(display: 'Poznań', lat: 52.4064, lng: 16.9252, aliases: ['Poznan', 'پوزنان']),
      FuelCity(display: 'Łódź', lat: 51.7592, lng: 19.4560, aliases: ['Lodz', 'ووج']),
    ],
  ),
  FuelCountry(
    code: 'cz',
    nameEn: 'Czechia',
    nameFa: 'چک',
    nameDe: 'Tschechien',
    currency: 'CZK',
    nominatimCode: 'cz',
    defaultLat: 50.0755,
    defaultLng: 14.4378,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Praha', lat: 50.0755, lng: 14.4378, aliases: ['Prague', 'پراگ']),
      FuelCity(display: 'Brno', lat: 49.1951, lng: 16.6068, aliases: ['برنو']),
      FuelCity(display: 'Ostrava', lat: 49.8209, lng: 18.2625, aliases: ['استراوا']),
      FuelCity(display: 'Plzeň', lat: 49.7384, lng: 13.3736, aliases: ['Pilsen', 'پلزن']),
    ],
  ),
  FuelCountry(
    code: 'si',
    nameEn: 'Slovenia',
    nameFa: 'اسلوونی',
    nameDe: 'Slowenien',
    currency: 'EUR',
    nominatimCode: 'si',
    defaultLat: 46.0569,
    defaultLng: 14.5058,
    cities: [
      FuelCity(display: 'Ljubljana', lat: 46.0569, lng: 14.5058, aliases: ['لیوبلیانا']),
      FuelCity(display: 'Maribor', lat: 46.5547, lng: 15.6459, aliases: ['ماریبور']),
      FuelCity(display: 'Celje', lat: 46.2310, lng: 15.2601, aliases: ['سلیه']),
      FuelCity(display: 'Koper', lat: 45.5469, lng: 13.7294, aliases: ['کوپر']),
    ],
  ),
  FuelCountry(
    code: 'hr',
    nameEn: 'Croatia',
    nameFa: 'کرواسی',
    nameDe: 'Kroatien',
    currency: 'EUR',
    nominatimCode: 'hr',
    defaultLat: 45.8150,
    defaultLng: 15.9819,
    cities: [
      FuelCity(display: 'Zagreb', lat: 45.8150, lng: 15.9819, aliases: ['زاگرب']),
      FuelCity(display: 'Split', lat: 43.5081, lng: 16.4402, aliases: ['اسپلیت']),
      FuelCity(display: 'Rijeka', lat: 45.3271, lng: 14.4422, aliases: ['رییکا']),
      FuelCity(display: 'Osijek', lat: 45.5550, lng: 18.6955, aliases: ['اوسییک']),
      FuelCity(display: 'Dubrovnik', lat: 42.6507, lng: 18.0944, aliases: ['دوبروونیک']),
    ],
  ),
  FuelCountry(
    code: 'gr',
    nameEn: 'Greece',
    nameFa: 'یونان',
    nameDe: 'Griechenland',
    currency: 'EUR',
    nominatimCode: 'gr',
    defaultLat: 37.9838,
    defaultLng: 23.7275,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Athína', lat: 37.9838, lng: 23.7275, aliases: ['Athens', 'آتن']),
      FuelCity(display: 'Thessaloniki', lat: 40.6401, lng: 22.9444, aliases: ['سالونیک']),
      FuelCity(display: 'Pátra', lat: 38.2466, lng: 21.7346, aliases: ['Patras', 'پاتراس']),
      FuelCity(display: 'Irákleio', lat: 35.3387, lng: 25.1442, aliases: ['Heraklion', 'هراکلیون']),
    ],
  ),
  FuelCountry(
    code: 'ch',
    nameEn: 'Switzerland',
    nameFa: 'سوئیس',
    nameDe: 'Schweiz',
    currency: 'CHF',
    nominatimCode: 'ch',
    defaultLat: 47.3769,
    defaultLng: 8.5417,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Zürich', lat: 47.3769, lng: 8.5417, aliases: ['Zurich', 'زوریخ']),
      FuelCity(display: 'Genève', lat: 46.2044, lng: 6.1432, aliases: ['Geneva', 'ژنو']),
      FuelCity(display: 'Basel', lat: 47.5596, lng: 7.5886, aliases: ['بازل']),
      FuelCity(display: 'Bern', lat: 46.9480, lng: 7.4474, aliases: ['برن']),
      FuelCity(display: 'Lausanne', lat: 46.5197, lng: 6.6323, aliases: ['لوزان']),
    ],
  ),
  FuelCountry(
    code: 'no',
    nameEn: 'Norway',
    nameFa: 'نروژ',
    nameDe: 'Norwegen',
    currency: 'NOK',
    nominatimCode: 'no',
    defaultLat: 59.9139,
    defaultLng: 10.7522,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Oslo', lat: 59.9139, lng: 10.7522, aliases: ['اسلو']),
      FuelCity(display: 'Bergen', lat: 60.3913, lng: 5.3221, aliases: ['برگن']),
      FuelCity(display: 'Trondheim', lat: 63.4305, lng: 10.3951, aliases: ['تروندهایم']),
      FuelCity(display: 'Stavanger', lat: 58.9700, lng: 5.7331, aliases: ['استاوانگر']),
    ],
  ),
  FuelCountry(
    code: 'se',
    nameEn: 'Sweden',
    nameFa: 'سوئد',
    nameDe: 'Schweden',
    currency: 'SEK',
    nominatimCode: 'se',
    defaultLat: 59.3293,
    defaultLng: 18.0686,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Stockholm', lat: 59.3293, lng: 18.0686, aliases: ['استکهلم']),
      FuelCity(display: 'Göteborg', lat: 57.7089, lng: 11.9746, aliases: ['Gothenburg', 'گوتنبرگ']),
      FuelCity(display: 'Malmö', lat: 55.6050, lng: 13.0038, aliases: ['Malmo', 'مالمو']),
      FuelCity(display: 'Uppsala', lat: 59.8586, lng: 17.6389, aliases: ['اوپسالا']),
    ],
  ),
  FuelCountry(
    code: 'dk',
    nameEn: 'Denmark',
    nameFa: 'دانمارک',
    nameDe: 'Dänemark',
    currency: 'DKK',
    nominatimCode: 'dk',
    defaultLat: 55.6761,
    defaultLng: 12.5683,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'København', lat: 55.6761, lng: 12.5683, aliases: ['Copenhagen', 'کپنهاگ']),
      FuelCity(display: 'Aarhus', lat: 56.1629, lng: 10.2039, aliases: ['آرهوس']),
      FuelCity(display: 'Odense', lat: 55.4038, lng: 10.4024, aliases: ['اودنسه']),
      FuelCity(display: 'Aalborg', lat: 57.0488, lng: 9.9217, aliases: ['البورگ']),
    ],
  ),
  FuelCountry(
    code: 'br',
    nameEn: 'Brazil',
    nameFa: 'برزیل',
    nameDe: 'Brasilien',
    currency: 'BRL',
    nominatimCode: 'br',
    defaultLat: -23.5505,
    defaultLng: -46.6333,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'São Paulo', lat: -23.5505, lng: -46.6333, aliases: ['Sao Paulo', 'سائوپائولو']),
      FuelCity(display: 'Rio de Janeiro', lat: -22.9068, lng: -43.1729, aliases: ['ریو']),
      FuelCity(display: 'Brasília', lat: -15.8267, lng: -47.9218, aliases: ['Brasilia', 'برازیلیا']),
      FuelCity(display: 'Salvador', lat: -12.9777, lng: -38.5016, aliases: ['سالوادور']),
      FuelCity(display: 'Belo Horizonte', lat: -19.9167, lng: -43.9345, aliases: ['بلو هوریزونته']),
    ],
  ),
  FuelCountry(
    code: 'ca',
    nameEn: 'Canada',
    nameFa: 'کانادا',
    nameDe: 'Kanada',
    currency: 'CAD',
    nominatimCode: 'ca',
    defaultLat: 43.6532,
    defaultLng: -79.3832,
    pricingMode: 'station',
    cities: [
      FuelCity(display: 'Toronto', lat: 43.6532, lng: -79.3832, aliases: ['تورنتو', 'YYZ']),
      FuelCity(display: 'Montréal', lat: 45.5017, lng: -73.5673, aliases: ['Montreal', 'مونترال']),
      FuelCity(display: 'Vancouver', lat: 49.2827, lng: -123.1207, aliases: ['ونکوور', 'YVR']),
      FuelCity(display: 'Calgary', lat: 51.0447, lng: -114.0719, aliases: ['کلگری']),
      FuelCity(display: 'Ottawa', lat: 45.4215, lng: -75.6972, aliases: ['اتاوا']),
    ],
  ),
  FuelCountry(
    code: 'sa',
    nameEn: 'Saudi Arabia',
    nameFa: 'عربستان سعودی',
    nameDe: 'Saudi-Arabien',
    currency: 'SAR',
    nominatimCode: 'sa',
    defaultLat: 24.7136,
    defaultLng: 46.6753,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Riyadh', lat: 24.7136, lng: 46.6753, aliases: ['ریاض']),
      FuelCity(display: 'Jeddah', lat: 21.4858, lng: 39.1925, aliases: ['جده']),
      FuelCity(display: 'Dammam', lat: 26.4207, lng: 50.0888, aliases: ['دمام']),
      FuelCity(display: 'Mecca', lat: 21.3891, lng: 39.8579, aliases: ['مکه']),
      FuelCity(display: 'Medina', lat: 24.5247, lng: 39.5692, aliases: ['مدینه']),
    ],
  ),
  FuelCountry(
    code: 'ae',
    nameEn: 'United Arab Emirates',
    nameFa: 'امارات',
    nameDe: 'Vereinigte Arabische Emirate',
    currency: 'AED',
    nominatimCode: 'ae',
    defaultLat: 25.2048,
    defaultLng: 55.2708,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Dubai', lat: 25.2048, lng: 55.2708, aliases: ['دبی']),
      FuelCity(display: 'Abu Dhabi', lat: 24.4539, lng: 54.3773, aliases: ['ابوظبی']),
      FuelCity(display: 'Sharjah', lat: 25.3463, lng: 55.4209, aliases: ['شارجه']),
      FuelCity(display: 'Ajman', lat: 25.4052, lng: 55.5136, aliases: ['عجمان']),
      FuelCity(display: 'Al Ain', lat: 24.2075, lng: 55.7447, aliases: ['العین']),
    ],
  ),
  FuelCountry(
    code: 'cn',
    nameEn: 'China',
    nameFa: 'چین',
    nameDe: 'China',
    currency: 'CNY',
    nominatimCode: 'cn',
    defaultLat: 31.2304,
    defaultLng: 121.4737,
    pricingMode: 'national',
    cities: [
      FuelCity(display: 'Shanghai', lat: 31.2304, lng: 121.4737, aliases: ['شانگهای']),
      FuelCity(display: 'Beijing', lat: 39.9042, lng: 116.4074, aliases: ['پکن', 'Pekan', 'Peking', 'Beijing']),
      FuelCity(display: 'Guangzhou', lat: 23.1291, lng: 113.2644, aliases: ['گوانگژو']),
      FuelCity(display: 'Shenzhen', lat: 22.5431, lng: 114.0579, aliases: ['شنژن']),
      FuelCity(display: 'Chengdu', lat: 30.5728, lng: 104.0668, aliases: ['چنگدو']),
      FuelCity(display: 'Hangzhou', lat: 30.2741, lng: 120.1551, aliases: ['هانگژو']),
    ],
  ),
  FuelCountry(
    code: 'us',
    nameEn: 'United States',
    nameFa: 'آمریکا',
    nameDe: 'USA',
    currency: 'USD',
    nominatimCode: 'us',
    defaultLat: 40.7128,
    defaultLng: -74.0060,
    pricingMode: 'station',
    cities: [
      FuelCity(display: 'New York', lat: 40.7128, lng: -74.0060, aliases: ['نیویورک', 'NY', 'NYC', 'New York City']),
      FuelCity(display: 'Los Angeles', lat: 34.0522, lng: -118.2437, aliases: ['لس‌آنجلس', 'LA', 'L.A.']),
      FuelCity(display: 'Chicago', lat: 41.8781, lng: -87.6298, aliases: ['شیکاگو']),
      FuelCity(display: 'Houston', lat: 29.7604, lng: -95.3698, aliases: ['هیوستون']),
      FuelCity(display: 'Phoenix', lat: 33.4484, lng: -112.0740, aliases: ['فینیکس']),
      FuelCity(display: 'Philadelphia', lat: 39.9526, lng: -75.1652, aliases: ['فیلادلفیا', 'Philly']),
      FuelCity(display: 'San Antonio', lat: 29.4241, lng: -98.4936, aliases: ['سن آنتونیو']),
      FuelCity(display: 'San Diego', lat: 32.7157, lng: -117.1611, aliases: ['سن دیگو']),
      FuelCity(display: 'Dallas', lat: 32.7767, lng: -96.7970, aliases: ['دالاس']),
      FuelCity(display: 'San Jose', lat: 37.3382, lng: -121.8863, aliases: ['سن خوزه', 'San José', 'SanJose']),
      FuelCity(display: 'Austin', lat: 30.2672, lng: -97.7431, aliases: ['آستین']),
      FuelCity(display: 'Jacksonville', lat: 30.3322, lng: -81.6557, aliases: ['جکسونویل']),
      FuelCity(display: 'Fort Worth', lat: 32.7555, lng: -97.3308, aliases: ['فورت ورث']),
      FuelCity(display: 'Columbus', lat: 39.9612, lng: -82.9988, aliases: ['کلمبوس']),
      FuelCity(display: 'Charlotte', lat: 35.2271, lng: -80.8431, aliases: ['شارلوت']),
      FuelCity(display: 'San Francisco', lat: 37.7749, lng: -122.4194, aliases: ['سان فرانسیسکو', 'SF', 'SanFran']),
      FuelCity(display: 'Indianapolis', lat: 39.7684, lng: -86.1581, aliases: ['ایندیاناپولیس']),
      FuelCity(display: 'Seattle', lat: 47.6062, lng: -122.3321, aliases: ['سیاتل']),
      FuelCity(display: 'Denver', lat: 39.7392, lng: -104.9903, aliases: ['دنور']),
      FuelCity(display: 'Washington', lat: 38.9072, lng: -77.0369, aliases: ['واشنگتن', 'DC', 'Washington DC', 'Washington D.C.']),
      FuelCity(display: 'Boston', lat: 42.3601, lng: -71.0589, aliases: ['بوستون']),
      FuelCity(display: 'El Paso', lat: 31.7619, lng: -106.4850, aliases: ['ال پاسو']),
      FuelCity(display: 'Nashville', lat: 36.1627, lng: -86.7816, aliases: ['نashville']),
      FuelCity(display: 'Detroit', lat: 42.3314, lng: -83.0458, aliases: ['دیترویت']),
      FuelCity(display: 'Oklahoma City', lat: 35.4676, lng: -97.5164, aliases: ['اوکلاهما سیتی']),
      FuelCity(display: 'Portland', lat: 45.5152, lng: -122.6784, aliases: ['پورتلند']),
      FuelCity(display: 'Las Vegas', lat: 36.1699, lng: -115.1398, aliases: ['لاس وگاس', 'Vegas']),
      FuelCity(display: 'Memphis', lat: 35.1495, lng: -90.0490, aliases: ['ممفیس']),
      FuelCity(display: 'Louisville', lat: 38.2527, lng: -85.7585, aliases: ['لوئیزویل']),
      FuelCity(display: 'Baltimore', lat: 39.2904, lng: -76.6122, aliases: ['بالتیمور']),
      FuelCity(display: 'Milwaukee', lat: 43.0389, lng: -87.9065, aliases: ['میلواکی']),
      FuelCity(display: 'Albuquerque', lat: 35.0844, lng: -106.6504, aliases: ['آلباکرکی']),
      FuelCity(display: 'Tucson', lat: 32.2226, lng: -110.9747, aliases: ['تاکسون']),
      FuelCity(display: 'Fresno', lat: 36.7378, lng: -119.7871, aliases: ['فرزنو']),
      FuelCity(display: 'Sacramento', lat: 38.5816, lng: -121.4944, aliases: ['ساکرامنتو']),
      FuelCity(display: 'Mesa', lat: 33.4152, lng: -111.8315, aliases: ['میسا']),
      FuelCity(display: 'Kansas City', lat: 39.0997, lng: -94.5786, aliases: ['کانزاس سیتی']),
      FuelCity(display: 'Atlanta', lat: 33.7490, lng: -84.3880, aliases: ['آتلانتا']),
      FuelCity(display: 'Omaha', lat: 41.2565, lng: -95.9345, aliases: ['اوماها']),
      FuelCity(display: 'Colorado Springs', lat: 38.8339, lng: -104.8214, aliases: ['کولورادو اسپرینگز']),
      FuelCity(display: 'Raleigh', lat: 35.7796, lng: -78.6382, aliases: ['رالی']),
      FuelCity(display: 'Miami', lat: 25.7617, lng: -80.1918, aliases: ['میامی']),
      FuelCity(display: 'Virginia Beach', lat: 36.8529, lng: -75.9780, aliases: ['ویرجینیا بیچ']),
      FuelCity(display: 'Oakland', lat: 37.8044, lng: -122.2712, aliases: ['اوکلند']),
      FuelCity(display: 'Minneapolis', lat: 44.9778, lng: -93.2650, aliases: ['مینیاپولیس']),
      FuelCity(display: 'Tulsa', lat: 36.1540, lng: -95.9928, aliases: ['تولسا']),
      FuelCity(display: 'Tampa', lat: 27.9506, lng: -82.4572, aliases: ['تامپا']),
      FuelCity(display: 'Arlington', lat: 32.7357, lng: -97.1081, aliases: ['آرلینگتون']),
      FuelCity(display: 'New Orleans', lat: 29.9511, lng: -90.0715, aliases: ['نیواورلئان']),
      FuelCity(display: 'Wichita', lat: 37.6872, lng: -97.3301, aliases: ['ویچیتا']),
      FuelCity(display: 'Bakersfield', lat: 35.3733, lng: -119.0187, aliases: ['بیکرزفیلد']),
      FuelCity(display: 'Cleveland', lat: 41.4993, lng: -81.6944, aliases: ['کلیولند']),
      FuelCity(display: 'Aurora', lat: 39.7294, lng: -104.8319, aliases: ['آرورا']),
      FuelCity(display: 'Anaheim', lat: 33.8366, lng: -117.9143, aliases: ['آناهایم']),
      FuelCity(display: 'Honolulu', lat: 21.3069, lng: -157.8583, aliases: ['هونولولو']),
      FuelCity(display: 'Santa Ana', lat: 33.7455, lng: -117.8677, aliases: ['سانتا آنا']),
      FuelCity(display: 'Riverside', lat: 33.9806, lng: -117.3755, aliases: ['ریورساید']),
      FuelCity(display: 'Corpus Christi', lat: 27.8006, lng: -97.3964, aliases: ['کورپوس کریستی']),
      FuelCity(display: 'Lexington', lat: 38.0406, lng: -84.5037, aliases: ['لکسینگتون']),
      FuelCity(display: 'Henderson', lat: 36.0395, lng: -114.9817, aliases: ['هندرسون']),
      FuelCity(display: 'Stockton', lat: 37.9577, lng: -121.2908, aliases: ['استاکتون']),
      FuelCity(display: 'Saint Paul', lat: 44.9537, lng: -93.0900, aliases: ['St Paul', 'St. Paul', 'سنت پل']),
      FuelCity(display: 'Cincinnati', lat: 39.1031, lng: -84.5120, aliases: ['سینسیناتی']),
      FuelCity(display: 'St. Louis', lat: 38.6270, lng: -90.1994, aliases: ['Saint Louis', 'سنت لوئیس']),
      FuelCity(display: 'Pittsburgh', lat: 40.4406, lng: -79.9959, aliases: ['پیتسبورگ']),
      FuelCity(display: 'Greensboro', lat: 36.0726, lng: -79.7920, aliases: ['گرینزبورو']),
      FuelCity(display: 'Anchorage', lat: 61.2181, lng: -149.9003, aliases: ['انکوریج']),
      FuelCity(display: 'Plano', lat: 33.0198, lng: -96.6989, aliases: ['پلانو']),
      FuelCity(display: 'Lincoln', lat: 40.8258, lng: -96.6852, aliases: ['لینکلن']),
      FuelCity(display: 'Orlando', lat: 28.5383, lng: -81.3792, aliases: ['اورلاندو']),
      FuelCity(display: 'Irvine', lat: 33.6846, lng: -117.8265, aliases: ['اروین']),
      FuelCity(display: 'Newark', lat: 40.7357, lng: -74.1724, aliases: ['نیوارک']),
      FuelCity(display: 'Durham', lat: 35.9940, lng: -78.8986, aliases: ['دورام']),
      FuelCity(display: 'Chula Vista', lat: 32.6401, lng: -117.0842, aliases: ['چولا ویستا']),
      FuelCity(display: 'Toledo', lat: 41.6528, lng: -83.5379, aliases: ['تولدو']),
      FuelCity(display: 'Fort Wayne', lat: 41.0793, lng: -85.1394, aliases: ['فورت وین']),
      FuelCity(display: 'St. Petersburg', lat: 27.7676, lng: -82.6403, aliases: ['Saint Petersburg', 'سنت پترزبورگ']),
      FuelCity(display: 'Laredo', lat: 27.5306, lng: -99.4803, aliases: ['لاریدو']),
      FuelCity(display: 'Jersey City', lat: 40.7178, lng: -74.0431, aliases: ['جرسی سیتی']),
      FuelCity(display: 'Chandler', lat: 33.3062, lng: -111.8413, aliases: ['چندلر']),
      FuelCity(display: 'Madison', lat: 43.0731, lng: -89.4012, aliases: ['مدیسون']),
      FuelCity(display: 'Lubbock', lat: 33.5779, lng: -101.8552, aliases: ['لاباک']),
      FuelCity(display: 'Scottsdale', lat: 33.4942, lng: -111.9261, aliases: ['اسکاتسدیل']),
      FuelCity(display: 'Reno', lat: 39.5296, lng: -119.8138, aliases: ['رینو']),
      FuelCity(display: 'Buffalo', lat: 42.8864, lng: -78.8784, aliases: ['بافالو']),
      FuelCity(display: 'Gilbert', lat: 33.3528, lng: -111.7890, aliases: ['گیلبرت']),
      FuelCity(display: 'Glendale', lat: 33.5387, lng: -112.1860, aliases: ['گلندیل']),
      FuelCity(display: 'North Las Vegas', lat: 36.1989, lng: -115.1175, aliases: ['نورت لاس وگاس']),
      FuelCity(display: 'Winston-Salem', lat: 36.0999, lng: -80.2442, aliases: ['وینستون سیلم']),
      FuelCity(display: 'Chesapeake', lat: 36.7682, lng: -76.2875, aliases: ['چساپیک']),
      FuelCity(display: 'Norfolk', lat: 36.8508, lng: -76.2859, aliases: ['نورفولک']),
      FuelCity(display: 'Fremont', lat: 37.5485, lng: -121.9886, aliases: ['فریمونت']),
      FuelCity(display: 'Garland', lat: 32.9126, lng: -96.6389, aliases: ['گارلند']),
      FuelCity(display: 'Irving', lat: 32.8140, lng: -96.9489, aliases: ['ایروینگ']),
      FuelCity(display: 'Hialeah', lat: 25.8576, lng: -80.2781, aliases: ['هیالیا']),
      FuelCity(display: 'Richmond', lat: 37.5407, lng: -77.4360, aliases: ['ریچموند']),
      FuelCity(display: 'Boise', lat: 43.6150, lng: -116.2023, aliases: ['بویزی']),
      FuelCity(display: 'Spokane', lat: 47.6588, lng: -117.4260, aliases: ['اسپوکن']),
      FuelCity(display: 'Baton Rouge', lat: 30.4515, lng: -91.1871, aliases: ['باتون روژ']),
      FuelCity(display: 'Tacoma', lat: 47.2529, lng: -122.4443, aliases: ['تاکوما']),
      FuelCity(display: 'San Bernardino', lat: 34.1083, lng: -117.2898, aliases: ['سن برناردینو']),
      FuelCity(display: 'Grand Rapids', lat: 42.9634, lng: -85.6681, aliases: ['گرند رپیدز']),
      FuelCity(display: 'Huntsville', lat: 34.7304, lng: -86.5861, aliases: ['هانتسویل']),
      FuelCity(display: 'Salt Lake City', lat: 40.7608, lng: -111.8910, aliases: ['سالت لیک سیتی', 'SLC']),
      FuelCity(display: 'Fayetteville', lat: 35.0527, lng: -78.8784, aliases: ['فییتویل']),
      FuelCity(display: 'Yonkers', lat: 40.9312, lng: -73.8987, aliases: ['یانکرز']),
      FuelCity(display: 'Amarillo', lat: 35.2220, lng: -101.8313, aliases: ['آماریلو']),
      FuelCity(display: 'Glendale CA', lat: 34.1425, lng: -118.2551, aliases: ['Glendale California']),
      FuelCity(display: 'Huntington Beach', lat: 33.6595, lng: -117.9988, aliases: ['هانتینگتون بیچ']),
      FuelCity(display: 'McKinney', lat: 33.1972, lng: -96.6397, aliases: ['مک‌کینی']),
      FuelCity(display: 'Montgomery', lat: 32.3668, lng: -86.3000, aliases: ['مونتگومری']),
      FuelCity(display: 'Augusta', lat: 33.4735, lng: -82.0105, aliases: ['آگوستا']),
      FuelCity(display: 'Akron', lat: 41.0814, lng: -81.5190, aliases: ['اکرون']),
      FuelCity(display: 'Little Rock', lat: 34.7465, lng: -92.2896, aliases: ['لیتل راک']),
      FuelCity(display: 'Oxnard', lat: 34.1975, lng: -119.1771, aliases: ['اکسنارد']),
      FuelCity(display: 'Moreno Valley', lat: 33.9425, lng: -117.2297, aliases: ['مورنو ولی']),
      FuelCity(display: 'Rochester', lat: 43.1566, lng: -77.6088, aliases: ['راچستر']),
      FuelCity(display: 'Fontana', lat: 34.0922, lng: -117.4350, aliases: ['فونتانا']),
      FuelCity(display: 'Amarillo', lat: 35.2220, lng: -101.8313, aliases: ['آماریلو TX']),
      FuelCity(display: 'Modesto', lat: 37.6391, lng: -120.9969, aliases: ['مودستو']),
      FuelCity(display: 'Des Moines', lat: 41.5868, lng: -93.6250, aliases: ['دس موینز']),
      FuelCity(display: 'Fargo', lat: 46.8772, lng: -96.7898, aliases: ['فارگو']),
      FuelCity(display: 'Sioux Falls', lat: 43.5446, lng: -96.7311, aliases: ['سیو فالز']),
      FuelCity(display: 'Billings', lat: 45.7833, lng: -108.5007, aliases: ['بیلینگز']),
      FuelCity(display: 'Cheyenne', lat: 41.1400, lng: -104.8202, aliases: ['شاین']),
      FuelCity(display: 'Providence', lat: 41.8240, lng: -71.4128, aliases: ['پراویدنس']),
      FuelCity(display: 'Hartford', lat: 41.7658, lng: -72.6734, aliases: ['هارتفورد']),
      FuelCity(display: 'Bridgeport', lat: 41.1865, lng: -73.1952, aliases: ['بریجپورت']),
      FuelCity(display: 'New Haven', lat: 41.3083, lng: -72.9279, aliases: ['نیوهیون']),
      FuelCity(display: 'Manchester NH', lat: 42.9956, lng: -71.4548, aliases: ['Manchester']),
      FuelCity(display: 'Portland ME', lat: 43.6591, lng: -70.2568, aliases: ['Portland Maine']),
      FuelCity(display: 'Burlington', lat: 44.4759, lng: -73.2121, aliases: ['برلینگتون']),
      FuelCity(display: 'Albany', lat: 42.6526, lng: -73.7562, aliases: ['آلبانی']),
      FuelCity(display: 'Syracuse', lat: 43.0481, lng: -76.1474, aliases: ['سیراکیوز']),
      FuelCity(display: 'Charleston', lat: 32.7765, lng: -79.9311, aliases: ['چارلستون']),
      FuelCity(display: 'Columbia', lat: 34.0007, lng: -81.0348, aliases: ['کلمبیا']),
      FuelCity(display: 'Savannah', lat: 32.0809, lng: -81.0912, aliases: ['ساوانا']),
      FuelCity(display: 'Knoxville', lat: 35.9606, lng: -83.9207, aliases: ['ناکسویل']),
      FuelCity(display: 'Chattanooga', lat: 35.0456, lng: -85.3097, aliases: ['چاتانوگا']),
      FuelCity(display: 'Birmingham', lat: 33.5186, lng: -86.8104, aliases: ['بیرمنگام']),
      FuelCity(display: 'Mobile', lat: 30.6954, lng: -88.0399, aliases: ['موبایل']),
      FuelCity(display: 'Jackson', lat: 32.2988, lng: -90.1848, aliases: ['جکسون']),
      FuelCity(display: 'Shreveport', lat: 32.5252, lng: -93.7502, aliases: ['شروپورت']),
      FuelCity(display: 'Oklahoma City', lat: 35.4676, lng: -97.5164, aliases: ['OKC']),
      FuelCity(display: 'Tulsa', lat: 36.1540, lng: -95.9928, aliases: ['تولسا OK']),
      FuelCity(display: 'Wichita', lat: 37.6872, lng: -97.3301, aliases: ['ویچیتا KS']),
      FuelCity(display: 'Santa Fe', lat: 35.6870, lng: -105.9378, aliases: ['سانتا فه']),
      FuelCity(display: 'Santa Barbara', lat: 34.4208, lng: -119.6982, aliases: ['سانتا باربارا']),
      FuelCity(display: 'Santa Rosa', lat: 38.4404, lng: -122.7141, aliases: ['سانتا روزا']),
      FuelCity(display: 'Santa Clara', lat: 37.3541, lng: -121.9552, aliases: ['سانتا کلارا']),
      FuelCity(display: 'Sunnyvale', lat: 37.3688, lng: -122.0363, aliases: ['سانی‌ویل']),
      FuelCity(display: 'Palo Alto', lat: 37.4419, lng: -122.1430, aliases: ['پالو آلتو']),
      FuelCity(display: 'Mountain View', lat: 37.3861, lng: -122.0839, aliases: ['ماونتین ویو']),
      FuelCity(display: 'Berkeley', lat: 37.8715, lng: -122.2730, aliases: ['برکلی']),
      FuelCity(display: 'Pasadena', lat: 34.1478, lng: -118.1445, aliases: ['پاسادنا']),
      FuelCity(display: 'Long Beach', lat: 33.7701, lng: -118.1937, aliases: ['لانگ بیچ']),
      FuelCity(display: 'Santa Monica', lat: 34.0195, lng: -118.4912, aliases: ['سانتا مونیکا']),
      FuelCity(display: 'Malibu', lat: 34.0259, lng: -118.7798, aliases: ['مالیبو']),
      FuelCity(display: 'Palm Springs', lat: 33.8303, lng: -116.5453, aliases: ['پالم اسپرینگز']),
      FuelCity(display: 'San Luis Obispo', lat: 35.2828, lng: -120.6596, aliases: ['SLO']),
      FuelCity(display: 'Eugene', lat: 44.0521, lng: -123.0868, aliases: ['یوجین']),
      FuelCity(display: 'Salem', lat: 44.9429, lng: -123.0351, aliases: ['سیلم']),
      FuelCity(display: 'Olympia', lat: 47.0379, lng: -122.9007, aliases: ['المپیا']),
      FuelCity(display: 'Bellevue', lat: 47.6101, lng: -122.2015, aliases: ['بلویو']),
      FuelCity(display: 'Juneau', lat: 58.3019, lng: -134.4197, aliases: ['جونو']),
      FuelCity(display: 'Fairbanks', lat: 64.8378, lng: -147.7164, aliases: ['فیربنکس']),
      FuelCity(display: 'Ann Arbor', lat: 42.2808, lng: -83.7430, aliases: ['آن‌آربور']),
      FuelCity(display: 'Naperville', lat: 41.7508, lng: -88.1535, aliases: ['نیپرویل']),
      FuelCity(display: 'Fort Lauderdale', lat: 26.1224, lng: -80.1373, aliases: ['فورت لادردیل']),
      FuelCity(display: 'West Palm Beach', lat: 26.7153, lng: -80.0534, aliases: ['وست پالم بیچ']),
      FuelCity(display: 'Tallahassee', lat: 30.4383, lng: -84.2807, aliases: ['تالاهاسی']),
      FuelCity(display: 'Gainesville', lat: 29.6516, lng: -82.3248, aliases: ['گینزویل']),
      FuelCity(display: 'Dayton', lat: 39.7589, lng: -84.1916, aliases: ['دیتون']),
      FuelCity(display: 'Harrisburg', lat: 40.2732, lng: -76.8867, aliases: ['هریسبورگ']),
      FuelCity(display: 'Trenton', lat: 40.2206, lng: -74.7597, aliases: ['ترنتون']),
      FuelCity(display: 'Wilmington', lat: 39.7391, lng: -75.5398, aliases: ['ویلمنگتون']),
      FuelCity(display: 'Dover', lat: 39.1582, lng: -75.5244, aliases: ['دوور']),
      FuelCity(display: 'Annapolis', lat: 38.9784, lng: -76.4922, aliases: ['آناپولیس']),
      FuelCity(display: 'Concord', lat: 43.2081, lng: -71.5376, aliases: ['کنکورد']),
      FuelCity(display: 'Montpelier', lat: 44.2601, lng: -72.5754, aliases: ['مونت‌پلیه']),
      FuelCity(display: 'Augusta ME', lat: 44.3106, lng: -69.7795, aliases: ['Augusta Maine']),
      FuelCity(display: 'Helena', lat: 46.5891, lng: -112.0391, aliases: ['هلنا']),
      FuelCity(display: 'Bismarck', lat: 46.8083, lng: -100.7837, aliases: ['بیسمارک']),
      FuelCity(display: 'Pierre', lat: 44.3683, lng: -100.3510, aliases: ['پیر']),
      FuelCity(display: 'Topeka', lat: 39.0473, lng: -95.6752, aliases: ['توپیکا']),
      FuelCity(display: 'Jefferson City', lat: 38.5767, lng: -92.1735, aliases: ['جفرسون سیتی']),
      FuelCity(display: 'Springfield IL', lat: 39.7817, lng: -89.6501, aliases: ['Springfield']),
      FuelCity(display: 'Springfield MO', lat: 37.2090, lng: -93.2923, aliases: ['Springfield Missouri']),
      FuelCity(display: 'Frankfort', lat: 38.2009, lng: -84.8733, aliases: ['فرانکفورت']),
      FuelCity(display: 'Indianapolis', lat: 39.7684, lng: -86.1581, aliases: ['Indy']),
      FuelCity(display: 'Carson City', lat: 39.1638, lng: -119.7674, aliases: ['کارسون سیتی']),
      FuelCity(display: 'Provo', lat: 40.2338, lng: -111.6585, aliases: ['پروو']),
      FuelCity(display: 'Ogden', lat: 41.2230, lng: -111.9738, aliases: ['آگدن']),
      FuelCity(display: 'Tempe', lat: 33.4255, lng: -111.9400, aliases: ['تمپی']),
      FuelCity(display: 'Peoria', lat: 33.5806, lng: -112.2374, aliases: ['پیوریا']),
      FuelCity(display: 'Cary', lat: 35.7915, lng: -78.7811, aliases: ['کری']),
      FuelCity(display: 'Overland Park', lat: 38.9822, lng: -94.6708, aliases: ['اورلند پارک']),
      FuelCity(display: 'Vancouver WA', lat: 45.6387, lng: -122.6615, aliases: ['Vancouver Washington']),
      FuelCity(display: 'Boulder', lat: 40.0150, lng: -105.2705, aliases: ['بولدر']),
      FuelCity(display: 'Aspen', lat: 39.1911, lng: -106.8175, aliases: ['اسپن']),
      FuelCity(display: 'Napa', lat: 38.2975, lng: -122.2869, aliases: ['ناپا']),
      FuelCity(display: 'Monterey', lat: 36.6002, lng: -121.8947, aliases: ['مونتری']),
      FuelCity(display: 'Carmel', lat: 36.5552, lng: -121.9233, aliases: ['کارمل']),
      FuelCity(display: 'Key West', lat: 24.5551, lng: -81.7800, aliases: ['کی وست']),
      FuelCity(display: 'Brooklyn', lat: 40.6782, lng: -73.9442, aliases: ['بروکلین']),
      FuelCity(display: 'Queens', lat: 40.7282, lng: -73.7949, aliases: ['کوئینز']),
      FuelCity(display: 'Bronx', lat: 40.8448, lng: -73.8648, aliases: ['برانکس']),
      FuelCity(display: 'Staten Island', lat: 40.5795, lng: -74.1502, aliases: ['استاتن آیلند']),
      FuelCity(display: 'Manhattan', lat: 40.7831, lng: -73.9712, aliases: ['منهتن']),
    ],
  ),
  FuelCountry(
    code: 'in',
    nameEn: 'India',
    nameFa: 'هند',
    nameDe: 'Indien',
    currency: 'INR',
    nominatimCode: 'in',
    defaultLat: 28.6139,
    defaultLng: 77.2090,
    pricingMode: 'station',
    cities: [
      FuelCity(display: 'New Delhi', lat: 28.6139, lng: 77.2090, aliases: ['دهلی', 'Delhi']),
      FuelCity(display: 'Mumbai', lat: 19.0760, lng: 72.8777, aliases: ['بمبئی']),
      FuelCity(display: 'Bengaluru', lat: 12.9716, lng: 77.5946, aliases: ['Bangalore', 'بنگلور']),
      FuelCity(display: 'Hyderabad', lat: 17.3850, lng: 78.4867, aliases: ['حیدرآباد']),
      FuelCity(display: 'Chennai', lat: 13.0827, lng: 80.2707, aliases: ['چنای']),
      FuelCity(display: 'Kolkata', lat: 22.5726, lng: 88.3639, aliases: ['کلکته']),
    ],
  ),
];
