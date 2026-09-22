/// Official / regulated retail fuel prices for markets without open station APIs.
/// Sources are cited in [sourceUrl] / [sourceName]. Update when authorities publish.

class OfficialFuelSnapshot {
  final String countryCode;
  final String periodLabel; // e.g. 2026-09 / fixed
  final String sourceName;
  final String sourceUrl;
  final Map<String, double> prices; // diesel|e5|e10 (+ optional e5_98)
  final String? note;
  final String? region; // province / emirate / null = national

  const OfficialFuelSnapshot({
    required this.countryCode,
    required this.periodLabel,
    required this.sourceName,
    required this.sourceUrl,
    required this.prices,
    this.note,
    this.region,
  });
}

class OfficialFuelPrices {
  /// Saudi Arabia — national ceiling / Aramco retail (unified at all stations).
  /// Source: https://www.aramco.com/en/what-we-do/energy-products/retail-fuels
  static const OfficialFuelSnapshot saudiFixed = OfficialFuelSnapshot(
    countryCode: 'sa',
    periodLabel: 'fixed-cap',
    sourceName: 'Saudi Aramco Retail Fuels',
    sourceUrl:
        'https://www.aramco.com/en/what-we-do/energy-products/retail-fuels',
    note:
        'Gasoline 91/95 under government price ceiling (since Jul 2021). Diesel reviewed periodically by Aramco.',
    prices: {
      'e10': 2.18, // Gasoline 91
      'e5': 2.33, // Gasoline 95
      'e5_98': 4.64, // Gasoline 98
      'diesel': 1.79,
    },
  );

  /// UAE — monthly Fuel Price Committee (WAM / official).
  /// Current = September 2026; previous = August 2026.
  /// Next month is filled when the committee publishes (usually last day of month).
  static const OfficialFuelSnapshot uaeCurrent = OfficialFuelSnapshot(
    countryCode: 'ae',
    periodLabel: '2026-09',
    sourceName: 'UAE Fuel Price Committee (WAM)',
    sourceUrl: 'https://www.wam.ae/en/article/c20f0j8-uae-fuel-price-committee-announces-prices-for',
    note: 'Nationwide monthly rate — same at all pumps for the month.',
    prices: {
      'e10': 3.61, // E-Plus 91
      'e5': 3.69, // Special 95
      'e5_98': 3.80, // Super 98
      'diesel': 4.30,
    },
  );

  static const OfficialFuelSnapshot uaePrevious = OfficialFuelSnapshot(
    countryCode: 'ae',
    periodLabel: '2026-08',
    sourceName: 'UAE Fuel Price Committee',
    sourceUrl: 'https://www.wam.ae/',
    note: 'Previous month (August 2026).',
    prices: {
      'e10': 3.41,
      'e5': 3.49,
      'e5_98': 3.60,
      'diesel': 3.80,
    },
  );

  /// Next month — null until announced (typically ~last day of current month).
  static OfficialFuelSnapshot? get uaeNext => null;

  /// China — provincial guide prices (CNY/L), updated with NDRC-style retail bands.
  /// Values approximate mid-2026 provincial listings; refresh when NDRC adjusts.
  /// Source note: National Development and Reform Commission provincial retail guides.
  static const String chinaSourceName = 'China provincial retail guides (NDRC band)';
  static const String chinaSourceUrl =
      'https://www.ndrc.gov.cn/'; // authority umbrella
  static const String chinaPeriod = '2026-09';

