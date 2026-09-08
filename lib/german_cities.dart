String foldGermanPlaceQuery(String input) {
  var s = input.trim().toLowerCase();
  const replacements = <String, String>{
    'ä': 'ae',
    'ö': 'oe',
    'ü': 'ue',
    'ß': 'ss',
    'آ': 'ا',
    'ي': 'ی',
    'ك': 'ک',
  };
  replacements.forEach((from, to) {
    s = s.replaceAll(from, to);
  });
  s = s.replaceAll(RegExp(r'[.,;:()/_\-+]+'), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class GermanCityHit {
  final String displayName;
  final double lat;
  final double lng;

  const GermanCityHit({
    required this.displayName,
    required this.lat,
    required this.lng,
  });

  Map<String, String> toPlace() => {
        'display_name': displayName,
        'lat': lat.toString(),
        'lon': lng.toString(),
      };
}

class _GermanCity {
  final String display;
  final double lat;
  final double lng;
  final List<String> aliases;

  const _GermanCity(this.display, this.lat, this.lng, this.aliases);
}

const _germanCities = <_GermanCity>[
  _GermanCity('Berlin', 52.5200, 13.4050, ['berlin', 'berliin', 'برلین']),
  _GermanCity('Hamburg', 53.5511, 9.9937, ['hamburg', 'hamborg', 'هامبورگ']),
  _GermanCity('München', 48.1351, 11.5820, ['munchen', 'muenchen', 'munich', 'مونیخ', 'مونشن']),
  _GermanCity('Köln', 50.9375, 6.9603, ['koln', 'koeln', 'cologne', 'cologn', 'کلن', 'کلون', 'کلن آلمان']),
  _GermanCity('Frankfurt am Main', 50.1109, 8.6821, ['frankfurt', 'frankfurt am main', 'frankfurt main', 'فرانکفورت']),
  _GermanCity('Stuttgart', 48.7758, 9.1829, ['stuttgart', 'اشتوتگارت', 'شتوتگارت']),
  _GermanCity('Düsseldorf', 51.2277, 6.7735, ['dusseldorf', 'duesseldorf', 'dusseldrof', 'دوسلدورف', 'دوسلدورف آلمان']),
  _GermanCity('Leipzig', 51.3397, 12.3731, ['leipzig', 'لایپزیگ', 'لایپزیگ']),
  _GermanCity('Dortmund', 51.5136, 7.4653, ['dortmund', 'دورتموند']),
  _GermanCity('Essen', 51.4556, 7.0116, ['essen', 'اسن']),
  _GermanCity('Bremen', 53.0793, 8.8017, ['bremen', 'برمن']),
  _GermanCity('Dresden', 51.0504, 13.7373, ['dresden', 'درسدن', 'درسدن']),
  _GermanCity('Hannover', 52.3759, 9.7320, ['hannover', 'hanover', 'هانوفر', 'هانوور']),
  _GermanCity('Nürnberg', 49.4521, 11.0767, ['nurnberg', 'nuernberg', 'nuremberg', 'نورنبرگ']),
  _GermanCity('Duisburg', 51.4344, 6.7623, ['duisburg', 'دویسبورگ']),
  _GermanCity('Bochum', 51.4818, 7.2162, ['bochum', 'بوخوم']),
  _GermanCity('Wuppertal', 51.2562, 7.1508, ['wuppertal', 'ووپرتال']),
  _GermanCity('Bielefeld', 52.0302, 8.5325, ['bielefeld', 'بیله فلد', 'بیله‌فلد']),
  _GermanCity('Bonn', 50.7374, 7.0982, ['bonn', 'بن']),
  _GermanCity('Münster', 51.9607, 7.6261, ['munster', 'muenster', 'مونستر']),
  _GermanCity('Karlsruhe', 49.0069, 8.4037, ['karlsruhe', 'کارلسروهه']),
  _GermanCity('Mannheim', 49.4875, 8.4660, ['mannheim', 'مانهایم']),
  _GermanCity('Augsburg', 48.3705, 10.8978, ['augsburg', 'آگسبورگ']),
  _GermanCity('Wiesbaden', 50.0782, 8.2398, ['wiesbaden', 'ویسبادن']),
  _GermanCity('Mönchengladbach', 51.1805, 6.4428, ['monchengladbach', 'moenchengladbach', 'gladbach', 'مونشن گلادباخ']),
  _GermanCity('Gelsenkirchen', 51.5177, 7.0857, ['gelsenkirchen', 'گلزنکیرشن']),
  _GermanCity('Aachen', 50.7753, 6.0839, ['aachen', 'aix la chapelle', 'آخن']),
  _GermanCity('Braunschweig', 52.2689, 10.5268, ['braunschweig', 'brunswick', 'براونشوایگ']),
  _GermanCity('Kiel', 54.3233, 10.1228, ['kiel', 'کیل']),
  _GermanCity('Chemnitz', 50.8278, 12.9214, ['chemnitz', 'کمنیتس']),
  _GermanCity('Halle (Saale)', 51.4825, 11.9700, ['halle', 'halle saale', 'هاله']),
  _GermanCity('Magdeburg', 52.1205, 11.6276, ['magdeburg', 'ماگدبورگ']),
  _GermanCity('Freiburg im Breisgau', 47.9990, 7.8421, ['freiburg', 'freiburg im breisgau', 'فرایبورگ']),
  _GermanCity('Krefeld', 51.3392, 6.5853, ['krefeld', 'کرفلد']),
  _GermanCity('Mainz', 49.9929, 8.2473, ['mainz', 'ماینتس', 'ماینز']),
  _GermanCity('Lübeck', 53.8655, 10.6866, ['lubeck', 'luebeck', 'لوبک']),
  _GermanCity('Erfurt', 50.9848, 11.0299, ['erfurt', 'ارفورت']),
  _GermanCity('Oberhausen', 51.4963, 6.8636, ['oberhausen', 'اوبرهاوزن']),
  _GermanCity('Rostock', 54.0924, 12.0991, ['rostock', 'روستوک']),
  _GermanCity('Kassel', 51.3127, 9.4797, ['kassel', 'کاسل']),
  _GermanCity('Hagen', 51.3671, 7.4633, ['hagen', 'هاگن']),
  _GermanCity('Potsdam', 52.3906, 13.0645, ['potsdam', 'پوتسدام']),
  _GermanCity('Saarbrücken', 49.2402, 6.9969, ['saarbrucken', 'saarbruecken', 'زاربروکن']),
  _GermanCity('Hamm', 51.6739, 7.8150, ['hamm', 'هام']),
  _GermanCity('Ludwigshafen', 49.4774, 8.4452, ['ludwigshafen', 'لودویگسهافن']),
  _GermanCity('Mülheim an der Ruhr', 51.4186, 6.8845, ['mulheim', 'muelheim', 'mulheim an der ruhr', 'مولهایم']),
  _GermanCity('Oldenburg', 53.1435, 8.2146, ['oldenburg', 'اولدنبورگ']),
  _GermanCity('Osnabrück', 52.2799, 8.0472, ['osnabruck', 'osnabrueck', 'اسنابروک']),
  _GermanCity('Leverkusen', 51.0459, 7.0192, ['leverkusen', 'لورکوزن']),
  _GermanCity('Heidelberg', 49.3988, 8.6724, ['heidelberg', 'هایدلبرگ']),
  _GermanCity('Solingen', 51.1652, 7.0671, ['solingen', 'زولینگن']),
  _GermanCity('Darmstadt', 49.8728, 8.6512, ['darmstadt', 'دارمشتات']),
  _GermanCity('Herne', 51.5369, 7.2009, ['herne', 'هرنه']),
  _GermanCity('Neuss', 51.2042, 6.6880, ['neuss', 'نویس']),
  _GermanCity('Regensburg', 49.0134, 12.1000, ['regensburg', 'رگنسبورگ']),
  _GermanCity('Paderborn', 51.7189, 8.7544, ['paderborn', 'پادربورن']),
  _GermanCity('Ingolstadt', 48.7665, 11.4257, ['ingolstadt', 'اینگولشتات']),
  _GermanCity('Würzburg', 49.7913, 9.9534, ['wurzburg', 'wuerzburg', 'ورتسبورگ']),
  _GermanCity('Fürth', 49.4771, 10.9887, ['furth', 'fuerth', 'فورت']),
  _GermanCity('Ulm', 48.4011, 9.9876, ['ulm', 'اولم']),
  _GermanCity('Heilbronn', 49.1427, 9.2109, ['heilbronn', 'هایلبرون']),
  _GermanCity('Pforzheim', 48.8922, 8.6946, ['pforzheim', 'پفورتسهایم']),
  _GermanCity('Wolfsburg', 52.4227, 10.7865, ['wolfsburg', 'ولفسبورگ']),
  _GermanCity('Göttingen', 51.5413, 9.9158, ['gottingen', 'goettingen', 'گوتینگن']),
  _GermanCity('Bottrop', 51.5291, 6.9447, ['bottrop', 'بوتروپ']),
  _GermanCity('Reutlingen', 48.4914, 9.2043, ['reutlingen', 'رویتلینگن']),
  _GermanCity('Koblenz', 50.3569, 7.5890, ['koblenz', 'کوبلنتس']),
  _GermanCity('Bremerhaven', 53.5396, 8.5809, ['bremerhaven', 'برمرهافن']),
  _GermanCity('Recklinghausen', 51.6141, 7.1979, ['recklinghausen', 'رکلینگهاوزن']),
  _GermanCity('Bergisch Gladbach', 50.9856, 7.1320, ['bergisch gladbach', 'برگیش گلادباخ']),
  _GermanCity('Erlangen', 49.5897, 11.0120, ['erlangen', 'ارلانگن']),
  _GermanCity('Jena', 50.9271, 11.5892, ['jena', 'ینا']),
  _GermanCity('Remscheid', 51.1786, 7.1890, ['remscheid', 'رمشاید']),
  _GermanCity('Trier', 49.7499, 6.6371, ['trier', 'تریر']),
  _GermanCity('Moers', 51.4513, 6.6405, ['moers', 'مورس']),
  _GermanCity('Salzgitter', 52.1503, 10.3493, ['salzgitter', 'زالزگیتر']),
  _GermanCity('Siegen', 50.8750, 8.0220, ['siegen', 'زیگن']),
  _GermanCity('Hildesheim', 52.1508, 9.9513, ['hildesheim', 'هیلدسهایم']),
  _GermanCity('Gütersloh', 51.9032, 8.3858, ['gutersloh', 'guetersloh', 'گوترسلوه']),
  _GermanCity('Kaiserslautern', 49.4401, 7.7491, ['kaiserslautern', 'کایزرسلاترن']),
  _GermanCity('Schwerin', 53.6355, 11.4012, ['schwerin', 'شورین']),
  _GermanCity('Esslingen', 48.7396, 9.3068, ['esslingen', 'اسلینگن']),
  _GermanCity('Ludwigsburg', 48.8974, 9.1916, ['ludwigsburg', 'لودویگسبورگ']),
  _GermanCity('Flensburg', 54.7937, 9.4469, ['flensburg', 'فلنسبورگ']),
  _GermanCity('Gera', 50.8806, 12.0820, ['gera', 'گرا']),
  _GermanCity('Cottbus', 51.7563, 14.3329, ['cottbus', 'کوتبوس']),
  _GermanCity('Witten', 51.4436, 7.3526, ['witten', 'ویتن']),
  _GermanCity('Iserlohn', 51.3753, 7.6990, ['iserlohn', 'ایزرلون']),
  _GermanCity('Düren', 50.8029, 6.4870, ['duren', 'dueren', 'دورن']),
  _GermanCity('Tübingen', 48.5216, 9.0576, ['tubingen', 'tuebingen', 'توبینگن']),
  _GermanCity('Gießen', 50.5840, 8.6784, ['giessen', 'giesen', 'گیسن']),
  _GermanCity('Hanau', 50.1260, 8.9280, ['hanau', 'هانائو']),
  _GermanCity('Schwerin', 53.6355, 11.4012, ['schwerin']),
  _GermanCity('Konstanz', 47.6779, 9.1732, ['konstanz', 'constance', 'کنستانس']),
  _GermanCity('Weimar', 50.9795, 11.3235, ['weimar', 'وایمر']),
  _GermanCity('Bamberg', 49.8988, 10.9028, ['bamberg', 'بامبرگ']),
  _GermanCity('Bayreuth', 49.9456, 11.5713, ['bayreuth', 'بایرویت']),
  _GermanCity('Passau', 48.5667, 13.4319, ['passau', 'پاسائو']),
  _GermanCity('Rosenheim', 47.8561, 12.1289, ['rosenheim', 'روزنهایم']),
  _GermanCity('Offenbach', 50.0956, 8.7761, ['offenbach', 'اوفنباخ']),
  _GermanCity('Marburg', 50.8021, 8.7667, ['marburg', 'ماربورگ']),
  _GermanCity('Fulda', 50.5558, 9.6808, ['fulda', 'فولدا']),
  _GermanCity('Göttingen', 51.5413, 9.9158, ['gottingen', 'goettingen']),
  _GermanCity('Lüneburg', 53.2464, 10.4115, ['luneburg', 'lueneburg', 'لونبورگ']),
  _GermanCity('Stralsund', 54.3091, 13.0819, ['stralsund', 'اشترالزوند']),
  _GermanCity('Wismar', 53.8925, 11.4529, ['wismar', 'ویسمار']),
  _GermanCity('Greifswald', 54.0865, 13.3923, ['greifswald', 'گرایفسوالد']),
  _GermanCity('Cuxhaven', 53.8617, 8.6940, ['cuxhaven', 'کوکسهافن']),
  _GermanCity('Emden', 53.3675, 7.2060, ['emden', 'امدن']),
  _GermanCity('Wilhelmshaven', 53.5224, 8.1069, ['wilhelmshaven', 'ویلهلمسهافن']),
  _GermanCity('Bocholt', 51.8384, 6.6153, ['bocholt', 'بوخولت']),
  _GermanCity('Ratingen', 51.2964, 6.8493, ['ratingen', 'راتینگن']),
  _GermanCity('Velbert', 51.3400, 7.0430, ['velbert', 'فلبرت']),
  _GermanCity('Viersen', 51.2562, 6.3905, ['viersen', 'فیرزن']),
  _GermanCity('Minden', 52.2905, 8.9167, ['minden', 'میندن']),
  _GermanCity('Detmold', 51.9380, 8.8783, ['detmold', 'دتمولد']),
  _GermanCity('Paderborn', 51.7189, 8.7544, ['paderborn']),
  _GermanCity('Goslar', 51.9060, 10.4292, ['goslar', 'گوسلا']),
  _GermanCity('Celle', 52.6226, 10.0805, ['celle', 'سله']),
  _GermanCity('Wolfsburg', 52.4227, 10.7865, ['wolfsburg']),
  _GermanCity('Dessau-Roßlau', 51.8308, 12.2300, ['dessau', 'dessau rosslau', 'دسائو']),
  _GermanCity('Zwickau', 50.7181, 12.4937, ['zwickau', 'تسویکاو']),
  _GermanCity('Plauen', 50.4976, 12.1360, ['plauen', 'پلاوئن']),
  _GermanCity('Hof', 50.3131, 11.9128, ['hof', 'هوف']),
  _GermanCity('Schweinfurt', 50.0489, 10.2333, ['schweinfurt', 'شواینفورت']),
  _GermanCity('Aschaffenburg', 49.9770, 9.1521, ['aschaffenburg', 'آشافنبورگ']),
  _GermanCity('Landshut', 48.5442, 12.1469, ['landshut', 'لاندسهوت']),
  _GermanCity('Kempten', 47.7267, 10.3168, ['kempten', 'کمپتن']),
  _GermanCity('Ravensburg', 47.7810, 9.6100, ['ravensburg', 'راونسبورگ']),
  _GermanCity('Friedrichshafen', 47.6567, 9.4650, ['friedrichshafen', 'فریدریشهافن']),
  _GermanCity('Singen', 47.7590, 8.8400, ['singen', 'زینگن']),
  _GermanCity('Offenburg', 48.4733, 7.9450, ['offenburg', 'اوفنبورگ']),
  _GermanCity('Baden-Baden', 48.7606, 8.2397, ['baden baden', 'baden-baden', 'بادن بادن']),
  _GermanCity('Sindelfingen', 48.7130, 9.0030, ['sindelfingen', 'زیندلفینگن']),
  _GermanCity('Reutlingen', 48.4914, 9.2043, ['reutlingen']),
  _GermanCity('Tübingen', 48.5216, 9.0576, ['tubingen', 'tuebingen']),
  _GermanCity('Ulm', 48.4011, 9.9876, ['ulm']),
  _GermanCity('Aalen', 48.8378, 10.0933, ['aalen', 'الن']),
  _GermanCity('Schwäbisch Gmünd', 48.7995, 9.7981, ['schwabisch gmund', 'schwaebisch gmuend']),
  _GermanCity('Göppingen', 48.7025, 9.6520, ['goppingen', 'goeppingen', 'گوپینگن']),
  _GermanCity('Heilbronn', 49.1427, 9.2109, ['heilbronn']),
  _GermanCity('Speyer', 49.3172, 8.4311, ['speyer', 'اشپایر']),
  _GermanCity('Worms', 49.6341, 8.3500, ['worms', 'ورمس']),
  _GermanCity('Ludwigshafen', 49.4774, 8.4452, ['ludwigshafen']),
  _GermanCity('Neustadt an der Weinstraße', 49.3500, 8.1380, ['neustadt', 'neustadt weinstrasse']),
  _GermanCity('Kaiserslautern', 49.4401, 7.7491, ['kaiserslautern']),
  _GermanCity('Trier', 49.7499, 6.6371, ['trier']),
  _GermanCity('Saarlouis', 49.3133, 6.7517, ['saarlouis', 'زارلوئیس']),
  _GermanCity('Neunkirchen', 49.3440, 7.1800, ['neunkirchen', 'نوینکیرشن']),
  _GermanCity('Homburg', 49.3264, 7.3389, ['homburg', 'هومبورگ']),
  _GermanCity('Idar-Oberstein', 49.7056, 7.3078, ['idar oberstein']),
  _GermanCity('Koblenz', 50.3569, 7.5890, ['koblenz']),
  _GermanCity('Andernach', 50.4310, 7.4040, ['andernach']),
  _GermanCity('Siegburg', 50.8000, 7.2070, ['siegburg', 'زیگبورگ']),
  _GermanCity('Troisdorf', 50.8090, 7.1550, ['troisdorf', 'ترویسدورف']),
  _GermanCity('Sankt Augustin', 50.7750, 7.1890, ['sankt augustin', 'سنت آوگوستین']),
  _GermanCity('Bergheim', 50.9557, 6.6399, ['bergheim', 'برگهایم']),
  _GermanCity('Kerpen', 50.8730, 6.6950, ['kerpen', 'کرپن']),
  _GermanCity('Hürth', 50.8700, 6.8760, ['hurth', 'huerth', 'هورث']),
  _GermanCity('Frechen', 50.9130, 6.8110, ['frechen', 'فرشن']),
  _GermanCity('Brühl', 50.8290, 6.9050, ['bruhl', 'bruehl', 'برول']),
  _GermanCity('Leverkusen', 51.0459, 7.0192, ['leverkusen']),
  _GermanCity('Solingen', 51.1652, 7.0671, ['solingen']),
  _GermanCity('Remscheid', 51.1786, 7.1890, ['remscheid']),
  _GermanCity('Wuppertal', 51.2562, 7.1508, ['wuppertal']),
  _GermanCity('Hagen', 51.3671, 7.4633, ['hagen']),
  _GermanCity('Iserlohn', 51.3753, 7.6990, ['iserlohn']),
  _GermanCity('Unna', 51.5380, 7.6890, ['unna', 'اونا']),
  _GermanCity('Hamm', 51.6739, 7.8150, ['hamm']),
  _GermanCity('Münster', 51.9607, 7.6261, ['munster', 'muenster']),
  _GermanCity('Rheine', 52.2850, 7.4330, ['rheine', 'راینه']),
  _GermanCity('Nordhorn', 52.4310, 7.0680, ['nordhorn', 'نوردهورن']),
  _GermanCity('Lingen', 52.5210, 7.3180, ['lingen', 'لینگن']),
  _GermanCity('Meppen', 52.6910, 7.2910, ['meppen', 'مپن']),
  _GermanCity('Cloppenburg', 52.8480, 8.0450, ['cloppenburg']),
  _GermanCity('Vechta', 52.7260, 8.2860, ['vechta']),
  _GermanCity('Delmenhorst', 53.0510, 8.6320, ['delmenhorst']),
  _GermanCity('Oldenburg', 53.1435, 8.2146, ['oldenburg']),
  _GermanCity('Wilhelmshaven', 53.5224, 8.1069, ['wilhelmshaven']),
  _GermanCity('Cuxhaven', 53.8617, 8.6940, ['cuxhaven']),
  _GermanCity('Stade', 53.5940, 9.4760, ['stade', 'شتاده']),
  _GermanCity('Lüneburg', 53.2464, 10.4115, ['luneburg', 'lueneburg']),
  _GermanCity('Uelzen', 52.9650, 10.5580, ['uelzen', 'اولتسن']),
  _GermanCity('Gifhorn', 52.4790, 10.5460, ['gifhorn']),
  _GermanCity('Peine', 52.3190, 10.2350, ['peine', 'پاینه']),
  _GermanCity('Salzgitter', 52.1503, 10.3493, ['salzgitter']),
  _GermanCity('Goslar', 51.9060, 10.4292, ['goslar']),
  _GermanCity('Hildesheim', 52.1508, 9.9513, ['hildesheim']),
  _GermanCity('Hameln', 52.1040, 9.3570, ['hameln', 'هاملن']),
  _GermanCity('Minden', 52.2905, 8.9167, ['minden']),
  _GermanCity('Herford', 52.1220, 8.6770, ['herford', 'هرفورد']),
  _GermanCity('Bielefeld', 52.0302, 8.5325, ['bielefeld']),
  _GermanCity('Gütersloh', 51.9032, 8.3858, ['gutersloh', 'guetersloh']),
  _GermanCity('Paderborn', 51.7189, 8.7544, ['paderborn']),
  _GermanCity('Detmold', 51.9380, 8.8783, ['detmold']),
  _GermanCity('Höxter', 51.7740, 9.3810, ['hoxter', 'hoexter']),
  _GermanCity('Kassel', 51.3127, 9.4797, ['kassel']),
  _GermanCity('Göttingen', 51.5413, 9.9158, ['gottingen', 'goettingen']),
  _GermanCity('Eisenach', 50.9740, 10.3190, ['eisenach', 'آیزناخ']),
  _GermanCity('Gotha', 50.9480, 10.7020, ['gotha', 'گوتا']),
  _GermanCity('Erfurt', 50.9848, 11.0299, ['erfurt']),
  _GermanCity('Weimar', 50.9795, 11.3235, ['weimar']),
  _GermanCity('Jena', 50.9271, 11.5892, ['jena']),
  _GermanCity('Gera', 50.8806, 12.0820, ['gera']),
  _GermanCity('Altenburg', 50.9850, 12.4330, ['altenburg']),
  _GermanCity('Chemnitz', 50.8278, 12.9214, ['chemnitz']),
  _GermanCity('Zwickau', 50.7181, 12.4937, ['zwickau']),
  _GermanCity('Plauen', 50.4976, 12.1360, ['plauen']),
  _GermanCity('Hof', 50.3131, 11.9128, ['hof']),
  _GermanCity('Bayreuth', 49.9456, 11.5713, ['bayreuth']),
  _GermanCity('Bamberg', 49.8988, 10.9028, ['bamberg']),
  _GermanCity('Coburg', 50.2590, 10.9640, ['coburg', 'کوبورگ']),
  _GermanCity('Schweinfurt', 50.0489, 10.2333, ['schweinfurt']),
  _GermanCity('Würzburg', 49.7913, 9.9534, ['wurzburg', 'wuerzburg']),
  _GermanCity('Aschaffenburg', 49.9770, 9.1521, ['aschaffenburg']),
  _GermanCity('Darmstadt', 49.8728, 8.6512, ['darmstadt']),
  _GermanCity('Offenbach', 50.0956, 8.7761, ['offenbach']),
  _GermanCity('Hanau', 50.1260, 8.9280, ['hanau']),
  _GermanCity('Giessen', 50.5840, 8.6784, ['giessen', 'giesen', 'گیسن']),
  _GermanCity('Wetzlar', 50.5610, 8.5050, ['wetzlar', 'وتسلار']),
  _GermanCity('Marburg', 50.8021, 8.7667, ['marburg']),
  _GermanCity('Fulda', 50.5558, 9.6808, ['fulda']),
  _GermanCity('Bad Homburg', 50.2270, 8.6180, ['bad homburg']),
  _GermanCity('Rüsselsheim', 49.9950, 8.4120, ['russelsheim', 'ruesselsheim']),
  _GermanCity('Mainz', 49.9929, 8.2473, ['mainz']),
  _GermanCity('Wiesbaden', 50.0782, 8.2398, ['wiesbaden']),
];

List<String> germanPlaceQueryVariants(String query) {
  final original = query.trim();
  final folded = foldGermanPlaceQuery(original);
  final variants = <String>{};
  if (original.isNotEmpty) variants.add(original);
  if (folded.isNotEmpty) variants.add(folded);
  for (final city in _germanCities) {
    for (final alias in city.aliases) {
      if (foldGermanPlaceQuery(alias) == folded) {
        variants.add(city.display);
      }
    }
  }
  return variants.toList();
}

List<GermanCityHit> matchGermanCities(String query, {int limit = 8}) {
  final folded = foldGermanPlaceQuery(query);
  if (folded.isEmpty) return [];

  final exact = <GermanCityHit>[];
  final starts = <GermanCityHit>[];
  final contains = <GermanCityHit>[];
  final seen = <String>{};

  void add(List<GermanCityHit> bucket, _GermanCity city) {
    if (!seen.add(city.display)) return;
    bucket.add(GermanCityHit(
      displayName: '${city.display}, Deutschland',
      lat: city.lat,
      lng: city.lng,
    ));
  }

  for (final city in _germanCities) {
    final names = [foldGermanPlaceQuery(city.display), ...city.aliases.map(foldGermanPlaceQuery)];
    final isExactOrSavedDisplay = names.any(
      (name) =>
          name == folded ||
          folded == '$name deutschland' ||
          folded == '$name germany',
    );
    if (isExactOrSavedDisplay) {
      add(exact, city);
      continue;
    }
    if (folded.length >= 3 && names.any((n) => n.startsWith(folded))) {
      add(starts, city);
      continue;
    }
    if (folded.length >= 4 && names.any((n) => n.contains(folded))) {
      add(contains, city);
    }
  }

  return [...exact, ...starts, ...contains].take(limit).toList();
}
