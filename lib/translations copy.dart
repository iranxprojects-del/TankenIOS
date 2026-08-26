const List<Map<String, String>> supportedLanguages = [
  {'code': 'en', 'label': 'EN', 'native': 'English'},
  {'code': 'de', 'label': 'DE', 'native': 'Deutsch'},
  {'code': 'fa', 'label': 'FA', 'native': 'فارسی'},
  {'code': 'tr', 'label': 'TR', 'native': 'Türkçe'},
  {'code': 'ru', 'label': 'RU', 'native': 'Русский'},
  {'code': 'ar', 'label': 'AR', 'native': 'العربية'},
  {'code': 'uk', 'label': 'UK', 'native': 'Українська'},
  {'code': 'ro', 'label': 'RO', 'native': 'Română'},
  {'code': 'pl', 'label': 'PL', 'native': 'Polski'},
];

const Map<String, Map<String, String>> localizedStrings = {
  'app_title': {
    'en': 'Smart Fuel & Service',
    'de': 'Smarter Kraftstoff & Service',
    'fa': 'مدیریت هوشمند سوخت و سرویس',
    'tr': 'Akıllı Yakıt ve Servis',
    'ru': 'Умный бензин и сервис',
    'ar': 'الوقود والخدمة الذكية',
    'uk': 'Розумне паливо та сервіс',
    'ro': 'Combustibil și serviciu inteligent',
    'pl': 'Inteligentne paliwo i serwis',
  },'free_tier_expired': {
    'en': 'Free tier has expired',
    'de': 'Testphase abgelaufen',
    'fa': 'دوره رایگان تمام شده است',
    'tr': 'Ücretsiz deneme süresi bitti',
    'ru': 'Бесплатный период истек',
    'ar': 'انتهت الفترة التجريبية المجانية',
    'uk': 'Безкоштовний період закінчився',
    'ro': 'Perioada gratuită a expirat',
    'pl': 'Darmowy okres próbny wygasł',
  },
  'free_tier_remaining': {
    'en': 'Days remaining in free tier: ',
    'de': 'Verbleibende Tage der Testphase: ',
    'fa': 'روز از دوره رایگان باقی مانده: ',
    'tr': 'Ücretsiz deneme günleri kaldı: ',
    'ru': 'Осталось дней бесплатного периода: ',
    'ar': 'الأيام المتبقية في الفترة المجانية: ',
    'uk': 'Залишилося днів безкоштовного періоду: ',
    'ro': 'Zile rămase din perioada gratuită: ',
    'pl': 'Pozostałe dni darmowego okresu: ',
  },
  'settings': {
    'en': 'Settings', 'de': 'Einstellungen', 'fa': 'تنظیمات', 'tr': 'Ayarlar',
    'ru': 'Настройки', 'ar': 'الإعدادات', 'uk': 'Налаштування', 'ro': 'Setări', 'pl': 'Ustawienia',
  },
  'save': {
    'en': 'Save', 'de': 'Speichern', 'fa': 'ذخیره', 'tr': 'Kaydet',
    'ru': 'Сохранить', 'ar': 'حفظ', 'uk': 'Зберегти', 'ro': 'Salvează', 'pl': 'Zapisz',
  },
  'edit': {
    'en': 'Edit', 'de': 'Bearbeiten', 'fa': 'ویرایش', 'tr': 'Düzenle',
    'ru': 'Изменить', 'ar': 'تعديل', 'uk': 'Редагувати', 'ro': 'Editează', 'pl': 'Edytuj',
  },
  'delete': {
    'en': 'Delete', 'de': 'Löschen', 'fa': 'حذف', 'tr': 'Sil',
    'ru': 'Удалить', 'ar': 'حذف', 'uk': 'Видалити', 'ro': 'Șterge', 'pl': 'Usuń',
  },
  'edit_service_snack': {
    'en': 'Editing {type}. Old record removed. Update fields and save.',
    'de': 'Bearbeiten von {type}. Alter Datensatz entfernt. Felder aktualisieren und speichern.',
    'fa': 'در حال ویرایش {type}. رکورد قبلی حذف شد. فیلدها را تغییر داده و ذخیره کنید.',
    'tr': '{type} düzenleniyor. Eski kayıt kaldırıldı. Alanları güncelleyin ve kaydedin.',
    'ru': 'Редактирование {type}. Старая запись удалена. Обновите поля и сохраните.',
    'ar': 'جاري تعديل {type}. تمت إزالة السجل القديم. قم بتحديث الحقول والحفظ.',
    'uk': 'Редагування {type}. Старий запис видалено. Оновіть поля та збережіть.',
    'ro': 'Se editează {type}. Înregistrarea veche a fost ștearsă. Actualizați câmpurile și salvați.',
    'pl': 'Edytowanie {type}. Stary rekord usunięty. Zaktualizuj pola i zapisz.',
  },
  'fuel_alert_title': {
    'en': 'Fuel Price Alert! ⛽', 'de': 'Kraftstoffpreis-Alarm! ⛽', 'fa': 'هشدار قیمت سوخت! ⛽', 'tr': 'Yakıt Fiyatı Uyarısı! ⛽',
    'ru': 'Оповещение о цене на топливо! ⛽', 'ar': 'تنبيه سعر الوقود! ⛽', 'uk': 'Сповіщення про ціну на пальне! ⛽', 'ro': 'Alertă preț combustibil! ⛽', 'pl': 'Alert cenowy paliwa! ⛽',
  },
  'fuel_alert_body': {
    'en': 'Price at {station} is now €{price} (Below your €{target} target)',
    'de': 'Der Preis bei {station} beträgt jetzt €{price} (Unter Ihrem Ziel von €{target})',
    'fa': 'قیمت در {station} اکنون €{price} است (کمتر از هدف €{target} شما)',
    'tr': '{station} istasyonunda fiyat şimdi €{price} (Hedefiniz olan €{target} altı)',
    'ru': 'Цена на {station} теперь €{price} (Ниже вашей цели в €{target})',
    'ar': 'السعر في {station} الآن €{price} (أقل من هدفك البالغ €{target})',
    'uk': 'Ціна на {station} тепер €{price} (Нижче вашої цілі в €{target})',
    'ro': 'Prețul la {station} este acum €{price} (Sub ținta ta de €{target})',
    'pl': 'Cena na {station} wynosi teraz €{price} (Poniżej Twojego celu €{target})',
  },
  'morning_fuel_title': {
    'en': 'Morning Fuel Report ☕⛽', 'de': 'Morgendlicher Kraftstoffbericht ☕⛽', 'fa': 'گزارش صبحگاهی قیمت سوخت ☕⛽', 'tr': 'Sabah Yakıt Raporu ☕⛽',
    'ru': 'Утренний отчет по топливу ☕⛽', 'ar': 'تقرير الوقود الصباحي ☕⛽', 'uk': 'Ранковий звіт щодо пального ☕⛽', 'ro': 'Raportul matinal al combustibilului ☕⛽', 'pl': 'Poranny raport paliwowy ☕⛽',
  },
  'morning_fuel_body': {
    'en': 'Cheapest station nearby: {name} at €{price}',
    'de': 'Günstigste Tankstelle in der Nähe: {name} für €{price}',
    'fa': 'ارزان‌ترین پمپ بنزین نزدیک شما: {name} با قیمت €{price}',
    'tr': 'Yakındaki en ucuz istasyon: €{price} ile {name}',
    'ru': 'Самая дешевая заправка рядом: {name} за €{price}',
    'ar': 'أرخص محطة قريبة: {name} بسعر €{price}',
    'uk': 'Найдешевша заправка поруч: {name} за €{price}',
    'ro': 'Cea mai ieftină stație din apropiere: {name} la €{price}',
    'pl': 'Najtańsza stacja w pobliżu: {name} za €{price}',
  },
  'service_reminder_title': {
    'en': 'Car Service Reminder 🚗', 'de': 'Auto-Service Erinnerung 🚗', 'fa': 'یادآور سرویس ماشین 🚗', 'tr': 'Araç Servis Hatırlatıcısı 🚗',
    'ru': 'Напоминание об обслуживании 🚗', 'ar': 'تذكير بخدمة السيارة 🚗', 'uk': 'Нагадування про обслуговування 🚗', 'ro': 'Memento service auto 🚗', 'pl': 'Przypomnienie o serwisie 🚗',
  },
  'service_reminder_body': {
    'en': 'It is 09:00 AM! Please check your car oil and service status.',
    'de': 'Es ist 09:00 Uhr! Bitte überprüfen Sie den Ölstand und den Servicestatus.',
    'fa': 'ساعت ۰۹:۰۰ صبح است! لطفاً وضعیت روغن و سرویس ماشین را چک کنید.',
    'tr': 'Saat 09:00! Lütfen araba yağını ve servis durumunu kontrol edin.',
    'ru': 'Время 09:00! Пожалуйста, проверьте уровень масла и статус обслуживания автомобиля.',
    'ar': 'إنها الساعة 09:00 صباحاً! يرجى فحص زيت سيارتك وحالة الخدمة.',
    'uk': 'Час 09:00! Будь ласка, перевірте рівень масла та стан обслуговування автомобіля.',
    'ro': 'Este ora 09:00! Vă rugăm să verificați uleiul și starea de service.',
    'pl': 'Jest 09:00! Sprawdź poziom oleju i stan serwisowy samochodu.',
  },
  'fuel_live': {
    'en': 'Germany Fuel Live', 'de': 'Kraftstoff Live', 'fa': 'قیمت زنده سوخت', 'tr': 'Canlı Yakıt',
    'ru': 'Топливо онлайн', 'ar': 'أسعار الوقود المباشرة', 'uk': 'Пальне онлайн', 'ro': 'Combustibil Live', 'pl': 'Ceny paliw na żywo',
  },
  'car_service_parking': {
    'en': 'Car Service', 'de': 'Autoservice', 'fa': 'سرویس ماشین', 'tr': 'Araç Servisi',
    'ru': 'Автосервис', 'ar': 'خدمة السيارات', 'uk': 'Автосервіс', 'ro': 'Service Auto', 'pl': 'Serwis samochodowy',
  },
  'nav_fuel': {
    'en': 'Fuel',
  'de': 'Tanken',
  'fa': 'سوخت',
  'tr': 'Yakıt',
  'ru': 'Топливо',
  'ar': 'وقود',
  'uk': 'Пальне',
  'ro': 'Combustibil',
  'pl': 'Paliwo',
  },
  'nav_services': {
    'en': 'Car Service', 'de': 'Autoservice', 'fa': 'سرویس ماشین', 'tr': 'Araç Servisi',
    'ru': 'Автосервис', 'ar': 'خدمة السيارات', 'uk': 'Автосервіс', 'ro': 'Service Auto', 'pl': 'Serwis samochodowy',
  },
  'tab_car_service': {
    'en': 'Car Service', 'de': 'Autoservice', 'fa': 'سرویس ماشین', 'tr': 'Araç Servisi',
    'ru': 'Автосервис', 'ar': 'خدمة السيارات', 'uk': 'Автосервіс', 'ro': 'Service Auto', 'pl': 'Serwis samochodowy',
  },
  'maintenance_overview': {
    'en': 'Service Items Overview', 'de': 'Übersicht der Servicepunkte', 'fa': 'نمای کلی سرویس‌ها', 'tr': 'Servis Öğeleri Genel Bakış',
    'ru': 'Обзор элементов обслуживания', 'ar': 'نظرة عامة على عناصر الخدمة', 'uk': 'Огляд елементів обслуговування', 'ro': 'Prezentare generală a elementelor de service', 'pl': 'Przegląd elementów serwisowych',
  },
  'item': {
    'en': 'Item', 'de': 'Punkt', 'fa': 'آیتم', 'tr': 'Öğe',
    'ru': 'Пункт', 'ar': 'البند', 'uk': 'Пункт', 'ro': 'Element', 'pl': 'Element',
  },
  'mileage': {
    'en': 'Mileage', 'de': 'Kilometerstand', 'fa': 'کیلومتر', 'tr': 'Kilometre',
    'ru': 'Пробег', 'ar': 'المسافة', 'uk': 'Пробіг', 'ro': 'Kilometraj', 'pl': 'Przebieg',
  },
  'date': {
    'en': 'Date', 'de': 'Datum', 'fa': 'تاریخ', 'tr': 'Tarih',
    'ru': 'Дата', 'ar': 'التاريخ', 'uk': 'Дата', 'ro': 'Dată', 'pl': 'Data',
  },
  'contact': {
    'en': 'Contact', 'de': 'Kontakt', 'fa': 'تماس', 'tr': 'İletişim',
    'ru': 'Контакт', 'ar': 'اتصال', 'uk': 'Контакт', 'ro': 'Contact', 'pl': 'Kontakt',
  },
  'alarm': {
    'en': 'Alarm', 'de': 'Alarm', 'fa': 'هشدار', 'tr': 'Alarm',
    'ru': 'Будильник', 'ar': 'إنذار', 'uk': 'Тривога', 'ro': 'Alarmă', 'pl': 'Alarm',
  }, 
  'alarm_enabled': {
    'en': 'Alarm Enabled', 'de': 'Alarm aktiviert', 'fa': 'هشدار فعال است', 'tr': 'Alarm etkin',
    'ru': 'Сигнал включен', 'ar': 'التنبيه مفعل', 'uk': 'Тривога увімкнена', 'ro': 'Alarma activată', 'pl': 'Alarm włączony',
  },
  'alarm_disabled': {
    'en': 'Alarm Disabled', 'de': 'Alarm deaktiviert', 'fa': 'هشدار غیرفعال است', 'tr': 'Alarm devre dışı',
    'ru': 'Сигнал отключен', 'ar': 'التنبيه معطل', 'uk': 'Тривога вимкнена', 'ro': 'Alarma dezactivată', 'pl': 'Alarm wyłączony',
  },  'reminder_for': {
    'en': 'Reminder for', 'de': 'Erinnerung für', 'fa': 'یادآوری برای', 'tr': 'Hatırlatma için',
    'ru': 'Напоминание для', 'ar': 'تذكير لـ', 'uk': 'Нагадування для', 'ro': 'Memento pentru', 'pl': 'Przypomnienie dla',
  },
  'reminder_before_due': {
    'en': 'Days before due', 'de': 'Tage vor Fälligkeit', 'fa': 'روز قبل از موعد', 'tr': 'Vadesinden önceki günler',
    'ru': 'Дней до срока', 'ar': 'أيام قبل الموعد', 'uk': 'Днів до терміну', 'ro': 'Zile înainte de scadență', 'pl': 'Dni przed terminem',
  },
  'set_date_first': {
    'en': 'Set the service date first.', 'de': 'Zuerst das Servicedatum festlegen.', 'fa': 'ابتدا تاریخ سرویس را تنظیم کنید.', 'tr': 'Önce servis tarihini ayarlayın.',
    'ru': 'Сначала установите дату обслуживания.', 'ar': 'حدد تاريخ الخدمة أولاً.', 'uk': 'Спочатку встановіть дату обслуговування.', 'ro': 'Setați mai întâi data serviciului.', 'pl': 'Najpierw ustaw datę serwisu.',
  },
  'reminder_info': {
    'en': 'Reminder will alert you {days} days before the due date.', 'de': 'Die Erinnerung benachrichtigt Sie {days} Tage vor Fälligkeit.', 'fa': 'یادآور {days} روز قبل از موعد سرویس به شما اطلاع می‌دهد.', 'tr': 'Hatırlatıcı, vade tarihinden {days} gün önce sizi uyaracak.',
    'ru': 'Напоминание уведомит вас за {days} дней до срока.', 'ar': 'سيقوم التذكير بتنبيهك قبل {days} يومًا من الموعد.', 'uk': 'Нагадування повідомить вас за {days} днів до терміну.', 'ro': 'Memento te va alerta cu {days} zile înainte de data scadenței.', 'pl': 'Przypomnienie powiadomi Cię {days} dni przed terminem.',
  },  'map_view': {
    'en': 'Map View', 'de': 'Kartenansicht', 'fa': 'نمای نقشه', 'tr': 'Harita Görünümü',
    'ru': 'Вид карты', 'ar': 'عرض الخريطة', 'uk': 'Вигляд карти', 'ro': 'Vizualizare hartă', 'pl': 'Widok mapy',
  },
  'list_view': {
    'en': 'List View', 'de': 'Listenansicht', 'fa': 'نمای لیست', 'tr': 'Liste Görünümü',
    'ru': 'Вид списка', 'ar': 'عرض القائمة', 'uk': 'Вигляд списку', 'ro': 'Vizualizare listă', 'pl': 'Widok listy',
  },
  'oil_price': {
    'en': 'Oil Price', 'de': 'Ölpreis', 'fa': 'قیمت نفت', 'tr': 'Petrol Fiyatı',
    'ru': 'Цена на нефть', 'ar': 'سعر النفط', 'uk': 'Ціна на нафту', 'ro': 'Prețul petrolului', 'pl': 'Cena ropy',
  },
  'error_loading': {
    'en': 'Error loading data', 'de': 'Fehler beim Laden', 'fa': 'خطا در بارگذاری', 'tr': 'Veri yükleme hatası',
    'ru': 'Ошибка загрузки', 'ar': 'خطأ في تحميل البيانات', 'uk': 'Помилка завантаження', 'ro': 'Eroare la încărcare', 'pl': 'Błąd ładowania',
  },
 'search_label': {
    'en': 'Search postal code / city', // تغییر به city برای هماهنگی بیشتر با تغییر فارسی
    'de': 'Postleitzahl / Ort suchen', 
    'fa': 'جستجوی کد پستی / شهر یا موقعیت کنونی', 
    'tr': 'Posta kodu / şehir ara',
    'ru': 'Поиск индекса / города', 
    'ar': 'البحث عن الرمز البريدي / المدينة', 
    'uk': 'Пошук індексу / міста', 
    'ro': 'Căutare cod poștal / oraș', 
    'pl': 'Szukaj kodu pocztowego / miasta',
  },
  'search_hint': {
    'en': 'e.g. 10115 or Berlin Mitte', 'de': 'z. B. 10115 oder Berlin Mitte', 'fa': 'مثال: 10115 یا Berlin Mitte', 'tr': 'örn. 10115 veya Berlin Mitte',
    'ru': 'напр. 10115 или Berlin Mitte', 'ar': 'مثال: 10115 أو Berlin Mitte', 'uk': 'напр. 10115 або Berlin Mitte', 'ro': 'ex. 10115 sau Berlin Mitte', 'pl': 'np. 10115 lub Berlin Mitte',
  },
  'error_no_location': {
    'en': 'No location found. Try a postal code or city name.', 'de': 'Kein Standort gefunden. Versuchen Sie eine Postleitzahl oder Stadt.', 'fa': 'مکان یافت نشد. کد پستی یا نام شهر را وارد کنید.', 'tr': 'Konum bulunamadı. Posta kodu veya şehir ismi deneyin.',
    'ru': 'Местоположение не найдено. Попробуйте индекс или город.', 'ar': 'لم يتم العثور على موقع. جرب رمزاً بريدياً أو مدينة.', 'uk': 'Місце не знайдено. Спробуйте індекс або місто.', 'ro': 'Nicio locație găsită. Încercați un cod poștal sau oraș.', 'pl': 'Nie znaleziono lokalizacji. Spróbuj kod pocztowy lub miasto.',
  },
  'error_coords': {
    'en': 'Unable to determine coordinates.', 'de': 'Koordinaten konnten nicht ermittelt werden.', 'fa': 'امکان تعیین مختصات وجود ندارد.', 'tr': 'Koordinatlar belirlenemedi.',
    'ru': 'Невозможно определить координаты.', 'ar': 'تعذر تحديد الإحداثيات.', 'uk': 'Неможливо визначити координати.', 'ro': 'Nu se pot determina coordonatele.', 'pl': 'Nie można określić współrzędnych.',
  },
  'error_search_failed': {
    'en': 'Search failed. Please try again.', 'de': 'Suche fehlgeschlagen. Bitte versuchen Sie es erneut.', 'fa': 'جستجو ناموفق بود. لطفاً دوباره تلاش کنید.', 'tr': 'Arama başarısız. Lütfen tekrar deneyin.',
    'ru': 'Ошибка поиска. Попробуйте еще раз.', 'ar': 'فشل البحث. يرجى المحاولة مرة أخرى.', 'uk': 'Помилка пошуку. Спробуйте ще раз.', 'ro': 'Căutarea a eșuat. Încercați din nou.', 'pl': 'Wyszukiwanie nie powiodło się. Spróbuj ponownie.',
  },
  'error_permission': {
    'en': 'Search cancelled. Location permission is required.', 'de': 'Suche abgebrochen. Standortberechtigung ist erforderlich.', 'fa': 'جستجو لغو شد. دسترسی به مکان ضروری است.', 'tr': 'Arama iptal edildi. Konum izni gereklidir.',
    'ru': 'Поиск отменен. Требуется доступ к геолокации.', 'ar': 'تم إلغاء البحث. إذن الموقع مطلوب.', 'uk': 'Пошук скасовано. Потрібен доступ до геолокації.', 'ro': 'Căutare anulată. Permisiunea de locație este necesară.', 'pl': 'Wyszukiwanie anulowane. Wymagana lokalizacja.',
  },
  'success_service': {
    'en': 'Service logged successfully!', 'de': 'Service erfolgreich gespeichert!', 'fa': 'سرویس با موفقیت ثبت شد!', 'tr': 'Servis başarıyla kaydedildi!',
    'ru': 'Обслуживание успешно сохранено!', 'ar': 'تم تسجيل الخدمة بنجاح!', 'uk': 'Обслуговування успішно збережено!', 'ro': 'Service înregistrat cu succes!', 'pl': 'Serwis pomyślnie zapisany!',
  },
  'recent_history': {
    'en': 'Recent History:', 'de': 'Letzte Historie:', 'fa': 'تاریخچه اخیر:', 'tr': 'Son Geçmiş:',
    'ru': 'Недавняя история:', 'ar': 'السجل الأخير:', 'uk': 'Недавня історія:', 'ro': 'Istoric recent:', 'pl': 'Ostatnia historia:',
  },
'location': {
    'en': 'My Location', 
    'de': 'Mein Standort', 
    'fa': 'موقعیت کنونی من', 
    'tr': 'Konumum',
    'ru': 'Моё местоположение', 
    'ar': 'موقعي الحالي', 
    'uk': 'Моє розташування', 
    'ro': 'Locația mea', 
    'pl': 'Moja lokalizacja',
  },
  'search': {
    'en': 'Search', 'de': 'Suchen', 'fa': 'جستجو', 'tr': 'Ara',
    'ru': 'Поиск', 'ar': 'بحث', 'uk': 'Пошук', 'ro': 'Căutare', 'pl': 'Szukaj',
  },
  'radius': {
    'en': 'Radius', 'de': 'Radius', 'fa': 'شعاع', 'tr': 'Yarıçap',
    'ru': 'Радиус', 'ar': 'النطاق', 'uk': 'Радіус', 'ro': 'Rază', 'pl': 'Promień',
  },
  'km': {
    'en': '{val} km', 'de': '{val} km', 'fa': '{val} کیلومتر', 'tr': '{val} km',
    'ru': '{val} км', 'ar': '{val} كم', 'uk': '{val} км', 'ro': '{val} km', 'pl': '{val} km',
  },
  'fuel_diesel': {
    'en': 'Diesel', 'de': 'Diesel', 'fa': 'دیزل', 'tr': 'Dizel',
    'ru': 'Дизель', 'ar': 'ديزل', 'uk': 'Дизель', 'ro': 'Motorină', 'pl': 'Diesel',
  },
  'parking': {
    'en': 'Parking', 'de': 'Parkplatz', 'fa': 'پارکینگ', 'tr': 'Otopark',
    'ru': 'Парковка', 'ar': 'موقف سيارات', 'uk': 'Парковка', 'ro': 'Parcare', 'pl': 'Parking',
  },
  'fuel_ev': {
    'en': 'EV', 'de': 'Elektro', 'fa': 'برقی (EV)', 'tr': 'Elektrikli',
    'ru': 'Электро (EV)', 'ar': 'كهربائي', 'uk': 'Електро (EV)', 'ro': 'Electric (EV)', 'pl': 'Elektryczny (EV)',
  },
  'two_days_ago': {
    'en': '2 Days Ago', 'de': 'Vor 2 Tagen', 'fa': '۲ روز پیش', 'tr': '2 Gün Önce',
    'ru': '2 дня назад', 'ar': 'قبل يومين', 'uk': '2 дні тому', 'ro': 'Acum 2 zile', 'pl': '2 dni temu',
  },
  'yesterday': {
    'en': 'Yesterday', 'de': 'Gestern', 'fa': 'دیروز', 'tr': 'Dün',
    'ru': 'Вчера', 'ar': 'أمس', 'uk': 'Вчора', 'ro': 'Ieri', 'pl': 'Wczoraj',
  },
  'today': {
    'en': 'Today', 'de': 'Heute', 'fa': 'امروز', 'tr': 'Bugün',
    'ru': 'Сегодня', 'ar': 'اليوم', 'uk': 'Сьогодні', 'ro': 'Astăzi', 'pl': 'Dzisiaj',
  },
  'smart_service_log': {
    'en': 'Smart Service Log', 'de': 'Intelligentes Service-Logbuch', 'fa': 'ثبت هوشمند سرویس', 'tr': 'Akıllı Servis Kaydı',
    'ru': 'Умный журнал обслуживания', 'ar': 'سجل الخدمة الذكي', 'uk': 'Розумний журнал обслуговування', 'ro': 'Jurnal Service Inteligent', 'pl': 'Inteligentny Dziennik Serwisu',
  },  
  'service_type': {
    'en': 'Service Type', 'de': 'Serviceart', 'fa': 'نوع سرویس', 'tr': 'Servis Türü',
    'ru': 'Тип обслуживания', 'ar': 'نوع الخدمة', 'uk': 'Тип послуги', 'ro': 'Tip service', 'pl': 'Rodzaj usługi',
  },
  'current_mileage': {
    'en': 'Current Mileage (Km)', 'de': 'Aktueller Kilometerstand (km)', 'fa': 'کارکرد فعلی (کیلومتر)', 'tr': 'Güncel Kilometre (km)',
    'ru': 'Текущий пробег (км)', 'ar': 'المسافة الحالية (كم)', 'uk': 'Поточний пробіг (км)', 'ro': 'Kilometraj curent (Km)', 'pl': 'Aktualny przebieg (Km)',
  },
  'vehicle_overview': {
    'en': 'Vehicle overview', 'de': 'Fahrzeugübersicht', 'fa': 'نمای کلی خودرو', 'tr': 'Araç genel bakışı',
    'ru': 'Обзор автомобиля', 'ar': 'نظرة عامة على السيارة', 'uk': 'Огляд автомобіля', 'ro': 'Prezentare generală a vehiculului', 'pl': 'Przegląd pojazdu',
  },
  'car_model': {
    'en': 'Car model', 'de': 'Automodell', 'fa': 'مدل خودرو', 'tr': 'Araç modeli',
    'ru': 'Модель автомобиля', 'ar': 'مديل السيارة', 'uk': 'Модель авто', 'ro': 'Model auto', 'pl': 'Model samochodu',
  },
  'license_plate': {
    'en': 'License plate', 'de': 'Kennzeichen', 'fa': 'پلاک', 'tr': 'Plaka',
    'ru': 'Номерной знак', 'ar': 'رقم اللوحة', 'uk': 'Державний номер', 'ro': 'Număr de înmatriculare', 'pl': 'Tablica rejestracyjna',
  },
  'authorized_workshop': {
    'en': 'Authorized workshop', 'de': 'Autorisiertes Werkstatt', 'fa': 'تعمیرگاه معتبر', 'tr': 'Yetkili servis',
    'ru': 'Авторизованный сервис', 'ar': 'ورشة معتمدة', 'uk': 'Авторизований сервіс', 'ro': 'Atelier autorizat', 'pl': 'Autoryzowany warsztat',
  },
  'phone_number': {
    'en': 'Phone number', 'de': 'Telefonnummer', 'fa': 'شماره تلفن', 'tr': 'Telefon numarası',
    'ru': 'Номер телефона', 'ar': 'رقم الهاتف', 'uk': 'Номер телефону', 'ro': 'Număr de telefon', 'pl': 'Numer telefonu',
  },
  'service_overview_hint': {
    'en': 'Enter your workshop phone and service details here to get reminders.', 'de': 'Geben Sie hier die Telefonnummer der Werkstatt und die Servicedaten ein, um Erinnerungen zu erhalten.', 'fa': 'برای دریافت یادآوری‌ها، اطلاعات سرویس و تلفن تعمیرگاه را اینجا وارد کنید.', 'tr': 'Hatırlatıcı almak için servis ayrıntılarını ve atölye telefonunu buraya girin.',
    'ru': 'Введите здесь телефон мастерской и данные обслуживания, чтобы получать напоминания.', 'ar': 'أدخل هنا رقم هاتف الورشة وتفاصيل الصيانة لتلقي التذكيرات.', 'uk': 'Введіть тут телефон майстерні та дані сервісу, щоб отримувати нагадування.', 'ro': 'Introduceți aici telefonul atelierului și detaliile de service pentru a primi memento-uri.', 'pl': 'Wprowadź tutaj telefon warsztatu i szczegóły serwisu, aby otrzymywać przypomnienia.',
  },
  'service_note_hint': {
    'en': 'Please review your service details on this page.', 'de': 'Bitte überprüfen Sie die Servicedaten auf dieser Seite.', 'fa': 'برای دریافت یادآوری سرویس، تاریخ و کیلومتر را کامل کنید.', 'tr': 'Lütfen servis bilgilerinizi bu sayfada kontrol edin.',
    'ru': 'Пожалуйста, проверьте данные обслуживания на этой странице.', 'ar': 'يرجى مراجعة تفاصيل الخدمة على هذه الصفحة.', 'uk': 'Будь ласка, перевірте дані сервісу на цій сторінці.', 'ro': 'Vă rugăm să verificați detaliile serviciului pe această pagină.', 'pl': 'Proszę sprawdzić szczegóły serwisu na tej stronie.',
  },
  'phone_workshop': {
    'en': 'Phone / Workshop', 'de': 'Telefon / Werkstatt', 'fa': 'تلفن / تعمیرگاه', 'tr': 'Telefon / Servis',
    'ru': 'Телефон / мастерская', 'ar': 'الهاتف / ورشة العمل', 'uk': 'Телефон / майстерня', 'ro': 'Telefon / atelier', 'pl': 'Telefon / warsztat',
  },
  'service_center': {
    'en': 'Service center', 'de': 'Servicezentrum', 'fa': 'مرکز خدمات', 'tr': 'Servis merkezi',
    'ru': 'Сервисный центр', 'ar': 'مركز الخدمة', 'uk': 'Сервісний центр', 'ro': 'Centru de service', 'pl': 'Centrum serwisowe',
  },
  'set_reminder': {
    'en': 'Set reminder', 'de': 'Erinnerung setzen', 'fa': 'تنظیم یادآور', 'tr': 'Hatırlatıcı ayarla',
    'ru': 'Установить напоминание', 'ar': 'تعيين تذكير', 'uk': 'Встановити нагадування', 'ro': 'Setează memento', 'pl': 'Ustaw przypomnienie',
  },
  'open_website': {
    'en': 'Open website', 'de': 'Webseite öffnen', 'fa': 'باز کردن وب‌سایت', 'tr': 'Web sitesini aç',
    'ru': 'Открыть сайт', 'ar': 'افتح الموقع', 'uk': 'Відкрити веб-сайт', 'ro': 'Deschide site-ul', 'pl': 'Otwórz stronę',
  },
  'call': {
    'en': 'Call', 'de': 'Anrufen', 'fa': 'تماس', 'tr': 'Ara',
    'ru': 'Позвонить', 'ar': 'اتصل', 'uk': 'Зателефонувати', 'ro': 'Sună', 'pl': 'Zadzwoń',
  },
  'pick_date': {
    'en': 'Pick date', 'de': 'Datum wählen', 'fa': 'انتخاب تاریخ', 'tr': 'Tarih seç',
    'ru': 'Выбрать дату', 'ar': 'اختر التاريخ', 'uk': 'Вибрати дату', 'ro': 'Alege data', 'pl': 'Wybierz datę',
  },
  'incomplete_row_note': {
    'en': 'Please fill the required service fields.', 'de': 'Bitte füllen Sie die erforderlichen Servicefelder aus.', 'fa': 'لطفا فیلدهای لازم سرویس را پر کنید.', 'tr': 'Lütfen gerekli servis alanlarını doldurun.',
    'ru': 'Пожалуйста, заполните необходимые поля сервиса.', 'ar': 'يرجى ملء حقول الخدمة المطلوبة.', 'uk': 'Будь ласка, заповніть потрібні поля сервісу.', 'ro': 'Vă rugăm să completați câmpurile de service necesare.', 'pl': 'Proszę wypełnić wymagane pola serwisu.',
  },  
  'cat_timing_belt': {
    'en': 'Timing Belt', 'de': 'Zahnriemen', 'fa': 'تسمه تایم', 'tr': 'Triger Kayışı',
    'ru': 'Ремень ГРМ', 'ar': 'حزام التوقيت', 'uk': 'Ремінь ГРМ', 'ro': 'Curea distribuție', 'pl': 'Pasek rozrządu',
  },
  'cat_oil': {
    'en': 'Oil Change', 'de': 'Ölwechsel', 'fa': 'تعویض روغن', 'tr': 'Yağ Değişimi',
    'ru': 'Замена масла', 'ar': 'تغيير الزيت', 'uk': 'Заміна масла', 'ro': 'Schimb ulei', 'pl': 'Wymiana oleju',
  },
  'cat_brake': {
    'en': 'Brake Pads', 'de': 'Bremsbeläge', 'fa': 'لنت ترمز', 'tr': 'Fren Balataları',
    'ru': 'Тормозные колодки', 'ar': 'تيل الفرامل', 'uk': 'Гальмівні колодки', 'ro': 'Plăcuțe de frână', 'pl': 'Klocki hamulcowe',
  },
  'cat_wipers': {
    'en': 'Wipers', 'de': 'Scheibenwischer', 'fa': 'برف‌پاک‌کن', 'tr': 'Silecekler',
    'ru': 'Дворники', 'ar': 'مساحات', 'uk': 'Дворники', 'ro': 'Ștergătoare', 'pl': 'Wycieraczki',
  },
  'cat_lights': {
    'en': 'Lights', 'de': 'Lichter', 'fa': 'چراغ‌ها', 'tr': 'Farlar',
    'ru': 'Фары', 'ar': 'أضواء', 'uk': 'Фари', 'ro': 'Luminile', 'pl': 'Światła',
  },
  'cat_insurance': {
    'en': 'Insurance', 'de': 'Versicherung', 'fa': 'بیمه', 'tr': 'Sigorta',
    'ru': 'Страхование', 'ar': 'تأمين', 'uk': 'Страхування', 'ro': 'Asigurare', 'pl': 'Ubezpieczenie',
  },
  'cat_adac': {
    'en': 'ADAC', 'de': 'ADAC', 'fa': 'اداک', 'tr': 'ADAC',
    'ru': 'ADAC', 'ar': 'ADAC', 'uk': 'ADAC', 'ro': 'ADAC', 'pl': 'ADAC',
  },
  'cat_km_stand': {
    'en': 'Kilometer Stand', 'de': 'Kilometerstand', 'fa': 'کیلومتر', 'tr': 'Kilometre',
    'ru': 'Пробег', 'ar': 'عداد الكيلومترات', 'uk': 'Пробіг', 'ro': 'Kilometraj', 'pl': 'Stan licznika',
  },
  'cat_spark': {
    'en': 'Spark Plugs', 'de': 'Zündkerzen', 'fa': 'شمع‌ها', 'tr': 'Bujiler',
    'ru': 'Свечи зажигания', 'ar': 'شمعات الإشعال', 'uk': 'Свічки запалювання', 'ro': 'Bujii', 'pl': 'Świece zapłonowe',
  },
  'cat_tires': {
    'en': 'Tires', 'de': 'Reifen', 'fa': 'لاستیک‌ها', 'tr': 'Lastikler',
    'ru': 'Шины', 'ar': 'الإطارات', 'uk': 'Шини', 'ro': 'Anvelope', 'pl': 'Opony',
  },
  'cat_tuv': {
    'en': 'TÜV / Inspection', 'de': 'TÜV / Inspektion', 'fa': 'تاییدیه فنی (TÜV)', 'tr': 'TÜV / Muayene',
    'ru': 'Техосмотр (TÜV)', 'ar': 'الفحص الفني (TÜV)', 'uk': 'Техогляд (TÜV)', 'ro': 'Inspecție ITP/TÜV', 'pl': 'Przegląd techniczny',
  },
  'no_history_found': {
    'en': 'No history found. Log your first service!', 'de': 'Keine Historie gefunden. Loggen Sie Ihren ersten Service!', 'fa': 'تاریخچه‌ای یافت نشد. اولین سرویس خود را ثبت کنید!', 'tr': 'Geçmiş bulunamadı. İlk servisinizi kaydedin!',
    'ru': 'История не найдена. Запишите свое первое обслуживание!', 'ar': 'لم يتم العثور على سجل. قم بتسجيل خدمتك الأولى!', 'uk': 'Історію не знайдено. Збережіть перше обслуговування!', 'ro': 'Niciun istoric găsit. Înregistrează primul service!', 'pl': 'Nie znaleziono historii. Zapisz swój pierwszy serwis!',
  },
  'log_service_date': {
    'en': 'Log Service & Date', 'de': 'Service & Datum loggen', 'fa': 'ثبت سرویس و تاریخ', 'tr': 'Servis ve Tarihi Kaydet',
    'ru': 'Записать обслуживание и дату', 'ar': 'تسجيل الخدمة والتاريخ', 'uk': 'Записати обслуговування та дату', 'ro': 'Înregistrează Service și Dată', 'pl': 'Zapisz Serwis i Datę',
  },
  'service_due_days': {
    'en': '{item} is due in {days} days.', 
    'de': '{item} ist in {days} Tagen fällig.', 
    'fa': '{days} روز تا سرویس {item} مانده.',
  },
  'service_overdue': {
    'en': '{item} is overdue.', 
    'de': '{item} ist überfällig.', 
    'fa': 'موعد سرویس {item} گذشته است.',
  },
  'service_due_km': {
    'en': '{item} is due in {km} km.', 
    'de': '{item} ist in {km} km fällig.', 
    'fa': '{km} کیلومتر تا سرویس {item} مانده.',
  },
  'service_check_now': {
    'en': 'Please check your {item} now.', 
    'de': 'Bitte überprüfen Sie {item} jetzt.', 
    'fa': 'لطفاً {item} ماشین را چک کنید.',
  },
  'service_active': {
    'en': 'Reminder active for {item}.', 
    'de': 'Erinnerung aktiv für {item}.', 
    'fa': 'یادآور {item} فعال است.',
  },
  'grouped_service_alert_body': {
    'en': 'You have {count} messages in your car service section, please check.', 
    'de': 'Sie haben {count} Nachrichten im Servicebereich, bitte prüfen.', 
    'fa': 'شما {count} پیغام در بخش سرویس ماشین دارید، لطفاً چک کنید.',
  },
  'btn_open': { 'en': 'Open Services', 'de': 'Öffnen', 'fa': 'ورود به سرویس' },
  'btn_delete': { 'en': 'Delete Alarm', 'de': 'Alarm löschen', 'fa': 'حذف آلارم' },
  'btn_snooze': { 'en': 'Remind Tomorrow', 'de': 'Morgen erinnern', 'fa': 'فردا یادآوری کن' },
  
  'upgrade_to_premium': {
    'en': 'Upgrade to Premium', 'de': 'Auf Premium upgraden', 'fa': 'ارتقا به نسخه ویژه', 'tr': 'Premium\'a Yükselt',
    'ru': 'Обновить до Премиум', 'ar': 'الترقية إلى النسخة المميزة', 'uk': 'Оновити до Преміум', 'ro': 'Treci la Premium', 'pl': 'Przejdź na Premium',
  },

  'premium_desc': {
    'en': 'Unlock full features and completely remove ads from the interface instantly.',
    'de': 'Schalten Sie alle Funktionen frei und entfernen Sie sofort alle Anzeigen.',
    'fa': 'با تهیه اشتراک ویژه، تبلیغات آزاردهنده به طور کامل حذف شده و بخش خدمات خودرو فعال می‌گردد.',
    'tr': 'Tam özellikleri açın ve reklamları anında tamamen kaldırın.',
    'ru': 'Разблокируйте все функции и полностью удалите рекламу из интерфейса.',
    'ar': 'افتح الميزات الكاملة وأزل الإعلانات تماماً من الواجهة فوراً.',
    'uk': 'Розблокуйте всі функції та повністю видаліть рекламу з інтерфейсу.',
    'ro': 'Deblocați funcțiile complete și eliminați complet reclamele.',
    'pl': 'Odblokuj pełne funkcje i całkowicie usuń reklamy z interfejsu.',
  },
  'cancel': {
    'en': 'Cancel', 'de': 'Abbrechen', 'fa': 'انصراف', 'tr': 'İptal',
    'ru': 'Отмена', 'ar': 'إلغاء', 'uk': 'Скасувати', 'ro': 'Anulare', 'pl': 'Anuluj',
  },
  'buy_premium': {
    'en': 'Buy Premium', 'de': 'Premium kaufen', 'fa': 'خرید نسخه پرمیوم', 'tr': 'Premium Satın Al',
    'ru': 'Купить Премиум', 'ar': 'شراء النسخة المميزة', 'uk': 'Купити Преміум', 'ro': 'Cumpără Premium', 'pl': 'Kup Premium',
  },
  'tanken_premium_desc': {
    'en': 'Your free trial has ended. Activate the premium version to see real-time gas prices and use the app ad-free for 6 months.',
    'de': 'Ihre Testphase ist abgelaufen. Aktivieren Sie Premium für Live-Preise und 6 Monate Werbefreiheit.',
    'fa': 'مهلت استفاده رایگان شما به پایان رسیده است. برای مشاهده قیمت لحظه‌ای پمپ بنزین‌ها و استفاده بدون تبلیغ به مدت ۶ ماه، نسخه پرمیوم را فعال کنید.',
    'tr': 'Deneme süreniz doldu. Canlı fiyatları görmek ve 6 ay reklamsız kullanmak için premium\'u etkinleştirin.',
    'ru': 'Пробный период завершен. Активируйте премиум для цен в реальном времени и 6 месяцев без рекламы.',
    'ar': 'انتهت الفترة التجريبية. قم بتفعيل النسخة المميزة لرؤية الأسعار المباشرة واستخدام التطبيق بدون إعلانات لمدة 6 أشهر.',
    'uk': 'Пробний період закінчився. Активуйте преміум для цін у реальному часі та 6 місяців без реклами.',
    'ro': 'Perioada de probă a expirat. Activați premium pentru prețuri live și 6 luni fără reclame.',
    'pl': 'Okres próbny minął. Aktywuj premium, aby widzieć ceny na żywo i korzystać bez reklam przez 6 miesięcy.',
  },
  'activate_premium_6months': {
    'en': 'Activate 6-Month Premium', 'de': '6-Monate Premium aktivieren', 'fa': 'فعال‌سازی پرمیوم ۶ ماهه', 'tr': '6 Aylık Premium\'u Etkinleştir',
    'ru': 'Активировать Премиум на 6 месяцев', 'ar': 'تفعيل النسخة المميزة لمدة 6 أشهر', 'uk': 'Активувати Преміум на 6 місяців', 'ro': 'Activează Premium 6 Luni', 'pl': 'Aktywuj Premium na 6 miesięcy',
  },
  'premium_activated': {
    'en': 'Premium activated successfully!', 'de': 'Premium erfolgreich aktiviert!', 'fa': 'اشتراک ویژه با موفقیت فعال شد!', 'tr': 'Premium başarıyla etkinleştirildi!',
    'ru': 'Премиум успешно активирован!', 'ar': 'تم تفعيل النسخة المميزة بنجاح!', 'uk': 'Преміум успішно активовано!', 'ro': 'Premium activat cu succes!', 'pl': 'Premium pomyślnie aktywowane!',
  },
  'unlimited_access_features': {
    'en': 'Unlimited access to all features', 'de': 'Unbegrenzter Zugriff auf alle Funktionen', 'fa': 'استفاده نامحدود از تمام امکانات اپلیکیشن', 'tr': 'Tüm özelliklere sınırsız erişim',
    'ru': 'Неограниченный доступ ко всем функциям', 'ar': 'وصول غير محدود لجميع الميزات', 'uk': 'Необмежений доступ до всіх функцій', 'ro': 'Acces nelimitat la toate funcțiile', 'pl': 'Nieograniczony dostęp do wszystkich funkcji',
  },
  'remove_ads_premium': {
    'en': 'Remove Ads + Premium', 'de': 'Keine Werbung + Premium', 'fa': 'حذف آگهی + نسخه پرمیوم', 'tr': 'Reklamları Kaldır + Premium',
    'ru': 'Убрать рекламу + Премиум', 'ar': 'إزالة الإعلانات + النسخة المميزة', 'uk': 'Видалити рекламу + Преміум', 'ro': 'Fără Reclame + Premium', 'pl': 'Usuń Reklamy + Premium',
  },
  'connecting_google_play': {
    'en': 'Connecting to Google Play...', 'de': 'Verbindung zu Google Play herstellen...', 'fa': 'در حال برقراری ارتباط با گوگل‌پلی...', 'tr': 'Google Play\'e bağlanılıyor...',
    'ru': 'Подключение к Google Play...', 'ar': 'الاتصال بـ Google Play...', 'uk': 'Підключення до Google Play...', 'ro': 'Se conectează la Google Play...', 'pl': 'Łączenie z Google Play...',
  },
  'set_price_alert_title': {
    'en': 'Set Price Drop Alert', 'de': 'Preisalarm einstellen', 'fa': 'تنظیم هشدار افت قیمت', 'tr': 'Fiyat Düşüş Alarmı Kur',
    'ru': 'Установить оповещение о снижении цены', 'ar': 'تعيين تنبيه انخفاض السعر', 'uk': 'Встановити сповіщення про зниження ціни', 'ro': 'Setează alerta de preț', 'pl': 'Ustaw alert o spadku ceny',
  },
  'set_price_alert_subtitle': {
    'en': 'Get notified when price goes below this amount', 'de': 'Benachrichtigen, wenn der Preis unter diesen Wert fällt', 'fa': 'وقتی قیمت کمتر از این شد به من اطلاع بده', 'tr': 'Fiyat bu miktarın altına düştüğünde bildirim al',
    'ru': 'Получить уведомление, когда цена упадет ниже этой суммы', 'ar': 'احصل على إشعار عندما ينخفض السعر عن هذا المبلغ', 'uk': 'Отримати сповіщення, коли ціна впаде нижче', 'ro': 'Primiți notificare când prețul scade', 'pl': 'Otrzymaj powiadomienie, gdy cena spadnie',
  },
  'save_alert_btn': {
    'en': 'Save Alert Settings', 'de': 'Alarmeinstellungen speichern', 'fa': 'ذخیره تنظیمات هشدار', 'tr': 'Alarm Ayarlarını Kaydet',
    'ru': 'Сохранить настройки оповещений', 'ar': 'حفظ إعدادات التنبيه', 'uk': 'Зберегти налаштування сповіщень', 'ro': 'Salvează Setările Alertei', 'pl': 'Zapisz Ustawienia Alertu',
  },
  'alert_success_snack': {
    'en': 'Alert set for €{price}', 'de': 'Alarm für €{price} eingestellt', 'fa': 'هشدار برای مبلغ €{price} تنظیم شد', 'tr': 'Alarm €{price} için ayarlandı',
    'ru': 'Оповещение установлено на €{price}', 'ar': 'تم تعيين التنبيه لـ €{price}', 'uk': 'Сповіщення встановлено на €{price}', 'ro': 'Alertă setată pentru €{price}', 'pl': 'Alert ustawiony na €{price}',
  },
  'recent_searches': {
    'en': 'Recent Searches', 'de': 'Letzte Suchanfragen', 'fa': 'جستجوهای اخیر', 'tr': 'Son Aramalar',
    'ru': 'Недавние поиски', 'ar': 'عمليات البحث الأخيرة', 'uk': 'Останні пошуки', 'ro': 'Căutări recente', 'pl': 'Ostatnie wyszukiwania',
  },
  'clear_history': {
    'en': 'Clear', 'de': 'Löschen', 'fa': 'پاک کردن', 'tr': 'Temizle',
    'ru': 'Очистить', 'ar': 'مسح', 'uk': 'Очистити', 'ro': 'Șterge', 'pl': 'Wyczyść',
  },
  'legal_consent_title': {
    'en': 'Legal Privacy Consent', 'de': 'Datenschutzrechtliche Einwilligung', 'fa': 'تاییدیه حریم خصوصی', 'tr': 'Yasal Gizlilik Onayı',
    'ru': 'Юридическое согласие', 'ar': 'الموافقة القانونية على الخصوصية', 'uk': 'Юридична згода', 'ro': 'Consimțământ de confidențialitate', 'pl': 'Zgoda na prywatność',
  },
  'legal_consent_desc': {
    'en': 'In compliance with data protection regulations (GDPR), this application requires your explicit consent to access your device\'s location. This data is used solely to fetch nearby gas station prices in real-time.\n\nImportant: Your location data is processed locally, transmitted securely, and is NEVER stored or tracked on any server.',
    'de': 'Gemäß den Datenschutzrichtlinien (DSGVO) benötigt diese App Ihre ausdrückliche Zustimmung zum Standortzugriff. Diese Daten werden ausschließlich genutzt, um Tankstellenpreise abzurufen.\n\nWichtig: Ihre Standortdaten werden lokal verarbeitet und NIEMALS auf Servern gespeichert.',
    'fa': 'طبق قوانین حفاظت از داده‌ها (GDPR)، این برنامه برای دسترسی به موقعیت مکانی شما نیاز به تایید صریح دارد. این داده‌ها صرفاً برای دریافت قیمت لحظه‌ای پمپ بنزین‌ها استفاده می‌شود.\n\nمهم: داده‌های مکانی شما به صورت محلی پردازش شده و هرگز در هیچ سروری ذخیره یا ردیابی نمی‌گردد.',
    'tr': 'Veri koruma yasalarına (GDPR) uygun olarak, bu uygulama konumunuza erişmek için açık rızanızı gerektirir. Bu veriler sadece yakındaki istasyon fiyatlarını almak için kullanılır.\n\nÖnemli: Konum verileriniz ASLA hiçbir sunucuda saklanmaz veya takip edilmez.',
    'ru': 'В соответствии с GDPR приложению требуется ваше согласие на доступ к местоположению. Эти данные используются только для получения цен на заправках.\n\nВажно: данные обрабатываются локально и НИКОГДА не сохраняются на серверах.',
    'ar': 'امتثالاً للوائح حماية البيانات (GDPR)، يتطلب هذا التطبيق موافقتك الصريحة للوصول إلى موقعك. تُستخدم هذه البيانات فقط لجلب أسعار المحطات.\n\nهام: تُعالج بياناتك محليًا ولا تُخزن أبدًا على أي خادم.',
    'uk': 'Відповідно до GDPR додатку потрібна ваша згода на доступ до місцезнаходження. Дані використовуються лише для отримання цін на заправках.\n\nВажливо: дані НІКОЛИ не зберігаються на серверах.',
    'ro': 'Conform GDPR, aplicația necesită consimțământul pentru locație. Datele sunt folosite doar pentru prețurile stațiilor.\n\nImportant: Datele nu sunt stocate NICIODATĂ pe servere.',
    'pl': 'Zgodnie z RODO, aplikacja wymaga zgody na dostęp do lokalizacji. Dane są używane tylko do pobierania cen stacji.\n\nWażne: Dane NIGDY nie są przechowywane na serwerach.',
  },
  'accept_proceed': {
    'en': 'Accept & Proceed', 'de': 'Akzeptieren & Fortfahren', 'fa': 'تایید و ادامه', 'tr': 'Kabul Et & İlerle',
    'ru': 'Принять и продолжить', 'ar': 'قبول ومتابعة', 'uk': 'Прийняти та продовжити', 'ro': 'Acceptă și continuă', 'pl': 'Akceptuj i kontynuuj',
  },
  'add_custom_service': {
    'en': 'Add Custom Service/Part', 'de': 'Benutzerdefinierten Service hinzufügen', 'fa': 'افزودن قطعه/سرویس جدید', 'tr': 'Özel Servis/Parça Ekle',
    'ru': 'Добавить пользовательский сервис', 'ar': 'إضافة خدمة/جزء مخصص', 'uk': 'Додати власну послугу', 'ro': 'Adaugă serviciu personalizat', 'pl': 'Dodaj niestandardową usługę',
  },
  'custom_service_name_label': {
    'en': 'Service name', 'de': 'Servicename', 'fa': 'نام سرویس', 'tr': 'Servis adı',
    'ru': 'Название сервиса', 'ar': 'اسم الخدمة', 'uk': 'Назва сервісу', 'ro': 'Numele serviciului', 'pl': 'Nazwa serwisu',
  },
  'custom_service_hint': {
    'en': 'e.g. Fuel Pump, Battery...', 'de': 'z.B. Kraftstoffpumpe, Batterie...', 'fa': 'مثال: پمپ بنزین، باتری...', 'tr': 'örn. Yakıt Pompası, Akü...',
    'ru': 'напр. Бензонасос, Батарея...', 'ar': 'مثال: مضخة وقود، بطارية...', 'uk': 'напр. Паливний насос, Акумулятор...', 'ro': 'ex. Pompă de combustibil, Baterie...', 'pl': 'np. Pompa paliwa, Bateria...',
  },
  'insurance_phone': {
    'en': 'Insurance Phone', 
    'de': 'Versicherung Telefon', 
    'fa': 'تلفن بیمه', 
    'tr': 'Sigorta Telefonu',
    'ru': 'Телефон страховой', 
    'ar': 'هاتف التأمين', 
    'uk': 'Телефон страховки', 
    'ro': 'Telefon asigurare', 
    'pl': 'Telefon do ubezpieczenia',
  },
  'move_up': {
    'en': 'Move up', 'de': 'Nach oben', 'fa': 'انتقال به بالا', 'tr': 'Yukarı taşı',
    'ru': 'Переместить вверх', 'ar': 'تحريك للأعلى', 'uk': 'Перемістити вгору', 'ro': 'Mută în sus', 'pl': 'Przenieś w górę',
  },
  'move_down': {
    'en': 'Move down', 'de': 'Nach unten', 'fa': 'انتقال به پایین', 'tr': 'Aşağı taşı',
    'ru': 'Переместить вниз', 'ar': 'تحريك للأسفل', 'uk': 'Перемістити вниз', 'ro': 'Mută în jos', 'pl': 'Przenieś w dół',
  },
  'remove_service': {
    'en': 'Remove', 'de': 'Entfernen', 'fa': 'حذف', 'tr': 'Kaldır',
    'ru': 'Удалить', 'ar': 'حذف', 'uk': 'Видалити', 'ro': 'Elimină', 'pl': 'Usuń',
  },
  'performance_update_title': {
    'en': 'Car Performance Update', 'de': 'Fahrzeug-Leistungsaktualisierung', 'fa': 'بروزرسانی کارکرد خودرو', 'tr': 'Araç Performans Güncellemesi',
    'ru': 'Обновление показателей автомобиля', 'ar': 'تحديث أداء السيارة', 'uk': 'Оновлення показників авто', 'ro': 'Actualizare performanță mașină', 'pl': 'Aktualizacja osiągów samochodu',
  },
  'performance_update_body': {
    'en': 'It has been 3 months. Please update your car performance and review service data.', 'de': 'Es sind 3 Monate vergangen. Bitte aktualisiere die Fahrzeugdaten und überprüfe den Service.', 'fa': '۳ ماه گذشته است. لطفاً کارکرد خودرو را به‌روز کن و وضعیت سرویس را بررسی کن.', 'tr': '3 ay geçti. Lütfen araç performansını güncelle ve servis verilerini kontrol et.',
    'ru': 'Прошло 3 месяца. Пожалуйста, обновите показатели автомобиля и проверьте данные обслуживания.', 'ar': 'مرّت 3 أشهر. الرجاء تحديث أداء السيارة ومراجعة بيانات الخدمة.', 'uk': 'Минуло 3 місяці. Будь ласка, оновіться показники авто та перевірте дані сервісу.', 'ro': 'Au trecut 3 luni. Vă rugăm să actualizați performanța mașinii și să verificați datele de service.', 'pl': 'Minęły 3 miesiące. Zaktualizuj osiągi samochodu i sprawdź dane serwisu.',
  },
  'add_btn': {
    'en': 'Add', 'de': 'Hinzufügen', 'fa': 'افزودن', 'tr': 'Ekle',
    'ru': 'Добавить', 'ar': 'إضافة', 'uk': 'Додати', 'ro': 'Adaugă', 'pl': 'Dodaj',
  },
};

// تابع جادویی ترجمه با قابلیت جایگذاری متغیرها (مثل نام پمپ بنزین یا قیمت)
String translate(
  String key,
  String languageCode, [
  Map<String, String>? params,
]) {
  final template = localizedStrings[key]?[languageCode] ??
      localizedStrings[key]?['en'] ?? // انگلیسی به عنوان زنده نگه‌دارنده دکمه فرار
      key;
      
  var result = template;
  if (params != null) {
    params.forEach((paramKey, paramValue) {
      result = result.replaceAll('{$paramKey}', paramValue);
    });
  }
  return result;
}