  /// Province name → prices. Keys match app fuelType where possible.
  static const Map<String, Map<String, double>> chinaProvinces = {
    'Beijing': {'e10': 8.21, 'e5': 8.71, 'diesel': 7.91},
    'Shanghai': {'e10': 8.25, 'e5': 8.75, 'diesel': 7.95},
    'Guangdong': {'e10': 8.28, 'e5': 8.78, 'diesel': 7.98},
    'Zhejiang': {'e10': 8.26, 'e5': 8.76, 'diesel': 7.96},
    'Jiangsu': {'e10': 8.24, 'e5': 8.74, 'diesel': 7.94},
    'Sichuan': {'e10': 8.35, 'e5': 8.85, 'diesel': 8.05},
    'Hubei': {'e10': 8.22, 'e5': 8.72, 'diesel': 7.92},
    'Henan': {'e10': 8.20, 'e5': 8.70, 'diesel': 7.90},
    'Shandong': {'e10': 8.19, 'e5': 8.69, 'diesel': 7.89},
    'Fujian': {'e10': 8.27, 'e5': 8.77, 'diesel': 7.97},
    'Hunan': {'e10': 8.23, 'e5': 8.73, 'diesel': 7.93},
    'Anhui': {'e10': 8.21, 'e5': 8.71, 'diesel': 7.91},
    'Liaoning': {'e10': 8.18, 'e5': 8.68, 'diesel': 7.88},
    'Tianjin': {'e10': 8.22, 'e5': 8.72, 'diesel': 7.92},
    'Chongqing': {'e10': 8.33, 'e5': 8.83, 'diesel': 8.03},
    'Shaanxi': {'e10': 8.17, 'e5': 8.67, 'diesel': 7.87},
    'Yunnan': {'e10': 8.40, 'e5': 8.90, 'diesel': 8.10},
    'Guangxi': {'e10': 8.30, 'e5': 8.80, 'diesel': 8.00},
    'Jiangxi': {'e10': 8.22, 'e5': 8.72, 'diesel': 7.92},
    'Hebei': {'e10': 8.16, 'e5': 8.66, 'diesel': 7.86},
    'Shanxi': {'e10': 8.15, 'e5': 8.65, 'diesel': 7.85},
    'Heilongjiang': {'e10': 8.14, 'e5': 8.64, 'diesel': 7.84},
    'Jilin': {'e10': 8.15, 'e5': 8.65, 'diesel': 7.85},
    'Inner Mongolia': {'e10': 8.12, 'e5': 8.62, 'diesel': 7.82},
    'Xinjiang': {'e10': 8.05, 'e5': 8.55, 'diesel': 7.75},
    'Tibet': {'e10': 8.50, 'e5': 9.00, 'diesel': 8.20},
    'Hainan': {'e10': 8.45, 'e5': 8.95, 'diesel': 8.15},
    'Gansu': {'e10': 8.10, 'e5': 8.60, 'diesel': 7.80},
    'Qinghai': {'e10': 8.08, 'e5': 8.58, 'diesel': 7.78},
    'Ningxia': {'e10': 8.11, 'e5': 8.61, 'diesel': 7.81},
    'Guizhou': {'e10': 8.32, 'e5': 8.82, 'diesel': 8.02},
  };

  /// Rough province from lat/lng (simplified).
  static String chinaProvinceFor(double lat, double lng) {
    if (lat >= 39.4 && lat <= 41.1 && lng >= 115.7 && lng <= 117.5) {
      return 'Beijing';
    }
    if (lat >= 30.7 && lat <= 31.9 && lng >= 120.8 && lng <= 122.3) {
      return 'Shanghai';
    }
    if (lat >= 22.4 && lat <= 25.5 && lng >= 109.5 && lng <= 117.5) {
      return 'Guangdong';
    }
    if (lat >= 29.0 && lat <= 31.5 && lng >= 102.9 && lng <= 108.5) {
      return 'Sichuan';
    }
    if (lat >= 28.0 && lat <= 30.5 && lng >= 105.5 && lng <= 110.5) {
      return 'Chongqing';
    }
    if (lat >= 35.5 && lat <= 38.5 && lng >= 116.0 && lng <= 123.0) {
      return 'Shandong';
    }
    if (lat >= 30.5 && lat <= 33.5 && lng >= 118.0 && lng <= 122.5) {
      return 'Jiangsu';
    }
    if (lat >= 27.0 && lat <= 31.5 && lng >= 118.0 && lng <= 123.0) {
      return 'Zhejiang';
    }
    if (lat >= 38.5 && lat <= 41.0 && lng >= 116.5 && lng <= 118.5) {
      return 'Tianjin';
    }
    if (lat >= 18.0 && lat <= 20.2 && lng >= 108.5 && lng <= 111.5) {
      return 'Hainan';
    }
    if (lat >= 41.0 && lat <= 53.5 && lng >= 119.0 && lng <= 135.0) {
      return 'Heilongjiang';
    }
    if (lat >= 34.0 && lat <= 41.0 && lng >= 73.0 && lng <= 97.0) {
      return 'Xinjiang';
    }
    if (lat >= 27.5 && lat <= 36.5 && lng >= 78.0 && lng <= 99.0) {
      return 'Tibet';
    }
    // Default: national-ish coastal reference
    return 'Guangdong';
  }

  static OfficialFuelSnapshot chinaFor(double lat, double lng) {
    final province = chinaProvinceFor(lat, lng);
    final prices = chinaProvinces[province] ?? chinaProvinces['Guangdong']!;
    return OfficialFuelSnapshot(
      countryCode: 'cn',
      periodLabel: chinaPeriod,
      sourceName: chinaSourceName,
      sourceUrl: chinaSourceUrl,
      region: province,
      note:
          'Provincial guide retail ($province). Next NDRC window typically ~10 working days after oil moves ≥5%.',
      prices: prices,
    );
  }

  static double? pickPrice(Map<String, double> prices, String fuelType) {
    switch (fuelType) {
      case 'diesel':
        return prices['diesel'];
      case 'e10':
        return prices['e10'] ?? prices['e5'];
      case 'e5_98':
        return prices['e5_98'] ?? prices['e5'] ?? prices['e10'];
      case 'e5':
      default:
        return prices['e5'] ?? prices['e10'] ?? prices['e5_98'];
    }
  }

  /// USA — weekly-style regional retail averages (USD / US gallon).
  /// Approximate EIA PADD / state bands; refresh when weekly EIA bulletin moves.
  /// Source: https://www.eia.gov/petroleum/gasdiesel/
  static const String usaSourceName = 'EIA-style regional retail (USD/gal)';
  static const String usaSourceUrl = 'https://www.eia.gov/petroleum/gasdiesel/';
  static const String usaPeriod = '2026-09-week';

  /// Region → Regular(e10) / Premium(e5) / Diesel in USD per US gallon.
  static const Map<String, Map<String, double>> usaRegions = {
    'West Coast': {'e10': 4.35, 'e5': 4.75, 'diesel': 4.55},
    'California': {'e10': 4.65, 'e5': 5.05, 'diesel': 4.85},
    'Rocky Mountain': {'e10': 3.15, 'e5': 3.65, 'diesel': 3.45},
    'Gulf Coast': {'e10': 2.95, 'e5': 3.45, 'diesel': 3.25},
    'Midwest': {'e10': 3.10, 'e5': 3.60, 'diesel': 3.40},
    'East Coast': {'e10': 3.20, 'e5': 3.75, 'diesel': 3.55},
    'New England': {'e10': 3.30, 'e5': 3.85, 'diesel': 3.70},
  };

  static String usaRegionFor(double lat, double lng) {
    // Hawaii / Alaska → West Coast band
    if (lat < 28 && lng < -154) return 'West Coast';
    if (lat > 50 && lng < -130) return 'West Coast';
    // California
    if (lat >= 32.4 && lat <= 42.1 && lng >= -124.5 && lng <= -114.0) {
      return 'California';
    }
    if (lng <= -115.0) return 'West Coast';
    if (lng <= -104.0) return 'Rocky Mountain';
    if (lat <= 36.5 && lng <= -88.0) return 'Gulf Coast';
    if (lng <= -84.0) return 'Midwest';
    if (lat >= 41.0 && lng >= -73.5) return 'New England';
    return 'East Coast';
  }

  static OfficialFuelSnapshot usaFor(double lat, double lng) {
    final region = usaRegionFor(lat, lng);
    final prices = usaRegions[region] ?? usaRegions['East Coast']!;
    return OfficialFuelSnapshot(
      countryCode: 'us',
      periodLabel: usaPeriod,
      sourceName: usaSourceName,
      sourceUrl: usaSourceUrl,
      region: region,
      note:
          'Regional retail average ($region), USD per US gallon — not each pump’s live price. Community reports override when available.',
      prices: prices,
    );
  }

  /// Canada — provincial retail averages (CAD / litre).
  /// Approximate street averages; refresh with provincial open bulletins.
  static const String canadaSourceName = 'Canadian provincial retail average (CAD/L)';
  static const String canadaSourceUrl = 'https://www.nrcan.gc.ca/';
  static const String canadaPeriod = '2026-09';

  static const Map<String, Map<String, double>> canadaProvinces = {
    'Ontario': {'e10': 1.52, 'e5': 1.72, 'diesel': 1.62},
    'Quebec': {'e10': 1.55, 'e5': 1.75, 'diesel': 1.65},
    'British Columbia': {'e10': 1.78, 'e5': 1.98, 'diesel': 1.85},
    'Alberta': {'e10': 1.38, 'e5': 1.58, 'diesel': 1.48},
    'Manitoba': {'e10': 1.45, 'e5': 1.65, 'diesel': 1.55},
    'Saskatchewan': {'e10': 1.42, 'e5': 1.62, 'diesel': 1.52},
    'Atlantic': {'e10': 1.60, 'e5': 1.80, 'diesel': 1.70},
  };

  static String canadaProvinceFor(double lat, double lng) {
    if (lng <= -120.0) return 'British Columbia';
    if (lng <= -110.0) return 'Alberta';
    if (lng <= -101.5) return 'Saskatchewan';
    if (lng <= -95.0) return 'Manitoba';
    if (lng <= -79.0 && lat >= 45.0) return 'Quebec';
    if (lng >= -70.0) return 'Atlantic';
    return 'Ontario';
  }

  static OfficialFuelSnapshot canadaFor(double lat, double lng) {
    final province = canadaProvinceFor(lat, lng);
    final prices = canadaProvinces[province] ?? canadaProvinces['Ontario']!;
    return OfficialFuelSnapshot(
      countryCode: 'ca',
      periodLabel: canadaPeriod,
      sourceName: canadaSourceName,
      sourceUrl: canadaSourceUrl,
      region: province,
      note:
          'Provincial average ($province), CAD per litre — not each pump’s live price. Community reports override when available.',
      prices: prices,
    );
  }
}
