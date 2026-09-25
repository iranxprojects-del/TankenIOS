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
  },
  'onboard_select_fuel': {
    'en': 'Select your fuel type',
    'de': 'Wählen Sie Ihre Kraftstoffart',
    'fa': 'لطفاً نوع سوخت خود را انتخاب کنید',
    'tr': 'Yakıt türünüzü seçin',
    'ru': 'Выберите тип топлива',
    'ar': 'اختر نوع الوقود الخاص بك',
    'uk': 'Виберіть тип пального',
    'ro': 'Selectați tipul de combustibil',
    'pl': 'Wybierz rodzaj paliwa',
  },
  'onboard_tap_location': {
    'en': 'Now tap here to find your current location',
    'de': 'Tippen Sie jetzt hier, um Ihren aktuellen Standort zu finden',
    'fa': 'حالا روی اینجا کلیک کنید تا موقعیت فعلی شما پیدا شود',
    'tr': 'Şimdi mevcut konumunuzu bulmak için buraya dokunun',
    'ru': 'Теперь нажмите здесь, чтобы найти своё текущее местоположение',
    'ar': 'انقر هنا الآن للعثور على موقعك الحالي',
    'uk': 'Тепер натисніть тут, щоб знайти своє поточне місцезнаходження',
    'ro': 'Acum atingeți aici pentru a găsi locația dvs. curentă',
    'pl': 'Teraz dotknij tutaj, aby znaleźć swoją bieżącą lokalizację',
  },
  'onboard_loading_stations': {
    'en': 'Please wait, loading nearby stations…',
    'de': 'Bitte warten, Tankstellen in der Nähe werden geladen…',
    'fa': 'لطفاً کمی صبر کنید تا پمپ‌بنزین‌های نزدیک بارگذاری شوند…',
    'tr': 'Lütfen bekleyin, yakındaki istasyonlar yükleniyor…',
    'ru': 'Пожалуйста, подождите, идёт загрузка ближайших заправок…',
    'ar': 'يرجى الانتظار، جارٍ تحميل محطات الوقود القريبة…',
    'uk': 'Будь ласка, зачекайте, завантажуються найближчі заправки…',
    'ro': 'Vă rugăm așteptați, se încarcă stațiile din apropiere…',
    'pl': 'Proszę czekać, trwa ładowanie pobliskich stacji…',
  },
  'onboard_select_cheapest': {
    'en': 'This is the cheapest station nearby — tap it!',
    'de': 'Dies ist die günstigste Tankstelle in der Nähe – tippen Sie darauf!',
    'fa': 'این ارزان‌ترین پمپ بنزین نزدیک شماست — روی آن کلیک کنید!',
    'tr': 'Bu yakındaki en ucuz istasyon — dokunun!',
    'ru': 'Это самая дешёвая заправка поблизости — нажмите на неё!',
    'ar': 'هذه أرخص محطة وقود قريبة منك — اضغط عليها!',
    'uk': 'Це найдешевша заправка поблизу — натисніть на неї!',
    'ro': 'Aceasta este cea mai ieftină stație din apropiere — atingeți-o!',
    'pl': 'To najtańsza stacja w pobliżu — dotknij jej!',
  },
  'free_tier_expired': {
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
    'en': 'Days of access remaining: ',
    'de': 'Verbleibende Zugriffstage: ',
    'fa': 'روز دسترسی کامل باقی مانده: ',
    'tr': 'Kalan erişim günleri: ',
    'ru': 'Осталось дней доступа: ',
    'ar': 'أيام الوصول المتبقية: ',
    'uk': 'Залишилося днів доступу: ',
    'ro': 'Zile de acces rămase: ',
    'pl': 'Pozostałe dni dostępu: ',
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
  'service_mileage_label': {
    'en': 'Mileage at last service ({unit})', 'de': 'Kilometerstand beim letzten Service ({unit})', 'fa': 'کارکرد در آخرین سرویس ({unit})', 'tr': 'Son serviste kilometre ({unit})',
    'ru': 'Пробег при последнем сервисе ({unit})', 'ar': 'المسافة عند آخر خدمة ({unit})', 'uk': 'Пробіг під час останнього сервісу ({unit})', 'ro': 'Kilometraj la ultimul service ({unit})', 'pl': 'Przebieg przy ostatnim serwisie ({unit})',
  },
  'last_service_date_label': {
    'en': 'Last service date', 'de': 'Letztes Servicedatum', 'fa': 'تاریخ آخرین سرویس', 'tr': 'Son servis tarihi',
    'ru': 'Дата последнего сервиса', 'ar': 'تاريخ آخر خدمة', 'uk': 'Дата останнього сервісу', 'ro': 'Data ultimului service', 'pl': 'Data ostatniego serwisu',
  },
  'no_date_set': {
    'en': 'Not set', 'de': 'Nicht festgelegt', 'fa': 'ثبت نشده', 'tr': 'Belirlenmedi',
    'ru': 'Не указано', 'ar': 'غير محدد', 'uk': 'Не вказано', 'ro': 'Nesetat', 'pl': 'Nie ustawiono',
  },
  'reminder_status_on': {
    'en': 'Reminder on', 'de': 'Erinnerung an', 'fa': 'یادآور فعال', 'tr': 'Hatırlatıcı açık',
    'ru': 'Напоминание включено', 'ar': 'التذكير مفعّل', 'uk': 'Нагадування увімкнено', 'ro': 'Memento activ', 'pl': 'Przypomnienie włączone',
  },
  'reminder_status_off': {
    'en': 'Reminder off', 'de': 'Erinnerung aus', 'fa': 'یادآور خاموش', 'tr': 'Hatırlatıcı kapalı',
    'ru': 'Напоминание выключено', 'ar': 'التذكير متوقف', 'uk': 'Нагадування вимкнено', 'ro': 'Memento oprit', 'pl': 'Przypomnienie wyłączone',
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
  'mile': {
    'en': '{val} mi', 'de': '{val} mi', 'fa': '{val} مایل', 'tr': '{val} mil',
    'ru': '{val} миль', 'ar': '{val} ميل', 'uk': '{val} миль', 'ro': '{val} mile', 'pl': '{val} mil',
  },
  'unit_km': {
    'en': 'km', 'de': 'km', 'fa': 'کیلومتر', 'tr': 'km',
    'ru': 'км', 'ar': 'كم', 'uk': 'км', 'ro': 'km', 'pl': 'km',
  },
  'unit_mile': {
    'en': 'mi', 'de': 'mi', 'fa': 'مایل', 'tr': 'mil',
    'ru': 'миль', 'ar': 'ميل', 'uk': 'миль', 'ro': 'mile', 'pl': 'mil',
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
    'en': 'Current Mileage ({unit})', 'de': 'Aktueller Kilometerstand ({unit})', 'fa': 'کارکرد فعلی ({unit})', 'tr': 'Güncel Kilometre ({unit})',
    'ru': 'Текущий пробег ({unit})', 'ar': 'المسافة الحالية ({unit})', 'uk': 'Поточний пробіг ({unit})', 'ro': 'Kilometraj curent ({unit})', 'pl': 'Aktualny przebieg ({unit})',
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
   'en': 'Repair shop phone number',
  'de': 'Werkstatt-Telefonnummer',
  'fa': 'شماره تلفن تعمیرگاه',
  'tr': 'Tamirhane telefon numarası',
  'ru': 'Номер телефона мастерской',
  'ar': 'رقم هاتف ورشة التصليح',
  'uk': 'Номер телефону майстерні',
  'ro': 'Număr de telefon atelier',
  'pl': 'Numer telefonu warsztatu',
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
  },'service_due_days': {
    'en': '{item} is due in {days} days.', 
    'de': '{item} ist in {days} Tagen fällig.', 
    'fa': '{days} روز تا سرویس {item} مانده.', 
    'tr': '{item} için {days} gün kaldı.',
    'ru': 'До обслуживания {item} осталось {days} дн.', 
    'ar': 'متبقي {days} يوم على صيانة {item}.', 
    'uk': 'До обслуговування {item} залишилось {days} дн.', 
    'ro': '{item} expiră în {days} zile.', 
    'pl': 'Serwis {item} za {days} dni.',
  },
  'service_overdue': {
    'en': '{item} is overdue.', 
    'de': '{item} ist überfällig.', 
    'fa': 'موعد سرویس {item} گذشته است.', 
    'tr': '{item} süresi geçmiş.',
    'ru': 'Срок обслуживания {item} истек.', 
    'ar': 'تأخرت صيانة {item}.', 
    'uk': 'Термін обслуговування {item} минув.', 
    'ro': '{item} a depășit termenul.', 
    'pl': 'Termin serwisu {item} minął.',
  },
  'service_due_km': {
    'en': '{item} is due in {km} km.', 
    'de': '{item} ist in {km} km fällig.', 
    'fa': '{km} کیلومتر تا سرویس {item} مانده.', 
    'tr': '{item} için {km} km kaldı.',
    'ru': 'До обслуживания {item} осталось {km} км.', 
    'ar': 'متبقي {km} كم على صيانة {item}.', 
    'uk': 'До обслуговування {item} залишилось {km} км.', 
    'ro': '{item} expiră în {km} km.', 
    'pl': 'Serwis {item} za {km} km.',
  },
  'service_check_now': {
    'en': 'Please check your {item} now.', 
    'de': 'Bitte überprüfen Sie {item} jetzt.', 
    'fa': 'لطفاً {item} ماشین را چک کنید.', 
    'tr': 'Lütfen şimdi {item} kontrol edin.',
    'ru': 'Пожалуйста, проверьте {item} прямо сейчас.', 
    'ar': 'الرجاء فحص {item} الآن.', 
    'uk': 'Будь ласка, перевірте {item} прямо зараз.', 
    'ro': 'Vă rugăm să verificați {item} acum.', 
    'pl': 'Sprawdź {item} teraz.',
  },
  'service_active': {
    'en': 'Reminder active for {item}.', 
    'de': 'Erinnerung aktiv für {item}.', 
    'fa': 'یادآور {item} فعال است.', 
    'tr': '{item} için hatırlatıcı aktif.',
    'ru': 'Напоминание для {item} активно.', 
    'ar': 'التذكير نشط لـ {item}.', 
    'uk': 'Нагадування для {item} активне.', 
    'ro': 'Memento activ pentru {item}.', 
    'pl': 'Przypomnienie aktywne dla {item}.',
  },
  'grouped_service_alert_body': {
    'en': 'You have {count} messages in your car service section, please check.', 
    'de': 'Sie haben {count} Nachrichten im Servicebereich, bitte prüfen.', 
    'fa': 'شما {count} پیغام در بخش سرویس ماشین دارید، لطفاً چک کنید.', 
    'tr': 'Araç servis bölümünde {count} mesajınız var, lütfen kontrol edin.',
    'ru': 'У вас {count} сообщ. в разделе обслуживания, пожалуйста, проверьте.', 
    'ar': 'لديك {count} رسائل في قسم صيانة السيارة، الرجاء التحقق.', 
    'uk': 'У вас {count} повід. у розділі обслуговування, будь ласка, перевірте.', 
    'ro': 'Aveți {count} mesaje în secțiunea de service auto, vă rugăm să verificați.', 
    'pl': 'Masz {count} wiadomości w sekcji serwisu auta, sprawdź je.',
  },
  'btn_open': { 
    'en': 'Open Services', 'de': 'Öffnen', 'fa': 'ورود به سرویس', 'tr': 'Servisleri Aç',
    'ru': 'Открыть сервис', 'ar': 'فتح الخدمات', 'uk': 'Відкрити сервіс', 'ro': 'Deschide Service', 'pl': 'Otwórz Serwis',
  },
  'btn_delete': { 
    'en': 'Delete Alarm', 'de': 'Alarm löschen', 'fa': 'حذف آلارم', 'tr': 'Alarmi Sil',
    'ru': 'Удалить будильник', 'ar': 'حذف التنبيه', 'uk': 'Видалити будильник', 'ro': 'Șterge Alarma', 'pl': 'Usuń Alarm',
  },
  'btn_snooze': { 
    'en': 'Remind Tomorrow', 'de': 'Morgen erinnern', 'fa': 'فردا یادآوری کن', 'tr': 'Yarın Hatırlat',
    'ru': 'Напомнить завтра', 'ar': 'تذكير غداً', 'uk': 'Нагадати завтра', 'ro': 'Amintește-mi mâine', 'pl': 'Przypomnij jutro',
  },
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
  'iap_timeout': {
    'en': 'The purchase process timed out. Please try again.', 'de': 'Der Kaufvorgang hat das Zeitlimit überschritten. Bitte versuchen Sie es erneut.', 'fa': 'زمان فرآیند خرید به پایان رسید. لطفاً دوباره تلاش کنید.', 'tr': 'Satın alma işlemi zaman aşımına uğradı. Lütfen tekrar deneyin.',
    'ru': 'Время ожидания покупки истекло. Пожалуйста, попробуйте снова.', 'ar': 'انتهت مهلة عملية الشراء. حاول مرة أخرى.', 'uk': 'Час очікування покупки минув. Спробуйте ще раз.', 'ro': 'Procesul de achiziție a expirat. Vă rugăm încercați din nou.', 'pl': 'Upłynął limit czasu zakupu. Spróbuj ponownie.',
  },
  'iap_subscription_price_line': {
    'en': '6-Month Premium Subscription – €6.99 every 6 months', 'de': '6-Monats-Premium-Abo – 6,99 € alle 6 Monate', 'fa': 'اشتراک 6ماهه پرمیوم - ۶.۹۹ یورو برای هر 6 ماه', 'tr': '6 Aylık Premium Abonelik – Her 6 ayda bir 6,99 €',
    'ru': 'Премиум-подписка на 6 месяцев – 6,99 € каждые 6 месяцев', 'ar': 'اشتراك مميز لمدة 6 أشهر - 6.99 يورو كل 6 أشهر', 'uk': 'Преміум-підписка на 6 місяців – 6,99 € кожні 6 місяців', 'ro': 'Abonament Premium de 6 luni – 6,99 € la fiecare 6 luni', 'pl': 'Subskrypcja Premium na 6 miesięcy – 6,99 € co 6 miesięcy',
  },
  'iap_privacy_policy_link': {
    'en': 'Privacy Policy', 'de': 'Datenschutzrichtlinie', 'fa': 'سیاست حریم خصوصی (Privacy Policy)', 'tr': 'Gizlilik Politikası',
    'ru': 'Политика конфиденциальности', 'ar': 'سياسة الخصوصية', 'uk': 'Політика конфіденційності', 'ro': 'Politica de confidențialitate', 'pl': 'Polityka prywatności',
  },
  'iap_terms_of_use_link': {
    'en': 'Terms of Use', 'de': 'Nutzungsbedingungen', 'fa': 'شرایط استفاده (Terms of Use)', 'tr': 'Kullanım Şartları',
    'ru': 'Условия использования', 'ar': 'شروط الاستخدام', 'uk': 'Умови використання', 'ro': 'Termeni de utilizare', 'pl': 'Warunki korzystania',
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
  'insurance_company': {
    'en': 'Insurance company', 'de': 'Versicherungsgesellschaft', 'fa': 'نام شرکت بیمه', 'tr': 'Sigorta şirketi',
    'ru': 'Страховая компания', 'ar': 'شركة التأمين', 'uk': 'Страхова компанія', 'ro': 'Companie de asigurări', 'pl': 'Firma ubezpieczeniowa',
  },
  'workshop_name': {
    'en': 'Repair shop name', 'de': 'Name der Werkstatt', 'fa': 'نام تعمیرگاه', 'tr': 'Tamirhane adı',
    'ru': 'Название мастерской', 'ar': 'اسم ورشة التصليح', 'uk': 'Назва майстерні', 'ro': 'Numele atelierului', 'pl': 'Nazwa warsztatu',
  },
  'pick_from_contacts': {
    'en': 'Pick from contacts', 'de': 'Aus Kontakten wählen', 'fa': 'انتخاب از دفترچه تلفن', 'tr': 'Rehberden seç',
    'ru': 'Выбрать из контактов', 'ar': 'اختر من جهات الاتصال', 'uk': 'Обрати з контактів', 'ro': 'Alege din contacte', 'pl': 'Wybierz z kontaktów',
  },
  'contact_no_phone': {
    'en': 'That contact has no phone number.', 'de': 'Dieser Kontakt hat keine Telefonnummer.', 'fa': 'این مخاطب شماره تلفنی ندارد.', 'tr': 'Bu kişide telefon numarası yok.',
    'ru': 'У этого контакта нет номера телефона.', 'ar': 'لا يحتوي جهة الاتصال هذه على رقم هاتف.', 'uk': 'Цей контакт не має номера телефону.', 'ro': 'Acest contact nu are număr de telefon.', 'pl': 'Ten kontakt nie ma numeru telefonu.',
  },
  'contacts_permission_denied': {
    'en': 'Contacts access was denied, so nothing could be picked.', 'de': 'Zugriff auf Kontakte verweigert, es konnte nichts ausgewählt werden.', 'fa': 'دسترسی به دفترچه تلفن داده نشد، پس چیزی انتخاب نشد.', 'tr': 'Kişilere erişim reddedildi, bu yüzden seçim yapılamadı.',
    'ru': 'Доступ к контактам запрещён, выбрать ничего не удалось.', 'ar': 'تم رفض الوصول إلى جهات الاتصال، لذا لم يتم اختيار شيء.', 'uk': 'Доступ до контактів заборонено, нічого не вибрано.', 'ro': 'Accesul la contacte a fost refuzat, nu s-a putut selecta nimic.', 'pl': 'Odmówiono dostępu do kontaktów, nic nie wybrano.',
  },
  'contact_pick_failed': {
    'en': 'Could not open contacts. You can type the number instead.', 'de': 'Kontakte konnten nicht geöffnet werden. Sie können die Nummer stattdessen eingeben.', 'fa': 'باز کردن دفترچه تلفن ممکن نشد. می‌تونی شماره رو دستی تایپ کنی.', 'tr': 'Kişiler açılamadı. Numarayı elle yazabilirsiniz.',
    'ru': 'Не удалось открыть контакты. Введите номер вручную.', 'ar': 'تعذر فتح جهات الاتصال. يمكنك كتابة الرقم يدويًا.', 'uk': 'Не вдалося відкрити контакти. Введіть номер вручну.', 'ro': 'Nu s-au putut deschide contactele. Puteți introduce numărul manual.', 'pl': 'Nie udało się otworzyć kontaktów. Możesz wpisać numer ręcznie.',
  },
  'vehicle_info_section': {
    'en': 'Vehicle', 'de': 'Fahrzeug', 'fa': 'اطلاعات خودرو', 'tr': 'Araç',
    'ru': 'Автомобиль', 'ar': 'المركبة', 'uk': 'Автомобіль', 'ro': 'Vehicul', 'pl': 'Pojazd',
  },
  'contacts_section': {
    'en': 'Contacts', 'de': 'Kontakte', 'fa': 'اطلاعات تماس', 'tr': 'Kişiler',
    'ru': 'Контакты', 'ar': 'جهات الاتصال', 'uk': 'Контакти', 'ro': 'Contacte', 'pl': 'Kontakty',
  },
  'car_model_hint': {
    'en': 'e.g. Mercedes G-Class', 'de': 'z. B. Mercedes G-Klasse', 'fa': 'مثال: Mercedes G-Class', 'tr': 'ör. Mercedes G-Class',
    'ru': 'напр. Mercedes G-Class', 'ar': 'مثال: Mercedes G-Class', 'uk': 'напр. Mercedes G-Class', 'ro': 'ex. Mercedes G-Class', 'pl': 'np. Mercedes G-Class',
  },
  'add_car_model': {
    'en': 'Add car model', 'de': 'Automodell hinzufügen', 'fa': 'افزودن مدل خودرو', 'tr': 'Araç modeli ekle',
    'ru': 'Добавить модель авто', 'ar': 'إضافة موديل السيارة', 'uk': 'Додати модель авто', 'ro': 'Adaugă model auto', 'pl': 'Dodaj model samochodu',
  },
  'add_insurance_phone': {
    'en': 'Add insurance phone', 'de': 'Versicherungstelefon hinzufügen', 'fa': 'افزودن تلفن بیمه', 'tr': 'Sigorta telefonu ekle',
    'ru': 'Добавить телефон страховой', 'ar': 'إضافة هاتف التأمين', 'uk': 'Додати телефон страховки', 'ro': 'Adaugă telefon asigurare', 'pl': 'Dodaj telefon do ubezpieczenia',
  },
  'add_workshop_info': {
    'en': 'Add repair shop info', 'de': 'Werkstattinfo hinzufügen', 'fa': 'افزودن اطلاعات تعمیرگاه', 'tr': 'Tamirhane bilgisi ekle',
    'ru': 'Добавить данные мастерской', 'ar': 'إضافة معلومات ورشة التصليح', 'uk': 'Додати дані майстерні', 'ro': 'Adaugă date atelier', 'pl': 'Dodaj dane warsztatu',
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
  'navigate_with': {
    'en': 'Navigate with',
    'de': 'Navigieren mit',
    'fa': 'مسیریابی با',
    'tr': 'Şununla git',
    'ru': 'Построить маршрут в',
    'ar': 'التنقل باستخدام',
    'uk': 'Побудувати маршрут у',
    'ro': 'Navighează cu',
    'pl': 'Nawiguj za pomocą',
  },
  'apple_maps': {
    'en': 'Apple Maps', 'de': 'Apple Maps', 'fa': 'Apple Maps', 'tr': 'Apple Maps',
    'ru': 'Apple Maps', 'ar': 'Apple Maps', 'uk': 'Apple Maps', 'ro': 'Apple Maps', 'pl': 'Apple Maps',
  },
  'google_maps': {
    'en': 'Google Maps', 'de': 'Google Maps', 'fa': 'Google Maps', 'tr': 'Google Maps',
    'ru': 'Google Maps', 'ar': 'Google Maps', 'uk': 'Google Maps', 'ro': 'Google Maps', 'pl': 'Google Maps',
  },
  'apple_maps_subtitle': {
    'en': 'Open directions in Apple Maps',
    'de': 'Route in Apple Maps öffnen',
    'fa': 'باز کردن مسیر در Apple Maps',
    'tr': 'Apple Maps ile yol tarifi',
    'ru': 'Открыть маршрут в Apple Maps',
    'ar': 'فتح الاتجاهات في Apple Maps',
    'uk': 'Відкрити маршрут у Apple Maps',
    'ro': 'Deschide ruta în Apple Maps',
    'pl': 'Otwórz trasę w Apple Maps',
  },
  'google_maps_subtitle': {
    'en': 'Open directions in Google Maps',
    'de': 'Route in Google Maps öffnen',
    'fa': 'باز کردن مسیر در Google Maps',
    'tr': 'Google Maps ile yol tarifi',
    'ru': 'Открыть маршрут в Google Maps',
    'ar': 'فتح الاتجاهات في Google Maps',
    'uk': 'Відкрити маршрут у Google Maps',
    'ro': 'Deschide ruta în Google Maps',
    'pl': 'Otwórz trasę w Google Maps',
  },
  'map_launch_failed': {
    'en': 'Could not open the maps app.',
    'de': 'Karten-App konnte nicht geöffnet werden.',
    'fa': 'باز کردن برنامه نقشه ممکن نشد.',
    'tr': 'Harita uygulaması açılamadı.',
    'ru': 'Не удалось открыть приложение карт.',
    'ar': 'تعذر فتح تطبيق الخرائط.',
    'uk': 'Не вдалося відкрити програму карт.',
    'ro': 'Nu s-a putut deschide aplicația de hărți.',
    'pl': 'Nie udało się otworzyć aplikacji map.',
  },
  'parking_no_data_redirect': {
    'en': 'No parking found nearby. Choose a maps app to search.',
    'de': 'Kein Parkplatz in der Nähe gefunden. Wähle eine Karten-App.',
    'fa': 'پارکینگی در این محدوده یافت نشد. یک برنامه نقشه انتخاب کنید.',
    'tr': 'Yakında otopark bulunamadı. Bir harita uygulaması seçin.',
    'ru': 'Парковка рядом не найдена. Выберите приложение карт.',
    'ar': 'لم يتم العثور على موقف سيارات. اختر تطبيق خرائط.',
    'uk': 'Парковку поруч не знайдено. Оберіть додаток карт.',
    'ro': 'Nu s-a găsit parcare. Alegeți o aplicație de hărți.',
    'pl': 'Nie znaleziono parkingu. Wybierz aplikację map.',
  },
  'ok': {
    'en': 'OK', 'de': 'OK', 'fa': 'باشه', 'tr': 'Tamam',
    'ru': 'ОК', 'ar': 'حسنًا', 'uk': 'OK', 'ro': 'OK', 'pl': 'OK',
  },
  'decline': {
    'en': 'Decline', 'de': 'Ablehnen', 'fa': 'رد کردن', 'tr': 'Reddet',
    'ru': 'Отклонить', 'ar': 'رفض', 'uk': 'Відхилити', 'ro': 'Refuză', 'pl': 'Odrzuć',
  },
  'add': {
    'en': 'Add', 'de': 'Hinzufügen', 'fa': 'افزودن', 'tr': 'Ekle',
    'ru': 'Добавить', 'ar': 'إضافة', 'uk': 'Додати', 'ro': 'Adaugă', 'pl': 'Dodaj',
  },
  'language': {
    'en': 'Language', 'de': 'Sprache', 'fa': 'زبان', 'tr': 'Dil',
    'ru': 'Язык', 'ar': 'اللغة', 'uk': 'Мова', 'ro': 'Limbă', 'pl': 'Język',
  },
  'consent_continue': {
    'en': 'Continue', 'de': 'Weiter', 'fa': 'ادامه', 'tr': 'Devam',
    'ru': 'Продолжить', 'ar': 'متابعة', 'uk': 'Продовжити', 'ro': 'Continuă', 'pl': 'Kontynuuj',
  },
  'consent_not_now': {
    'en': 'Not now', 'de': 'Nicht jetzt', 'fa': 'الان نه', 'tr': 'Şimdi değil',
    'ru': 'Не сейчас', 'ar': 'ليس الآن', 'uk': 'Не зараз', 'ro': 'Nu acum', 'pl': 'Nie teraz',
  },
  'consent_location_title': {
    'en': 'Location for navigation',
    'de': 'Standort für Navigation',
    'fa': 'موقعیت مکانی برای مسیریابی',
    'tr': 'Navigasyon için konum',
    'ru': 'Геолокация для навигации',
    'ar': 'الموقع للملاحة',
    'uk': 'Місцезнаходження для навігації',
    'ro': 'Locație pentru navigație',
    'pl': 'Lokalizacja do nawigacji',
  },
  'consent_location_body': {
    'en': 'This app uses your location only after you choose nearby search or navigation.\n\n• Find nearby fuel stations and parking around you\n• Start turn-by-turn directions in Apple Maps or Google Maps\n• Used on this device while the app is open; we do not sell location data\n• We do not store your GPS on our servers for this feature\n• You can deny access and still search by city or postal code\n\nIf you continue, the next screen is the system permission from Apple or Google. You can change this later in system settings.',
    'de': 'Diese App nutzt Ihren Standort erst, wenn Sie die Suche in der Nähe oder die Navigation wählen.\n\n• Tankstellen und Parkplätze in der Nähe finden\n• Zielführung in Apple Maps oder Google Maps starten\n• Nur auf diesem Gerät, während die App geöffnet ist; keine Standortdaten werden verkauft\n• GPS wird für diese Funktion nicht auf unseren Servern gespeichert\n• Sie können ablehnen und weiter per Stadt oder PLZ suchen\n\nWenn Sie fortfahren, folgt die Systemabfrage von Apple oder Google. Später in den Systemeinstellungen änderbar.',
    'fa': 'این برنامه موقعیت مکانی را فقط وقتی استفاده می‌کند که جستجوی نزدیک یا مسیریابی را انتخاب کنید.\n\n• پیدا کردن پمپ‌بنزین و پارکینگ اطراف شما\n• شروع راهنمای مسیر در Apple Maps یا Google Maps\n• فقط روی همین دستگاه و وقتی برنامه باز است؛ داده موقعیت فروخته نمی‌شود\n• مختصات GPS برای این قابلیت روی سرور ما ذخیره نمی‌شود\n• می‌توانید رد کنید و همچنان با شهر یا کد پستی جستجو کنید\n\nاگر ادامه دهید، در مرحله بعد سیستم‌عامل اپل یا گوگل اجازه را می‌پرسد. بعداً در تنظیمات سیستم قابل تغییر است.',
    'tr': 'Bu uygulama konumunuzu yalnızca yakındaki arama veya navigasyonu seçtiğinizde kullanır.\n\n• Yakındaki istasyon ve otoparkları bulmak\n• Apple Maps veya Google Maps ile yol tarifi başlatmak\n• Yalnızca uygulama açıkken bu cihazda; konum satılmaz\n• GPS bu özellik için sunucularımızda saklanmaz\n• Reddedebilir ve şehir/posta kodu ile aramaya devam edebilirsiniz\n\nDevam ederseniz bir sonraki adım Apple veya Google sistem iznidir. Daha sonra sistem ayarlarından değiştirebilirsiniz.',
    'ru': 'Приложение использует геолокацию только после выбора поиска рядом или навигации.\n\n• Поиск заправок и парковок рядом с вами\n• Маршрут в Apple Maps или Google Maps\n• Только на этом устройстве, пока приложение открыто; данные не продаются\n• GPS для этой функции не хранится на наших серверах\n• Можно отказать и искать по городу или индексу\n\nЕсли продолжите, система Apple или Google запросит разрешение. Позже это можно изменить в настройках.',
    'ar': 'يستخدم التطبيق موقعك فقط بعد اختيار البحث القريب أو التنقل.\n\n• العثور على محطات الوقود ومواقف السيارات القريبة\n• بدء التوجيه في Apple Maps أو Google Maps\n• على هذا الجهاز أثناء فتح التطبيق؛ لا نبيع بيانات الموقع\n• لا نخزّن GPS لهذه الميزة على خوادمنا\n• يمكنك الرفض والبحث بالمدينة أو الرمز البريدي\n\nإذا تابعت، سيطلب نظام Apple أو Google الإذن بعد ذلك. يمكنك تغيير ذلك لاحقاً من إعدادات النظام.',
    'uk': 'Додаток використовує місцезнаходження лише після вибору пошуку поряд або навігації.\n\n• Пошук заправок і парковок поруч\n• Маршрут в Apple Maps або Google Maps\n• Лише на цьому пристрої, поки додаток відкритий; дані не продаються\n• GPS для цієї функції не зберігається на наших серверах\n• Можна відмовити й шукати за містом чи індексом\n\nЯкщо продовжите, система Apple або Google запитає дозвіл. Пізніше це можна змінити в налаштуваннях.',
    'ro': 'Aplicația folosește locația doar după ce alegeți căutarea din apropiere sau navigația.\n\n• Găsirea stațiilor și parcărilor din apropiere\n• Indicații în Apple Maps sau Google Maps\n• Doar pe acest dispozitiv cât timp aplicația e deschisă; nu vindem datele de locație\n• GPS-ul nu este stocat pe serverele noastre pentru această funcție\n• Puteți refuza și căuta după oraș sau cod poștal\n\nDacă continuați, sistemul Apple sau Google va cere permisiunea. O puteți schimba ulterior în setări.',
    'pl': 'Aplikacja używa lokalizacji dopiero po wyborze wyszukiwania w pobliżu lub nawigacji.\n\n• Znajdowanie stacji i parkingów w okolicy\n• Prowadzenie w Apple Maps lub Google Maps\n• Tylko na tym urządzeniu, gdy aplikacja jest otwarta; nie sprzedajemy lokalizacji\n• GPS nie jest zapisywany na naszych serwerach dla tej funkcji\n• Możesz odmówić i szukać po mieście lub kodzie pocztowym\n\nJeśli kontynuujesz, system Apple lub Google poprosi o zgodę. Później zmienisz to w ustawieniach systemu.',
  },
  'consent_notification_title': {
    'en': 'Reminders and alarms',
    'de': 'Erinnerungen und Alarme',
    'fa': 'یادآورها و هشدارها',
    'tr': 'Hatırlatıcılar ve alarmlar',
    'ru': 'Напоминания и сигналы',
    'ar': 'التذكيرات والتنبيهات',
    'uk': 'Нагадування та будильники',
    'ro': 'Memento-uri și alarme',
    'pl': 'Przypomnienia i alarmy',
  },
  'consent_notification_body': {
    'en': 'To remind you about oil changes, TÜV, tires and other service dates, this app needs permission to send notifications.\n\n• Reminders are scheduled on this device for dates you enter\n• We do not use this permission for marketing spam\n• You can turn alarms off in the app or in system settings at any time\n• Notifications are optional; the rest of the app still works without them\n\nIf you continue, the next screen is the system permission from Apple or Google.',
    'de': 'Für Erinnerungen zu Ölwechsel, TÜV, Reifen und anderen Serviceterminen braucht die App die Berechtigung für Mitteilungen.\n\n• Erinnerungen werden auf diesem Gerät für von Ihnen eingegebene Daten geplant\n• Keine Marketing-Spam-Nachrichten\n• Alarme können Sie jederzeit in der App oder in den Systemeinstellungen deaktivieren\n• Mitteilungen sind optional; die App funktioniert auch ohne\n\nWenn Sie fortfahren, folgt die Systemabfrage von Apple oder Google.',
    'fa': 'برای یادآوری تعویض روغن، TÜV، تایر و سایر تاریخ‌های سرویس، برنامه به اجازه ارسال اعلان نیاز دارد.\n\n• یادآورها روی همین دستگاه و بر اساس تاریخ‌هایی که خودتان وارد می‌کنید زمان‌بندی می‌شوند\n• از این اجازه برای پیام تبلیغاتی استفاده نمی‌شود\n• هر وقت بخواهید می‌توانید آلارم را در برنامه یا تنظیمات سیستم خاموش کنید\n• اعلان اختیاری است؛ بقیه برنامه بدون آن کار می‌کند\n\nاگر ادامه دهید، در مرحله بعد سیستم‌عامل اپل یا گوگل اجازه را می‌پرسد.',
    'tr': 'Yağ değişimi, TÜV, lastik ve diğer servis tarihlerini hatırlatmak için uygulamanın bildirim iznine ihtiyacı vardır.\n\n• Hatırlatıcılar bu cihazda, sizin girdiğiniz tarihlere göre planlanır\n• Bu izin pazarlama spam’i için kullanılmaz\n• Alarmı istediğiniz zaman uygulamada veya sistem ayarlarında kapatabilirsiniz\n• Bildirimler isteğe bağlıdır; uygulamanın geri kalanı çalışmaya devam eder\n\nDevam ederseniz bir sonraki adım Apple veya Google sistem iznidir.',
    'ru': 'Чтобы напоминать о замене масла, TÜV, шинах и других датах сервиса, приложению нужно разрешение на уведомления.\n\n• Напоминания планируются на этом устройстве по датам, которые вы вводите\n• Мы не используем это для рекламного спама\n• Сигнал можно отключить в приложении или в настройках системы\n• Уведомления необязательны; остальное приложение работает без них\n\nЕсли продолжите, система Apple или Google запросит разрешение.',
    'ar': 'لتذكيرك بتغيير الزيت وTÜV والإطارات ومواعيد الخدمة الأخرى يحتاج التطبيق إلى إذن الإشعارات.\n\n• تُجدول التذكيرات على هذا الجهاز حسب التواريخ التي تدخلها\n• لا نستخدم هذا الإذن للرسائل الإعلانية\n• يمكنك إيقاف التنبيه في التطبيق أو إعدادات النظام في أي وقت\n• الإشعارات اختيارية؛ بقية التطبيق تعمل بدونها\n\nإذا تابعت، سيطلب نظام Apple أو Google الإذن بعد ذلك.',
    'uk': 'Щоб нагадувати про заміну оливи, TÜV, шини та інші дати сервісу, потрібен дозвіл на сповіщення.\n\n• Нагадування плануються на цьому пристрої за датами, які ви вводите\n• Ми не використовуємо це для рекламного спаму\n• Будильник можна вимкнути в додатку або в системних налаштуваннях\n• Сповіщення необов’язкові; решта додатка працює без них\n\nЯкщо продовжите, система Apple або Google запитає дозвіл.',
    'ro': 'Pentru a vă reaminti schimbul de ulei, TÜV, anvelope și alte date de service, aplicația are nevoie de permisiunea de notificări.\n\n• Memento-urile sunt programate pe acest dispozitiv după datele pe care le introduceți\n• Nu folosim această permisiune pentru spam de marketing\n• Puteți opri alarma oricând în aplicație sau în setările sistemului\n• Notificările sunt opționale; restul aplicației funcționează fără ele\n\nDacă continuați, sistemul Apple sau Google va cere permisiunea.',
    'pl': 'Aby przypominać o wymianie oleju, TÜV, oponach i innych terminach serwisu, aplikacja potrzebuje zgody na powiadomienia.\n\n• Przypomnienia są planowane na tym urządzeniu według dat, które wpisujesz\n• Nie używamy tej zgody do spamu marketingowego\n• Alarm możesz wyłączyć w aplikacji lub w ustawieniach systemu\n• Powiadomienia są opcjonalne; reszta aplikacji działa bez nich\n\nJeśli kontynuujesz, system Apple lub Google poprosi o zgodę.',
  },
  'os_permission_denied_location': {
    'en': 'Location permission was not granted. Navigation cannot start.',
    'de': 'Standortzugriff wurde nicht erteilt. Navigation kann nicht starten.',
    'fa': 'اجازه موقعیت مکانی داده نشد. مسیریابی شروع نمی‌شود.',
    'tr': 'Konum izni verilmedi. Navigasyon başlatılamaz.',
    'ru': 'Доступ к геолокации не дан. Навигация не запустится.',
    'ar': 'لم يُمنح إذن الموقع. لا يمكن بدء التنقل.',
    'uk': 'Дозвіл на місцезнаходження не надано. Навігацію не можна почати.',
    'ro': 'Permisiunea de locație nu a fost acordată. Navigația nu poate porni.',
    'pl': 'Nie udzielono zgody na lokalizację. Nie można uruchomić nawigacji.',
  },
  'os_permission_denied_notification': {
    'en': 'Notification permission was not granted. The alarm was not enabled.',
    'de': 'Mitteilungen wurden nicht erlaubt. Der Alarm wurde nicht aktiviert.',
    'fa': 'اجازه اعلان داده نشد. آلارم فعال نشد.',
    'tr': 'Bildirim izni verilmedi. Alarm açılmadı.',
    'ru': 'Разрешение на уведомления не дано. Сигнал не включён.',
    'ar': 'لم يُمنح إذن الإشعارات. لم يتم تفعيل التنبيه.',
    'uk': 'Дозвіл на сповіщення не надано. Будильник не увімкнено.',
    'ro': 'Permisiunea de notificări nu a fost acordată. Alarma nu a fost activată.',
    'pl': 'Nie udzielono zgody na powiadomienia. Alarm nie został włączony.',
  },
  'email_reminder_title': {
    'en': 'Email reminder settings', 'de': 'E-Mail-Erinnerungen', 'fa': 'تنظیمات یادآور ایمیلی', 'tr': 'E-posta hatırlatıcı ayarları',
    'ru': 'Настройки email-напоминаний', 'ar': 'إعدادات تذكير البريد', 'uk': 'Налаштування email-нагадувань', 'ro': 'Setări memento e-mail', 'pl': 'Ustawienia przypomnień e-mail',
  },
  'email_reminder_intro': {
    'en': 'Enter your email to receive periodic service reminders:',
    'de': 'Geben Sie Ihre E-Mail ein, um Service-Erinnerungen zu erhalten:',
    'fa': 'برای دریافت هشدارهای سرویس دوره‌ای، ایمیل خود را وارد کنید:',
    'tr': 'Periyodik servis hatırlatmaları için e-posta adresinizi girin:',
    'ru': 'Введите email, чтобы получать напоминания о сервисе:',
    'ar': 'أدخل بريدك لتلقي تذكيرات الخدمة الدورية:',
    'uk': 'Введіть email, щоб отримувати нагадування про сервіс:',
    'ro': 'Introduceți e-mailul pentru memento-uri de service:',
    'pl': 'Podaj e-mail, aby otrzymywać przypomnienia serwisowe:',
  },
  'email_label': {
    'en': 'Email address', 'de': 'E-Mail-Adresse', 'fa': 'آدرس ایمیل', 'tr': 'E-posta adresi',
    'ru': 'Адрес электронной почты', 'ar': 'عنوان البريد', 'uk': 'Електронна адреса', 'ro': 'Adresă de e-mail', 'pl': 'Adres e-mail',
  },
  'email_saved': {
    'en': 'Email saved and reminder enabled.',
    'de': 'E-Mail gespeichert und Erinnerung aktiviert.',
    'fa': 'ایمیل با موفقیت ثبت و آلارم فعال شد.',
    'tr': 'E-posta kaydedildi ve hatırlatıcı açıldı.',
    'ru': 'Email сохранён, напоминание включено.',
    'ar': 'تم حفظ البريد وتفعيل التذكير.',
    'uk': 'Email збережено, нагадування увімкнено.',
    'ro': 'E-mail salvat și memento activat.',
    'pl': 'E-mail zapisany, przypomnienie włączone.',
  },
  'email_invalid': {
    'en': 'Please enter a valid email.',
    'de': 'Bitte geben Sie eine gültige E-Mail ein.',
    'fa': 'لطفا یک ایمیل معتبر وارد کنید.',
    'tr': 'Lütfen geçerli bir e-posta girin.',
    'ru': 'Введите корректный email.',
    'ar': 'يرجى إدخال بريد صالح.',
    'uk': 'Введіть коректний email.',
    'ro': 'Introduceți un e-mail valid.',
    'pl': 'Podaj poprawny adres e-mail.',
  },
  'email_save_activate': {
    'en': 'Save and enable', 'de': 'Speichern und aktivieren', 'fa': 'ذخیره و فعال‌سازی', 'tr': 'Kaydet ve etkinleştir',
    'ru': 'Сохранить и включить', 'ar': 'حفظ وتفعيل', 'uk': 'Зберегти та увімкнути', 'ro': 'Salvează și activează', 'pl': 'Zapisz i włącz',
  },
  'email_tooltip': {
    'en': 'Email reminder settings', 'de': 'E-Mail-Erinnerung', 'fa': 'تنظیم ایمیل یادآور', 'tr': 'E-posta hatırlatıcı',
    'ru': 'Настройки email-напоминаний', 'ar': 'إعداد تذكير البريد', 'uk': 'Налаштування email-нагадування', 'ro': 'Setări memento e-mail', 'pl': 'Ustawienia e-mail',
  },
  'email_tuv_title': {
    'en': 'Send important alerts (TÜV) by email',
    'de': 'Wichtige Hinweise (TÜV) per E-Mail senden',
    'fa': 'ارسال هشدارهای مهم (TÜV) به ایمیل',
    'tr': 'Önemli uyarıları (TÜV) e-posta ile gönder',
    'ru': 'Важные оповещения (TÜV) на email',
    'ar': 'إرسال التنبيهات المهمة (TÜV) بالبريد',
    'uk': 'Надсилати важливі сповіщення (TÜV) на email',
    'ro': 'Trimite alerte importante (TÜV) pe e-mail',
    'pl': 'Wysyłaj ważne alerty (TÜV) e-mailem',
  },
  'email_hint': {
    'en': 'Enter your email (e.g. name@domain.com)',
    'de': 'E-Mail eingeben (z. B. name@domain.com)',
    'fa': 'ایمیل خود را وارد کنید (e.g. name@domain.com)',
    'tr': 'E-postanızı girin (örn. name@domain.com)',
    'ru': 'Введите email (напр. name@domain.com)',
    'ar': 'أدخل بريدك (مثال name@domain.com)',
    'uk': 'Введіть email (напр. name@domain.com)',
    'ro': 'Introduceți e-mailul (ex. name@domain.com)',
    'pl': 'Podaj e-mail (np. name@domain.com)',
  },
  'email_tuv_note': {
    'en': 'Due dates such as the technical inspection (TÜV) will be sent to this email at 09:00.',
    'de': 'Fälligkeiten wie die Hauptuntersuchung (TÜV) werden um 09:00 an diese E-Mail gesendet.',
    'fa': 'سررسید مواردی همچون معاینه فنی (TÜV) رأس ساعت 09:00 صبح به این ایمیل ارسال خواهد شد.',
    'tr': 'TÜV gibi vadeler saat 09:00’da bu e-postaya gönderilir.',
    'ru': 'Сроки вроде техосмотра (TÜV) будут отправлены на этот email в 09:00.',
    'ar': 'تُرسل مواعيد مثل الفحص الفني (TÜV) إلى هذا البريد الساعة 09:00.',
    'uk': 'Терміни на кшталт техогляду (TÜV) надсилатимуться на цей email о 09:00.',
    'ro': 'Scadențe precum inspecția tehnică (TÜV) vor fi trimise pe acest e-mail la 09:00.',
    'pl': 'Terminy takie jak przegląd (TÜV) zostaną wysłane na ten e-mail o 09:00.',
  },
  'email_settings_saved': {
    'en': 'Email settings saved.',
    'de': 'E-Mail-Einstellungen gespeichert.',
    'fa': 'تنظیمات ارسال ایمیل با موفقیت ذخیره شد.',
    'tr': 'E-posta ayarları kaydedildi.',
    'ru': 'Настройки email сохранены.',
    'ar': 'تم حفظ إعدادات البريد.',
    'uk': 'Налаштування email збережено.',
    'ro': 'Setările de e-mail au fost salvate.',
    'pl': 'Zapisano ustawienia e-mail.',
  },
  'support_tooltip': {
    'en': 'Support and suggestions', 'de': 'Support und Vorschläge', 'fa': 'پشتیبانی و پیشنهادات', 'tr': 'Destek ve öneriler',
    'ru': 'Поддержка и предложения', 'ar': 'الدعم والاقتراحات', 'uk': 'Підтримка та пропозиції', 'ro': 'Suport și sugestii', 'pl': 'Wsparcie i sugestie',
  },
  'support_title': {
    'en': 'Support and suggestions', 'de': 'Support und Vorschläge', 'fa': 'پشتیبانی و پیشنهادات', 'tr': 'Destek ve öneriler',
    'ru': 'Поддержка и предложения', 'ar': 'الدعم والاقتراحات', 'uk': 'Підтримка та пропозиції', 'ro': 'Suport și sugestii', 'pl': 'Wsparcie i sugestie',
  },
  'support_body': {
    'en': 'You can send problems or suggestions about the app directly to support.smartcarmanager@gmail.com. Open the email app now?',
    'de': 'Probleme oder Vorschläge können Sie direkt an support.smartcarmanager@gmail.com senden. E-Mail-App jetzt öffnen?',
    'fa': 'شما می‌توانید مشکلات یا پیشنهادات خود را در مورد اپلیکیشن مستقیماً به ایمیل support.smartcarmanager@gmail.com ارسال کنید. آیا مایل به باز کردن برنامه ایمیل هستید؟',
    'tr': 'Sorun veya önerilerinizi doğrudan support.smartcarmanager@gmail.com adresine gönderebilirsiniz. E-posta uygulaması açılsın mı?',
    'ru': 'Проблемы и предложения можно отправить на support.smartcarmanager@gmail.com. Открыть почтовое приложение?',
    'ar': 'يمكنك إرسال المشاكل أو الاقتراحات إلى support.smartcarmanager@gmail.com. هل تريد فتح تطبيق البريد؟',
    'uk': 'Проблеми чи пропозиції можна надіслати на support.smartcarmanager@gmail.com. Відкрити поштовий додаток?',
    'ro': 'Puteți trimite probleme sau sugestii la support.smartcarmanager@gmail.com. Deschideți aplicația de e-mail?',
    'pl': 'Problemy i sugestie możesz wysłać na support.smartcarmanager@gmail.com. Otworzyć aplikację poczty?',
  },
  'support_send_email': {
    'en': 'Send email', 'de': 'E-Mail senden', 'fa': 'ارسال ایمیل', 'tr': 'E-posta gönder',
    'ru': 'Отправить письмо', 'ar': 'إرسال بريد', 'uk': 'Надіслати лист', 'ro': 'Trimite e-mail', 'pl': 'Wyślij e-mail',
  },
  'support_email_failed': {
    'en': 'Could not open the email app. Please write to us manually.',
    'de': 'E-Mail-App konnte nicht geöffnet werden. Bitte schreiben Sie uns manuell.',
    'fa': 'امکان باز کردن مستقیم برنامه ایمیل وجود ندارد. لطفاً به صورت دستی به ایمیل ما پیام دهید.',
    'tr': 'E-posta uygulaması açılamadı. Lütfen bize elle yazın.',
    'ru': 'Не удалось открыть почту. Напишите нам вручную.',
    'ar': 'تعذر فتح تطبيق البريد. يرجى مراسلتنا يدويًا.',
    'uk': 'Не вдалося відкрити пошту. Напишіть нам вручну.',
    'ro': 'Nu s-a putut deschide aplicația de e-mail. Scrieți-ne manual.',
    'pl': 'Nie można otworzyć poczty. Napisz do nas ręcznie.',
  },
  'support_email_error': {
    'en': 'Email error: {error}',
    'de': 'E-Mail-Fehler: {error}',
    'fa': 'خطایی در اجرای برنامه ایمیل رخ داد: {error}',
    'tr': 'E-posta hatası: {error}',
    'ru': 'Ошибка почты: {error}',
    'ar': 'خطأ في البريد: {error}',
    'uk': 'Помилка пошти: {error}',
    'ro': 'Eroare e-mail: {error}',
    'pl': 'Błąd e-mail: {error}',
  },
  'support_email_subject': {
    'en': 'Suggestion or issue in the app',
    'de': 'Vorschlag oder Problem in der App',
    'fa': 'پیشنهاد یا گزارش مشکل در اپلیکیشن',
    'tr': 'Uygulamada öneri veya sorun',
    'ru': 'Предложение или проблема в приложении',
    'ar': 'اقتراح أو مشكلة في التطبيق',
    'uk': 'Пропозиція або проблема в додатку',
    'ro': 'Sugestie sau problemă în aplicație',
    'pl': 'Sugestia lub problem w aplikacji',
  },
  'support_email_prefill': {
    'en': 'Hello support team,\n\nI have a suggestion or issue about the app:\n\n',
    'de': 'Hallo Support-Team,\n\nich habe einen Vorschlag oder ein Problem zur App:\n\n',
    'fa': 'سلام تیم پشتیبانی،\n\nمن پیشنهاد یا مشکلی درباره اپلیکیشن داشتم که در زیر مطرح می‌کنم:\n\n',
    'tr': 'Merhaba destek ekibi,\n\nUygulama hakkında bir önerim veya sorunum var:\n\n',
    'ru': 'Здравствуйте, команда поддержки,\n\nУ меня предложение или проблема по приложению:\n\n',
    'ar': 'مرحباً فريق الدعم،\n\nلدي اقتراح أو مشكلة حول التطبيق:\n\n',
    'uk': 'Вітаю, командо підтримки,\n\nМаю пропозицію або проблему щодо додатка:\n\n',
    'ro': 'Bună echipa de suport,\n\nAm o sugestie sau o problemă despre aplicație:\n\n',
    'pl': 'Witaj zespole wsparcia,\n\nMam sugestię lub problem dotyczący aplikacji:\n\n',
  },
  'premium_days_left_warning': {
    'en': 'Warning: Only {days} days left until full access is blocked.',
    'de': 'Warnung: Nur noch {days} Tage, bis der Zugriff vollständig gesperrt wird.',
    'fa': 'اخطار: تنها {days} روز تا قطعی کامل سرویس‌ها باقیست.',
    'tr': 'Uyarı: Tam erişim engellenmeden önce yalnızca {days} gün kaldı.',
    'ru': 'Внимание: до полной блокировки осталось {days} дн.',
    'ar': 'تحذير: تبقّى {days} يومًا فقط حتى يُحظر الوصول بالكامل.',
    'uk': 'Увага: до повного блокування залишилось {days} дн.',
    'ro': 'Avertisment: mai sunt doar {days} zile până la blocarea completă.',
    'pl': 'Ostrzeżenie: zostało tylko {days} dni do pełnej blokady.',
  },
  'extend_6_months': {
    'en': 'Extend 6 Months', 'de': '6 Monate verlängern', 'fa': 'تمدید ۶ ماهه', 'tr': '6 ay uzat',
    'ru': 'Продлить на 6 месяцев', 'ar': 'تمديد 6 أشهر', 'uk': 'Продовжити на 6 місяців', 'ro': 'Prelungește 6 luni', 'pl': 'Przedłuż o 6 miesięcy',
  },
  'loc_permission_needed': {
    'en': 'Location permission is required to find local stations.',
    'de': 'Standortzugriff ist erforderlich, um Tankstellen zu finden.',
    'fa': 'برای پیدا کردن پمپ‌بنزین‌های اطراف، اجازه موقعیت مکانی لازم است.',
    'tr': 'Yakındaki istasyonları bulmak için konum izni gerekir.',
    'ru': 'Для поиска заправок нужен доступ к геолокации.',
    'ar': 'يلزم إذن الموقع للعثور على المحطات القريبة.',
    'uk': 'Щоб знайти заправки, потрібен доступ до місцезнаходження.',
    'ro': 'Permisiunea de locație este necesară pentru a găsi stații.',
    'pl': 'Do znalezienia stacji potrzebna jest zgoda na lokalizację.',
  },
  'history_cleared': {
    'en': 'Search history cleared.',
    'de': 'Suchverlauf gelöscht.',
    'fa': 'تاریخچه جستجو پاک شد.',
    'tr': 'Arama geçmişi temizlendi.',
    'ru': 'История поиска очищена.',
    'ar': 'تم مسح سجل البحث.',
    'uk': 'Історію пошуку очищено.',
    'ro': 'Istoricul căutărilor a fost șters.',
    'pl': 'Wyczyszczono historię wyszukiwania.',
  },
  'watch_video': {
    'en': 'Watch video', 'de': 'Video ansehen', 'fa': 'تماشای ویدیو', 'tr': 'Videoyu izle',
    'ru': 'Смотреть видео', 'ar': 'شاهد الفيديو', 'uk': 'Дивитися відео', 'ro': 'Vizionați videoclipul', 'pl': 'Obejrzyj wideo',
  },
  'service_blocked': {
    'en': 'Service access is blocked. Upgrade to premium to unlock.',
    'de': 'Der Service-Bereich ist gesperrt. Premium freischalten.',
    'fa': 'دسترسی به بخش سرویس قطع شده است. برای استفاده نامحدود ارتقا دهید.',
    'tr': 'Servis erişimi kilitlendi. Açmak için premium’a geçin.',
    'ru': 'Доступ к сервису заблокирован. Оформите премиум.',
    'ar': 'تم حظر قسم الخدمة. قم بالترقية إلى النسخة المميزة.',
    'uk': 'Доступ до сервісу заблоковано. Оформіть преміум.',
    'ro': 'Accesul la service este blocat. Treceți la premium.',
    'pl': 'Dostęp do serwisu jest zablokowany. Włącz premium.',
  },
  'service_watch_video_msg': {
    'en': 'Watch a video to access and edit your service history.',
    'de': 'Sehen Sie ein Video an, um den Service-Verlauf zu öffnen.',
    'fa': 'برای مشاهده و ویرایش اطلاعات سرویس، ابتدا یک ویدیو تبلیغاتی تماشا کنید.',
    'tr': 'Servis geçmişini görmek ve düzenlemek için bir video izleyin.',
    'ru': 'Посмотрите видео, чтобы открыть историю сервиса.',
    'ar': 'شاهد فيديو للوصول إلى سجل الخدمة وتعديله.',
    'uk': 'Перегляньте відео, щоб відкрити історію сервісу.',
    'ro': 'Vizionați un videoclip pentru a accesa istoricul de service.',
    'pl': 'Obejrzyj wideo, aby otworzyć historię serwisu.',
  },
  'tire_4season': {
    'en': '4-Seasons', 'de': 'Allwetter', 'fa': '۴ فصل', 'tr': '4 mevsim',
    'ru': 'Всесезонные', 'ar': '4 فصول', 'uk': 'Всесезонні', 'ro': 'All-season', 'pl': 'Całoroczne',
  },
  'tire_2season': {
    'en': '2-Seasons', 'de': 'Sommer/Winter', 'fa': '۲ فصل (ت/ز)', 'tr': '2 mevsim (Y/K)',
    'ru': 'Лето/зима', 'ar': 'فصلان (ص/ش)', 'uk': 'Літо/зима', 'ro': 'Vară/iarnă', 'pl': 'Lato/zima',
  },
  'km_error_title': {
    'en': 'Invalid mileage', 'de': 'Ungültiger Kilometerstand', 'fa': 'خطا در ثبت کیلومتر', 'tr': 'Geçersiz kilometre',
    'ru': 'Неверный пробег', 'ar': 'كيلومتر غير صالح', 'uk': 'Невірний пробіг', 'ro': 'Kilometraj invalid', 'pl': 'Nieprawidłowy przebieg',
  },
  'km_error_body': {
    'en': 'The entered mileage ({entered} {unit}) cannot be higher than the current car mileage ({current} {unit}).',
    'de': 'Der eingegebene Stand ({entered}) darf nicht höher sein als der aktuelle Kilometerstand ({current}).',
    'fa': 'مقدار وارد شده ({entered} {unit}) نمی‌تواند بیشتر از کارکرد فعلی ماشین ({current} {unit}) باشد!',
    'tr': 'Girilen kilometre ({entered}), mevcut araç kilometresinden ({current}) büyük olamaz.',
    'ru': 'Введённый пробег ({entered}) не может быть больше текущего ({current}).',
    'ar': 'لا يمكن أن يكون الكيلومتر المدخل ({entered}) أكبر من كيلومتر السيارة الحالي ({current}).',
    'uk': 'Введений пробіг ({entered}) не може бути більшим за поточний ({current}).',
    'ro': 'Kilometrajul introdus ({entered}) nu poate fi mai mare decât cel actual ({current}).',
    'pl': 'Wpisany przebieg ({entered}) nie może być większy niż aktualny ({current}).',
  },
  'km_error_ok': {
    'en': 'Got it, I will correct it',
    'de': 'Verstanden, ich korrigiere es',
    'fa': 'متوجه شدم، اصلاح می‌کنم',
    'tr': 'Anladım, düzelteceğim',
    'ru': 'Понятно, исправлю',
    'ar': 'حسناً، سأصححه',
    'uk': 'Зрозуміло, виправлю',
    'ro': 'Am înțeles, voi corecta',
    'pl': 'Rozumiem, poprawię',
  },
  'km_diff_title': {
    'en': 'Warning: large mileage difference',
    'de': 'Warnung: große Kilometerdifferenz',
    'fa': 'هشدار: اختلاف کیلومتر زیاد',
    'tr': 'Uyarı: büyük kilometre farkı',
    'ru': 'Внимание: большая разница пробега',
    'ar': 'تحذير: فرق كبير في الكيلومتر',
    'uk': 'Увага: велика різниця пробігу',
    'ro': 'Avertisment: diferență mare de kilometraj',
    'pl': 'Ostrzeżenie: duża różnica przebiegu',
  },
  'km_diff_body': {
    'en': 'The value ({entered} {unit}) differs from the current mileage ({current} {unit}) by more than {threshold} {unit}. Are you sure?',
    'de': 'Der Wert ({entered}) weicht vom aktuellen Stand ({current}) um mehr als 30.000 km ab. Sind Sie sicher?',
    'fa': 'مقدار وارد شده ({entered} {unit}) با کارکرد فعلی ماشین ({current} {unit}) بیش از {threshold} {unit} اختلاف دارد. آیا مطمئن هستید؟',
    'tr': 'Girilen değer ({entered}), mevcut kilometreden ({current}) 30.000 km’den fazla farklı. Emin misiniz?',
    'ru': 'Значение ({entered}) отличается от текущего пробега ({current}) более чем на 30 000 км. Вы уверены?',
    'ar': 'القيمة ({entered}) تختلف عن الكيلومتر الحالي ({current}) بأكثر من 30,000 كم. هل أنت متأكد؟',
    'uk': 'Значення ({entered}) відрізняється від поточного пробігу ({current}) більш ніж на 30 000 км. Ви впевнені?',
    'ro': 'Valoarea ({entered}) diferă de kilometrajul actual ({current}) cu peste 30.000 km. Sunteți sigur?',
    'pl': 'Wartość ({entered}) różni się od aktualnego przebiegu ({current}) o ponad 30 000 km. Czy na pewno?',
  },
  'km_diff_no': {
    'en': 'No, I will correct it',
    'de': 'Nein, ich korrigiere es',
    'fa': 'خیر، اصلاح می‌کنم',
    'tr': 'Hayır, düzelteceğim',
    'ru': 'Нет, исправлю',
    'ar': 'لا، سأصححه',
    'uk': 'Ні, виправлю',
    'ro': 'Nu, voi corecta',
    'pl': 'Nie, poprawię',
  },
  'km_diff_yes': {
    'en': 'Yes, I am sure',
    'de': 'Ja, ich bin sicher',
    'fa': 'بله، مطمئنم',
    'tr': 'Evet, eminim',
    'ru': 'Да, уверен',
    'ar': 'نعم، متأكد',
    'uk': 'Так, я впевнений',
    'ro': 'Da, sunt sigur',
    'pl': 'Tak, jestem pewien',
  },
  'km_missing_title': {
    'en': 'Current mileage is missing',
    'de': 'Aktueller Kilometerstand fehlt',
    'fa': 'کیلومتر فعلی ثبت نشده!',
    'tr': 'Güncel kilometre girilmedi',
    'ru': 'Текущий пробег не указан',
    'ar': 'لم يُسجل الكيلومتر الحالي',
    'uk': 'Поточний пробіг не вказано',
    'ro': 'Kilometrajul actual lipsește',
    'pl': 'Brak aktualnego przebiegu',
  },
  'km_missing_body': {
    'en': 'Please enter the current car mileage ({unit}) at the top of the page first.',
    'de': 'Bitte tragen Sie zuerst den aktuellen Kilometerstand oben auf der Seite ein.',
    'fa': 'لطفا ابتدا «کارکرد فعلی» ماشین را (بر حسب {unit}) در بالای صفحه وارد کنید.',
    'tr': 'Lütfen önce sayfanın üstüne güncel araç kilometresini girin.',
    'ru': 'Сначала укажите текущий пробег автомобиля вверху страницы.',
    'ar': 'يرجى إدخال كيلومتر السيارة الحالي أعلى الصفحة أولاً.',
    'uk': 'Спочатку введіть поточний пробіг авто вгорі сторінки.',
    'ro': 'Introduceți mai întâi kilometrajul actual în partea de sus a paginii.',
    'pl': 'Najpierw wpisz aktualny przebieg na górze strony.',
  },
  'km_missing_ok': {
    'en': 'Got it',
    'de': 'Verstanden',
    'fa': 'متوجه شدم',
    'tr': 'Anladım',
    'ru': 'Понятно',
    'ar': 'حسناً',
    'uk': 'Зрозуміло',
    'ro': 'Am înțeles',
    'pl': 'Rozumiem',
  },
  'km_enter_current_first': {
    'en': 'Enter the current mileage ({unit}) at the top of the page first.',
    'de': 'Bitte zuerst den aktuellen Kilometerstand oben eingeben.',
    'fa': 'ابتدا کارکرد فعلی (بر حسب {unit}) را در بالای صفحه وارد کنید.',
    'tr': 'Önce sayfanın üstüne güncel kilometreyi girin.',
    'ru': 'Сначала укажите текущий пробег вверху страницы.',
    'ar': 'أدخل الكيلومتر الحالي أعلى الصفحة أولاً.',
    'uk': 'Спочатку введіть поточний пробіг вгорі сторінки.',
    'ro': 'Introduceți mai întâi kilometrajul actual în partea de sus.',
    'pl': 'Najpierw wpisz aktualny przebieg na górze strony.',
  },
  'date_required_title': {
    'en': 'Date required',
    'de': 'Datum erforderlich',
    'fa': 'تنظیم تاریخ الزامی است',
    'tr': 'Tarih gerekli',
    'ru': 'Нужна дата',
    'ar': 'التاريخ مطلوب',
    'uk': 'Потрібна дата',
    'ro': 'Data este obligatorie',
    'pl': 'Wymagana data',
  },
  'date_required_body': {
    'en': 'Please set the previous service date first, then enable the alarm.',
    'de': 'Bitte setzen Sie zuerst das letzte Servicedatum, dann den Alarm.',
    'fa': 'لطفاً ابتدا تاریخ (سرویس قبلی) را تنظیم کنید، سپس اقدام به فعال‌سازی آلارم نمایید.',
    'tr': 'Lütfen önce önceki servis tarihini ayarlayın, sonra alarmı açın.',
    'ru': 'Сначала укажите дату прошлого сервиса, затем включите сигнал.',
    'ar': 'يرجى تعيين تاريخ الخدمة السابقة أولاً ثم تفعيل التنبيه.',
    'uk': 'Спочатку встановіть дату попереднього сервісу, потім увімкніть будильник.',
    'ro': 'Setați mai întâi data service-ului anterior, apoi activați alarma.',
    'pl': 'Najpierw ustaw datę poprzedniego serwisu, potem włącz alarm.',
  },
  'reminder_interval_km': {
    'en': 'Service interval ({unit})',
    'de': 'Serviceintervall (km)',
    'fa': 'فاصله تعویض/سرویس ({unit})',
    'tr': 'Servis aralığı (km)',
    'ru': 'Интервал сервиса (км)',
    'ar': 'فترة الخدمة (كم)',
    'uk': 'Інтервал сервісу (км)',
    'ro': 'Interval service (km)',
    'pl': 'Interwał serwisu (km)',
  },
  'reminder_interval_days': {
    'en': 'Service period (days)',
    'de': 'Servicezeitraum (Tage)',
    'fa': 'دوره تناوب سرویس (تعداد روز)',
    'tr': 'Servis periyodu (gün)',
    'ru': 'Период сервиса (дни)',
    'ar': 'مدة الخدمة (أيام)',
    'uk': 'Період сервісу (дні)',
    'ro': 'Perioadă service (zile)',
    'pl': 'Okres serwisu (dni)',
  },
  'service_due_notice': {
    'en': 'Service time has arrived for some items. Please check the car service page.',
    'de': 'Für einige Punkte ist der Service fällig. Bitte prüfen Sie die Service-Seite.',
    'fa': 'موعد سرویس برخی قطعات رسیده است. لطفاً صفحه سرویس ماشین را بررسی کنید.',
    'tr': 'Bazı kalemlerin servis zamanı geldi. Lütfen servis sayfasını kontrol edin.',
    'ru': 'Для некоторых пунктов наступил срок сервиса. Проверьте страницу сервиса.',
    'ar': 'حان موعد خدمة بعض العناصر. يرجى مراجعة صفحة الخدمة.',
    'uk': 'Для деяких пунктів настав час сервісу. Перевірте сторінку сервісу.',
    'ro': 'A venit termenul de service pentru unele elemente. Verificați pagina de service.',
    'pl': 'Dla niektórych pozycji nadszedł serwis. Sprawdź stronę serwisu.',
  },
  'select_station': {
    'en': 'Select station', 'de': 'Station wählen', 'fa': 'انتخاب پمپ', 'tr': 'İstasyon seç',
    'ru': 'Выбрать станцию', 'ar': 'اختر المحطة', 'uk': 'Обрати станцію', 'ro': 'Selectează stația', 'pl': 'Wybierz stację',
  },
  'deselect_station': {
    'en': 'Deselect station', 'de': 'Auswahl aufheben', 'fa': 'لغو انتخاب پمپ', 'tr': 'Seçimi kaldır',
    'ru': 'Снять выбор', 'ar': 'إلغاء اختيار المحطة', 'uk': 'Скасувати вибір', 'ro': 'Deselectează stația', 'pl': 'Odznacz stację',
  },
  'parking_spaces': {
    'en': 'Spaces: {slots}', 'de': 'Plätze: {slots}', 'fa': 'ظرفیت: {slots}', 'tr': 'Yer: {slots}',
    'ru': 'Места: {slots}', 'ar': 'أماكن: {slots}', 'uk': 'Місця: {slots}', 'ro': 'Locuri: {slots}', 'pl': 'Miejsca: {slots}',
  },
  'notification_disabled_title': {
    'en': 'Notifications disabled',
    'de': 'Mitteilungen deaktiviert',
    'fa': 'هشدار نوتیفیکیشن',
    'tr': 'Bildirimler kapalı',
    'ru': 'Уведомления отключены',
    'ar': 'الإشعارات معطّلة',
    'uk': 'Сповіщення вимкнено',
    'ro': 'Notificări dezactivate',
    'pl': 'Powiadomienia wyłączone',
  },
  'notification_disabled_msg': {
    'en': 'App notifications are disabled in system settings. Enable them to receive car service alerts.',
    'de': 'Mitteilungen der App sind in den Systemeinstellungen deaktiviert. Aktivieren Sie sie für Service-Hinweise.',
    'fa': 'نوتیفیکیشن‌های برنامه در تنظیمات گوشی غیرفعال شده‌اند. برای دریافت هشدارهای سرویس خودرو، لطفاً آن را فعال کنید.',
    'tr': 'Uygulama bildirimleri sistem ayarlarında kapalı. Servis uyarıları için açın.',
    'ru': 'Уведомления приложения отключены в настройках системы. Включите их для сервисных напоминаний.',
    'ar': 'إشعارات التطبيق معطّلة في إعدادات النظام. فعّلها لتلقي تنبيهات خدمة السيارة.',
    'uk': 'Сповіщення додатка вимкнено в системних налаштуваннях. Увімкніть їх для нагадувань про сервіс.',
    'ro': 'Notificările aplicației sunt dezactivate în setările sistemului. Activați-le pentru alerte de service.',
    'pl': 'Powiadomienia aplikacji są wyłączone w ustawieniach systemu. Włącz je, aby otrzymywać alerty serwisowe.',
  },
  'open_settings': {
    'en': 'Phone settings', 'de': 'Handy-Einstellungen', 'fa': 'تنظیمات گوشی', 'tr': 'Telefon ayarları',
    'ru': 'Настройки телефона', 'ar': 'إعدادات الهاتف', 'uk': 'Налаштування телефону', 'ro': 'Setări telefon', 'pl': 'Ustawienia telefonu',
  },
  'timeline_reset': {
    'en': 'Timeline reset successfully!',
    'de': 'Zeitlinie erfolgreich zurückgesetzt!',
    'fa': 'خط زمانی با موفقیت بازنشانی شد!',
    'tr': 'Zaman çizelgesi sıfırlandı!',
    'ru': 'Шкала времени сброшена!',
    'ar': 'تمت إعادة ضبط الخط الزمني!',
    'uk': 'Часову шкалу скинуто!',
    'ro': 'Cronologia a fost resetată!',
    'pl': 'Oś czasu została zresetowana!',
  },
  'example_km': {
    'en': 'e.g. 15000', 'de': 'z. B. 15000', 'fa': 'مثال: ۱۵۰۰۰', 'tr': 'ör. 15000',
    'ru': 'напр. 15000', 'ar': 'مثال: 15000', 'uk': 'напр. 15000', 'ro': 'ex. 15000', 'pl': 'np. 15000',
  },
  'example_days': {
    'en': 'e.g. 365', 'de': 'z. B. 365', 'fa': 'مثال: ۳۶۵', 'tr': 'ör. 365',
    'ru': 'напр. 365', 'ar': 'مثال: 365', 'uk': 'напр. 365', 'ro': 'ex. 365', 'pl': 'np. 365',
  },
  'error_generic': {
    'en': 'Error: {error}', 'de': 'Fehler: {error}', 'fa': 'خطا: {error}', 'tr': 'Hata: {error}',
    'ru': 'Ошибка: {error}', 'ar': 'خطأ: {error}', 'uk': 'Помилка: {error}', 'ro': 'Eroare: {error}', 'pl': 'Błąd: {error}',
  },
  'parking_garage': {
    'en': 'Parking garage', 'de': 'Parkhaus', 'fa': 'پارکینگ طبقاتی', 'tr': 'Otopark',
    'ru': 'Паркинг', 'ar': 'موقف سيارات', 'uk': 'Паркінг', 'ro': 'Parcare', 'pl': 'Parking',
  },
  'not_available': {
    'en': 'N/A', 'de': 'k. A.', 'fa': 'نامشخص', 'tr': 'Yok',
    'ru': 'н/д', 'ar': 'غير متاح', 'uk': 'н/д', 'ro': 'N/A', 'pl': 'bd.',
  },
  'parking_public': {
    'en': 'Public', 'de': 'Öffentlich', 'fa': 'عمومی', 'tr': 'Halka açık',
    'ru': 'Общественная', 'ar': 'عام', 'uk': 'Громадська', 'ro': 'Public', 'pl': 'Publiczny',
  },
  'edit_phone': {
    'en': 'Edit phone', 'de': 'Telefon ändern', 'fa': 'ویرایش تلفن', 'tr': 'Telefonu düzenle',
    'ru': 'Изменить телефон', 'ar': 'تعديل الهاتف', 'uk': 'Змінити телефон', 'ro': 'Editează telefonul', 'pl': 'Edytuj telefon',
  },
  'set_km_at_current': {
    'en': 'Set to current mileage', 'de': 'Aktuellen Stand übernehmen', 'fa': 'ثبت در کیلومتر فعلی', 'tr': 'Güncel kilometreyi yaz',
    'ru': 'Подставить текущий пробег', 'ar': 'تعيين للكيلومتر الحالي', 'uk': 'Встановити поточний пробіг', 'ro': 'Setează kilometrajul actual', 'pl': 'Ustaw aktualny przebieg',
  },
  'snooze_reminder_title': {
    'en': 'Car Service Reminder 🔧', 'de': 'Auto-Service Erinnerung 🔧', 'fa': 'یادآور سرویس خودرو 🔧', 'tr': 'Araç Servis Hatırlatıcısı 🔧',
    'ru': 'Напоминание о сервисе 🔧', 'ar': 'تذكير بخدمة السيارة 🔧', 'uk': 'Нагадування про сервіс 🔧', 'ro': 'Memento service auto 🔧', 'pl': 'Przypomnienie o serwisie 🔧',
  },
  'snooze_reminder_body': {
    'en': 'Snoozed reminder — please check your car service page.',
    'de': 'Erinnerung verschoben — bitte die Service-Seite prüfen.',
    'fa': 'یادآور به تعویق افتاد — لطفاً صفحه سرویس ماشین را بررسی کنید.',
    'tr': 'Hatırlatıcı ertelendi — lütfen servis sayfasını kontrol edin.',
    'ru': 'Напоминание отложено — проверьте страницу сервиса.',
    'ar': 'تم تأجيل التذكير — يرجى مراجعة صفحة الخدمة.',
    'uk': 'Нагадування відкладено — перевірте сторінку сервісу.',
    'ro': 'Memento amânat — verificați pagina de service.',
    'pl': 'Przypomnienie odroczone — sprawdź stronę serwisu.',
  },
  'alarm_test_title': {
    'en': 'Alarm test', 'de': 'Alarmtest', 'fa': 'تست آلارم', 'tr': 'Alarm testi',
    'ru': 'Тест сигнала', 'ar': 'اختبار التنبيه', 'uk': 'Тест будильника', 'ro': 'Test alarmă', 'pl': 'Test alarmu',
  },
  'alarm_test_body': {
    'en': 'Notification system is working.',
    'de': 'Das Mitteilungssystem funktioniert.',
    'fa': 'سیستم اعلان کار می‌کند.',
    'tr': 'Bildirim sistemi çalışıyor.',
    'ru': 'Система уведомлений работает.',
    'ar': 'نظام الإشعارات يعمل.',
    'uk': 'Система сповіщень працює.',
    'ro': 'Sistemul de notificări funcționează.',
    'pl': 'System powiadomień działa.',
  },
  'phone_example': {
    'en': 'e.g. 030123456', 'de': 'z. B. 030123456', 'fa': 'مثال: ۰۳۰۱۲۳۴۵۶', 'tr': 'ör. 030123456',
    'ru': 'напр. 030123456', 'ar': 'مثال: 030123456', 'uk': 'напр. 030123456', 'ro': 'ex. 030123456', 'pl': 'np. 030123456',
  },
  'service_completed': {
    'en': 'Service completed', 'de': 'Service erledigt', 'fa': 'سرویس انجام شد', 'tr': 'Servis tamamlandı',
    'ru': 'Сервис выполнен', 'ar': 'اكتملت الخدمة', 'uk': 'Сервіс виконано', 'ro': 'Service finalizat', 'pl': 'Serwis ukończony',
  },
  'open_services': {
    'en': 'Open services', 'de': 'Service öffnen', 'fa': 'باز کردن سرویس', 'tr': 'Servisi aç',
    'ru': 'Открыть сервис', 'ar': 'فتح الخدمات', 'uk': 'Відкрити сервіс', 'ro': 'Deschide service', 'pl': 'Otwórz serwis',
  },
  'snooze_one_day': {
    'en': 'Snooze 1 day', 'de': '1 Tag später', 'fa': 'یک روز بعد', 'tr': '1 gün ertele',
    'ru': 'Отложить на день', 'ar': 'تأجيل يوم', 'uk': 'Відкласти на день', 'ro': 'Amână 1 zi', 'pl': 'Odłóż o 1 dzień',
  },
  'fuel_channel_name': {
    'en': 'Fuel price alerts', 'de': 'Kraftstoffpreis-Hinweise', 'fa': 'هشدار قیمت سوخت', 'tr': 'Yakıt fiyat uyarıları',
    'ru': 'Оповещения о цене топлива', 'ar': 'تنبيهات سعر الوقود', 'uk': 'Сповіщення про ціну пального', 'ro': 'Alerte preț combustibil', 'pl': 'Alerty cen paliwa',
  },
  'fuel_channel_desc': {
    'en': 'Notifications for cheap fuel prices',
    'de': 'Mitteilungen zu günstigen Kraftstoffpreisen',
    'fa': 'اعلان قیمت سوخت ارزان',
    'tr': 'Ucuz yakıt fiyatı bildirimleri',
    'ru': 'Уведомления о низких ценах на топливо',
    'ar': 'إشعارات أسعار الوقود المنخفضة',
    'uk': 'Сповіщення про низькі ціни на пальне',
    'ro': 'Notificări pentru prețuri mici la combustibil',
    'pl': 'Powiadomienia o niskich cenach paliwa',
  },
  'service_channel_name': {
    'en': 'Car service reminders', 'de': 'Auto-Service-Erinnerungen', 'fa': 'یادآور سرویس خودرو', 'tr': 'Araç servis hatırlatıcıları',
    'ru': 'Напоминания о сервисе', 'ar': 'تذكيرات خدمة السيارة', 'uk': 'Нагадування про сервіс', 'ro': 'Memento-uri service auto', 'pl': 'Przypomnienia serwisowe',
  },
  'service_channel_desc': {
    'en': 'Reminders for oil change and repairs',
    'de': 'Erinnerungen zu Ölwechsel und Reparaturen',
    'fa': 'یادآور تعویض روغن و تعمیرات',
    'tr': 'Yağ değişimi ve tamir hatırlatıcıları',
    'ru': 'Напоминания о замене масла и ремонте',
    'ar': 'تذكيرات تغيير الزيت والإصلاحات',
    'uk': 'Нагадування про заміну оливи та ремонт',
    'ro': 'Memento-uri pentru schimb de ulei și reparații',
    'pl': 'Przypomnienia o wymianie oleju i naprawach',
  },
  'oil_status_check_body': {
    'en': 'Please check your car oil and service status.',
    'de': 'Bitte Ölstand und Servicestatus prüfen.',
    'fa': 'لطفاً وضعیت روغن و سرویس ماشین را بررسی کنید.',
    'tr': 'Lütfen yağ ve servis durumunu kontrol edin.',
    'ru': 'Проверьте масло и статус сервиса автомобиля.',
    'ar': 'يرجى فحص زيت السيارة وحالة الخدمة.',
    'uk': 'Перевірте оливу та стан сервісу автомобіля.',
    'ro': 'Verificați uleiul și starea de service.',
    'pl': 'Sprawdź olej i stan serwisu samochodu.',
  },
  'iap_stream_error': {
    'en': 'Store connection error: {error}',
    'de': 'Fehler bei der Store-Verbindung: {error}',
    'fa': 'خطا در ارتباط با فروشگاه: {error}',
    'tr': 'Mağaza bağlantı hatası: {error}',
    'ru': 'Ошибка связи с магазином: {error}',
    'ar': 'خطأ في الاتصال بالمتجر: {error}',
    'uk': 'Помилка з’єднання з магазином: {error}',
    'ro': 'Eroare de conexiune la magazin: {error}',
    'pl': 'Błąd połączenia ze sklepem: {error}',
  },
  'iap_failed': {
    'en': 'The purchase could not be completed.',
    'de': 'Der Kauf konnte nicht abgeschlossen werden.',
    'fa': 'تراکنش ناموفق بود.',
    'tr': 'Satın alma tamamlanamadı.',
    'ru': 'Покупка не выполнена.',
    'ar': 'تعذّر إكمال الشراء.',
    'uk': 'Покупку не завершено.',
    'ro': 'Achiziția nu a putut fi finalizată.',
    'pl': 'Zakup nie powiódł się.',
  },
  'iap_cancelled': {
    'en': 'Purchase was cancelled.',
    'de': 'Kauf abgebrochen.',
    'fa': 'پرداخت توسط شما لغو شد.',
    'tr': 'Satın alma iptal edildi.',
    'ru': 'Покупка отменена.',
    'ar': 'تم إلغاء الشراء.',
    'uk': 'Покупку скасовано.',
    'ro': 'Achiziția a fost anulată.',
    'pl': 'Zakup został anulowany.',
  },
  'iap_store_unavailable': {
    'en': 'The store is currently unavailable.',
    'de': 'Der Store ist derzeit nicht verfügbar.',
    'fa': 'فروشگاه در حال حاضر در دسترس نیست.',
    'tr': 'Mağaza şu anda kullanılamıyor.',
    'ru': 'Магазин сейчас недоступен.',
    'ar': 'المتجر غير متاح حالياً.',
    'uk': 'Магазин зараз недоступний.',
    'ro': 'Magazinul nu este disponibil momentan.',
    'pl': 'Sklep jest obecnie niedostępny.',
  },
  'iap_product_not_found': {
    'en': 'Product not found in the store. Checked ID: {id}',
    'de': 'Produkt im Store nicht gefunden. Geprüfte ID: {id}',
    'fa': 'محصول در فروشگاه یافت نشد. شناسه بررسی شده: {id}',
    'tr': 'Ürün mağazada bulunamadı. Kontrol edilen kimlik: {id}',
    'ru': 'Товар в магазине не найден. Проверенный ID: {id}',
    'ar': 'المنتج غير موجود في المتجر. المعرّف: {id}',
    'uk': 'Товар у магазині не знайдено. Перевірений ID: {id}',
    'ro': 'Produsul nu a fost găsit în magazin. ID verificat: {id}',
    'pl': 'Nie znaleziono produktu w sklepie. Sprawdzone ID: {id}',
  },
  'community_report_btn': {
    'en': 'Report live price',
    'de': 'Live-Preis melden',
    'fa': 'گزارش قیمت لحظه‌ای',
    'tr': 'Anlık fiyat bildir',
    'ru': 'Сообщить цену',
    'ar': 'بلّغ عن السعر',
    'uk': 'Повідомити ціну',
    'ro': 'Raportează prețul',
    'pl': 'Zgłoś cenę',
  },
  'community_points': {
    'en': 'Community points: {n}',
    'de': 'Community-Punkte: {n}',
    'fa': 'امتیاز همیاری: {n}',
    'tr': 'Topluluk puanı: {n}',
    'ru': 'Очки сообщества: {n}',
    'ar': 'نقاط المجتمع: {n}',
    'uk': 'Бали спільноти: {n}',
    'ro': 'Puncte comunitate: {n}',
    'pl': 'Punkty społeczności: {n}',
  },
  'community_story': {
    'en':
        'You are the eyes of our Persian-speaking family on the road. One honest price from you can save a traveller\'s time, money, and stress — turn on your light for the next person.',
    'de':
        'Du bist die Augen unserer persischsprachigen Familie unterwegs. Ein ehrlicher Preis von dir kann Zeit, Geld und Stress sparen.',
    'fa':
        'تو چشم‌های خانوادهٔ فارسی‌زبان روی جاده‌ای. یک قیمت صادقانه از تو می‌تواند وقت، پول و اضطراب یک هم‌وطن را کم کند — چراغت را برای نفر بعدی روشن کن. کمک تو گردش اطلاعات بین جامعهٔ ماست؛ هر گزارش، یک دست مهربان روی شانهٔ کسی است که غریب است و فقط می‌خواهد با خیال راحت باک بزند.',
    'tr':
        'Yoldaki Farsça konuşan ailemizin gözlerisin. Dürüst bir fiyat, bir yolcunun zamanını ve parasını kurtarabilir.',
    'ru':
        'Ты — глаза нашей персоязычной семьи в дороге. Честная цена экономит время и деньги путнику.',
    'ar':
        'أنت عيون عائلتنا الناطقة بالفارسية على الطريق. سعر صادق منك يوفّر الوقت والمال للتالي.',
    'uk':
        'Ти — очі нашої перськомовної родини в дорозі. Чесна ціна економить час і гроші мандрівнику.',
    'ro':
        'Ești ochii familiei noastre vorbitoare de persană pe drum. Un preț sincer ajută următorul călător.',
    'pl':
        'Jesteś oczami naszej perskojęzycznej rodziny w drodze. Uczciwa cena pomaga następnemu podróżnemu.',
  },
  'community_price_hint': {
    'en': 'Price per litre',
    'de': 'Preis pro Liter',
    'fa': 'قیمت هر لیتر',
    'tr': 'Litre fiyatı',
    'ru': 'Цена за литр',
    'ar': 'السعر لكل لتر',
    'uk': 'Ціна за літр',
    'ro': 'Preț pe litru',
    'pl': 'Cena za litr',
  },
  'community_station_hint': {
    'en': 'Station name (optional)',
    'de': 'Stationsname (optional)',
    'fa': 'نام پمپ (اختیاری)',
    'tr': 'İstasyon adı (isteğe bağlı)',
    'ru': 'Название АЗС (необязательно)',
    'ar': 'اسم المحطة (اختياري)',
    'uk': 'Назва АЗС (необовʼязково)',
    'ro': 'Nume stație (opțional)',
    'pl': 'Nazwa stacji (opcjonalnie)',
  },
  'community_submit': {
    'en': 'Send & earn points',
    'de': 'Senden & Punkte verdienen',
    'fa': 'ارسال و دریافت امتیاز',
    'tr': 'Gönder ve puan kazan',
    'ru': 'Отправить и получить очки',
    'ar': 'أرسل واكسب نقاطاً',
    'uk': 'Надіслати й отримати бали',
    'ro': 'Trimite și câștigă puncte',
    'pl': 'Wyślij i zbierz punkty',
  },
  'community_ok': {
    'en': 'Thank you! +{n} points. Your report helps the community.',
    'de': 'Danke! +{n} Punkte. Deine Meldung hilft der Community.',
    'fa': 'ممنون از مهربانی‌ات! +{n} امتیاز. گزارش تو به هم‌وطنان رسید.',
    'tr': 'Teşekkürler! +{n} puan. Bildirimin topluluğa yardımcı oldu.',
    'ru': 'Спасибо! +{n} очков. Ваш отчёт помогает сообществу.',
    'ar': 'شكراً! +{n} نقطة. بلاغك يساعد المجتمع.',
    'uk': 'Дякуємо! +{n} балів. Ваш звіт допомагає спільноті.',
    'ro': 'Mulțumim! +{n} puncte. Raportul tău ajută comunitatea.',
    'pl': 'Dziękujemy! +{n} punktów. Twoje zgłoszenie pomaga społeczności.',
  },
  'community_err_location': {
    'en': 'GPS must be inside this country to report.',
    'de': 'GPS muss in diesem Land sein, um zu melden.',
    'fa': 'برای گزارش، موقعیت GPS باید داخل همین کشور باشد.',
    'tr': 'Bildirmek için GPS bu ülkede olmalı.',
    'ru': 'GPS должен быть внутри этой страны.',
    'ar': 'يجب أن يكون موقعك داخل هذا البلد للإبلاغ.',
    'uk': 'GPS має бути всередині цієї країни.',
    'ro': 'GPS-ul trebuie să fie în această țară.',
    'pl': 'GPS musi być w tym kraju.',
  },
  'community_err_cooldown': {
    'en': 'Please wait a few minutes before another report.',
    'de': 'Bitte warte ein paar Minuten vor der nächsten Meldung.',
    'fa': 'لطفاً چند دقیقه صبر کن و بعد دوباره گزارش بده.',
    'tr': 'Yeni bildirimden önce birkaç dakika bekle.',
    'ru': 'Подождите несколько минут перед следующим отчётом.',
    'ar': 'انتظر بضع دقائق قبل بلاغ آخر.',
    'uk': 'Зачекайте кілька хвилин перед наступним звітом.',
    'ro': 'Așteaptă câteva minute înainte de un nou raport.',
    'pl': 'Poczekaj kilka minut przed kolejnym zgłoszeniem.',
  },
  'community_err_price': {
    'en': 'Enter a valid price.',
    'de': 'Gib einen gültigen Preis ein.',
    'fa': 'یک قیمت معتبر وارد کن.',
    'tr': 'Geçerli bir fiyat gir.',
    'ru': 'Введите корректную цену.',
    'ar': 'أدخل سعراً صالحاً.',
    'uk': 'Введіть коректну ціну.',
    'ro': 'Introdu un preț valid.',
    'pl': 'Podaj poprawną cenę.',
  },
  'community_err_country': {
    'en': 'Live reports are only for USA, Canada and India.',
    'de': 'Live-Meldungen nur für USA, Kanada und Indien.',
    'fa': 'گزارش لحظه‌ای فعلاً فقط برای آمریکا، کانادا و هند است.',
    'tr': 'Anlık bildirim yalnızca ABD, Kanada ve Hindistan için.',
    'ru': 'Живые отчёты только для США, Канады и Индии.',
    'ar': 'التقارير اللحظية لأمريكا وكندا والهند فقط.',
    'uk': 'Живі звіти лише для США, Канади та Індії.',
    'ro': 'Rapoarte live doar pentru SUA, Canada și India.',
    'pl': 'Raporty na żywo tylko dla USA, Kanady i Indii.',
  },
  'price_notice_national': {
    'en':
        'Shown prices are the national average for {country} — not live per-station pump prices.',
    'de':
        'Angezeigte Preise sind der Landesdurchschnitt für {country} — keine Live-Preise einzelner Tankstellen.',
    'fa':
        'قیمت‌های نمایش‌داده‌شده میانگین سراسری کشور {country} است — نه قیمت لحظه‌ای هر پمپ بنزین.',
    'tr':
        'Gösterilen fiyatlar {country} ülke ortalamasıdır — istasyon bazlı canlı fiyat değildir.',
    'ru':
        'Показаны средние цены по стране {country}, а не цены отдельных АЗС.',
    'ar':
        'الأسعار المعروضة هي متوسط الدولة لـ {country} وليست أسعار محطات فردية.',
    'uk':
        'Показано середні ціни по країні {country}, а не ціни окремих АЗС.',
    'ro':
        'Prețurile afișate sunt media națională pentru {country}, nu prețuri pe stație.',
    'pl':
        'Wyświetlane ceny to średnia krajowa dla {country}, nie ceny poszczególnych stacji.',
  },
  'price_notice_monthly': {
    'en':
        'Official monthly nationwide rate for {country} — the same at every pump this month.',
    'de':
        'Offizieller monatlicher Landespreis für {country} — diesen Monat an allen Tankstellen gleich.',
    'fa':
        'نرخ رسمی ماهانه سراسری {country} — این ماه در همه پمپ‌ها یکسان است.',
    'tr':
        '{country} için resmi aylık ülke fiyatı — bu ay tüm istasyonlarda aynı.',
    'ru':
        'Официальная месячная цена по всей стране {country} — одинакова на всех АЗС в этом месяце.',
    'ar':
        'السعر الرسمي الشهري على مستوى {country} — موحّد في كل المحطات هذا الشهر.',
    'uk':
        'Офіційна місячна ціна по всій країні {country} — однакова на всіх АЗС цього місяця.',
    'ro':
        'Tariful oficial lunar la nivel național pentru {country} — același la toate pompele luna aceasta.',
    'pl':
        'Oficjalna miesięczna stawka ogólnokrajowa dla {country} — taka sama na wszystkich stacjach w tym miesiącu.',
  },
  'price_notice_fixed': {
    'en':
        'Official regulated nationwide price for {country} — the same at every pump.',
    'de':
        'Offiziell regulierter Landespreis für {country} — an allen Tankstellen gleich.',
    'fa':
        'قیمت رسمی تنظیم‌شده سراسری {country} — در همه پمپ‌ها یکسان است.',
    'tr':
        '{country} için resmi düzenlenmiş ülke fiyatı — tüm istasyonlarda aynı.',
    'ru':
        'Официальная регулируемая цена по стране {country} — одинакова на всех АЗС.',
    'ar':
        'السعر الرسمي المنظّم على مستوى {country} — موحّد في كل المحطات.',
    'uk':
        'Офіційна регульована ціна по країні {country} — однакова на всіх АЗС.',
    'ro':
        'Preț oficial reglementat la nivel național pentru {country} — același la toate pompele.',
    'pl':
        'Oficjalna regulowana cena ogólnokrajowa dla {country} — taka sama na wszystkich stacjach.',
  },
  'price_notice_provincial': {
    'en':
        'Guide retail price for {region} ({country}) — provincial/state average, not each pump’s live price.',
    'de':
        'Richtpreis für {region} ({country}) — Provinz-/Landesdurchschnitt, kein Live-Preis einzelner Tankstellen.',
    'fa':
        'قیمت راهنمای {region} ({country}) — میانگین استان/ایالت است، نه قیمت لحظه‌ای هر پمپ.',
    'tr':
        '{region} ({country}) için rehber perakende fiyatı — eyalet/il ortalaması, canlı pompa fiyatı değil.',
    'ru':
        'Ориентировочная цена для {region} ({country}) — среднее по провинции/штату, не цена отдельной АЗС.',
    'ar':
        'سعر إرشادي لـ {region} ({country}) — متوسط المقاطعة/الولاية وليس سعر كل محطة.',
    'uk':
        'Орієнтовна ціна для {region} ({country}) — середнє по провінції/штату, не ціна окремої АЗС.',
    'ro':
        'Preț orientativ pentru {region} ({country}) — medie provincială/de stat, nu preț live pe pompă.',
    'pl':
        'Cena orientacyjna dla {region} ({country}) — średnia prowincji/stanu, nie żywa cena stacji.',
  },
  'price_notice_crowd': {
    'en':
        'Prices for {country} come from community reports or the national average when reports are sparse.',
    'de':
        'Preise für {country} stammen aus Community-Meldungen oder dem Landesdurchschnitt, wenn wenig gemeldet wird.',
    'fa':
        'قیمت‌های {country} از گزارش کاربران است؛ اگر گزارش کم باشد، میانگین سراسری کشور نشان داده می‌شود.',
    'tr':
        '{country} fiyatları topluluk bildirimlerinden gelir; azsa ülke ortalaması gösterilir.',
    'ru':
        'Цены для {country} — из отчётов сообщества или среднего по стране, если отчётов мало.',
    'ar':
        'أسعار {country} من تقارير المجتمع أو متوسط الدولة إن قلّت التقارير.',
    'uk':
        'Ціни для {country} — зі звітів спільноти або середнього по країні, якщо звітів мало.',
    'ro':
        'Prețurile pentru {country} vin din rapoarte comunitare sau media națională dacă sunt puține.',
    'pl':
        'Ceny dla {country} pochodzą z zgłoszeń społeczności lub średniej krajowej, gdy zgłoszeń jest mało.',
  },
  'price_notice_us': {
    'en':
        'USA ({region}): community live reports when available, otherwise regional retail average — USD per US gallon.',
    'de':
        'USA ({region}): Community-Live-Preise falls vorhanden, sonst regionaler Durchschnitt — USD pro US-Gallon.',
    'fa':
        'آمریکا ({region}): در صورت وجود، گزارش لحظه‌ای کاربران؛ وگرنه میانگین منطقه‌ای — دلار به ازای هر گالن آمریکایی.',
    'tr':
        'ABD ({region}): varsa topluluk anlık fiyatları, yoksa bölgesel ortalama — ABD galonu başına USD.',
    'ru':
        'США ({region}): живые отчёты сообщества или региональное среднее — USD за американский галлон.',
    'ar':
        'أمريكا ({region}): تقارير المجتمع إن وُجدت، وإلا متوسط المنطقة — دولار لكل غالون أمريكي.',
    'uk':
        'США ({region}): живі звіти спільноти або регіональне середнє — USD за американський галон.',
    'ro':
        'SUA ({region}): rapoarte live din comunitate sau media regională — USD pe galon SUA.',
    'pl':
        'USA ({region}): zgłoszenia społeczności lub średnia regionalna — USD za galon USA.',
  },
  'price_notice_unit': {
    'en': 'Prices are shown per {unit}.',
    'de': 'Preise werden pro {unit} angezeigt.',
    'fa': 'قیمت‌ها بر حسب {unit} نمایش داده می‌شوند.',
    'tr': 'Fiyatlar {unit} başına gösterilir.',
    'ru': 'Цены указаны за {unit}.',
    'ar': 'تُعرض الأسعار لكل {unit}.',
    'uk': 'Ціни вказані за {unit}.',
    'ro': 'Prețurile sunt afișate pe {unit}.',
    'pl': 'Ceny są podane za {unit}.',
  },
  'price_unit_liter': {
    'en': 'litre',
    'de': 'Liter',
    'fa': 'لیتر',
    'tr': 'litre',
    'ru': 'литр',
    'ar': 'لتر',
    'uk': 'літр',
    'ro': 'litru',
    'pl': 'litr',
  },
  'price_unit_gallon': {
    'en': 'US gallon',
    'de': 'US-Gallon',
    'fa': 'گالن آمریکایی',
    'tr': 'ABD galonu',
    'ru': 'американский галлон',
    'ar': 'غالون أمريكي',
    'uk': 'американський галон',
    'ro': 'galon SUA',
    'pl': 'galon USA',
  },
  'stations_loading_wait': {
    'en': 'Loading fuel stations… please wait a moment.',
    'de': 'Tankstellen werden geladen… bitte kurz warten.',
    'fa': 'در حال بارگذاری پمپ‌بنزین‌ها… لطفاً چند لحظه منتظر بمانید.',
    'tr': 'Benzin istasyonları yükleniyor… lütfen bekleyin.',
    'ru': 'Загрузка АЗС… пожалуйста, подождите.',
    'ar': 'جاري تحميل المحطات… يرجى الانتظار قليلاً.',
    'uk': 'Завантаження АЗС… зачекайте хвилинку.',
    'ro': 'Se încarcă stațiile… așteaptă puțin.',
    'pl': 'Ładowanie stacji… proszę chwilę poczekać.',
  },
  'deals_fab': {
    'en': 'Deals',
    'de': 'Deals',
    'fa': 'تخفیف‌ها',
    'tr': 'Fırsatlar',
    'ru': 'Скидки',
    'ar': 'عروض',
    'uk': 'Знижки',
    'ro': 'Oferte',
    'pl': 'Okazje',
  },
  'deals_fab_locked': {
    'en': 'Deals · Premium',
    'de': 'Deals · Premium',
    'fa': 'تخفیف‌ها · پرمیوم',
    'tr': 'Fırsatlar · Premium',
    'ru': 'Скидки · Premium',
    'ar': 'عروض · مميز',
    'uk': 'Знижки · Premium',
    'ro': 'Oferte · Premium',
    'pl': 'Okazje · Premium',
  },
  'deals_premium_title': {
    'en': 'Unlock savings tools',
    'de': 'Spar-Tools freischalten',
    'fa': 'ابزارهای صرفه‌جویی را باز کن',
    'tr': 'Tasarruf araçlarını aç',
    'ru': 'Откройте инструменты экономии',
    'ar': 'افتح أدوات التوفير',
    'uk': 'Відкрийте інструменти економії',
    'ro': 'Deblochează uneltele de economisit',
    'pl': 'Odblokuj narzędzia oszczędzania',
  },
  'deals_premium_desc': {
    'en':
        'Practical ways to pay less at the pump that are available in your country. Premium unlocks the full list with step-by-step instructions.',
    'de':
        'Praktische Wege, an der Zapfsäule weniger zu zahlen – passend zu deinem Land. Premium schaltet die komplette Liste mit Schritt-für-Schritt-Anleitung frei.',
    'fa':
        'راه‌های عملی برای کمتر پرداخت کردن سر پمپ که در کشور تو در دسترس است. پرمیوم لیست کامل را همراه با راهنمای قدم‌به‌قدم باز می‌کند.',
    'tr':
        'Ülkende geçerli, pompada daha az ödemenin pratik yolları. Premium, adım adım talimatlarla tam listeyi açar.',
    'ru':
        'Практичные способы платить меньше на АЗС, доступные в вашей стране. Premium открывает полный список с пошаговыми инструкциями.',
    'ar':
        'طرق عملية لدفع أقل عند المضخة متاحة في بلدك. النسخة المميزة تفتح القائمة الكاملة مع تعليمات خطوة بخطوة.',
    'uk':
        'Практичні способи платити менше на АЗС, доступні у вашій країні. Premium відкриває повний список із покроковими інструкціями.',
    'ro':
        'Modalități practice de a plăti mai puțin la pompă, disponibile în țara ta. Premium deblochează lista completă cu instrucțiuni pas cu pas.',
    'pl':
        'Praktyczne sposoby, by płacić mniej na stacji, dostępne w Twoim kraju. Premium odblokowuje pełną listę z instrukcjami krok po kroku.',
  },
  'deals_premium_b1': {
    'en':
        'Loyalty programs at partner stations — collect points and use fuel coupons',
    'de':
        'Treueprogramme an Partner-Tankstellen – Punkte sammeln und Tank-Coupons nutzen',
    'fa':
        'برنامه‌های وفاداری پمپ‌بنزین‌ها — امتیاز جمع کن و از کوپن‌های سوخت استفاده کن',
    'tr':
        'Anlaşmalı istasyonlarda sadakat programları — puan topla, yakıt kuponlarını kullan',
    'ru':
        'Программы лояльности на АЗС-партнёрах — копите баллы и используйте купоны на топливо',
    'ar':
        'برامج الولاء في المحطات الشريكة — اجمع النقاط واستخدم كوبونات الوقود',
    'uk':
        'Програми лояльності на АЗС-партнерах — збирайте бали та використовуйте купони на пальне',
    'ro':
        'Programe de loialitate la benzinăriile partenere — strânge puncte și folosește cupoane de carburant',
    'pl':
        'Programy lojalnościowe na stacjach partnerskich — zbieraj punkty i korzystaj z kuponów na paliwo',
  },
  'deals_premium_b2': {
    'en':
        'Pay-at-pump apps — pay from your phone; the apps sometimes run offers for new users',
    'de':
        'Bezahl-Apps an der Zapfsäule – per Handy zahlen; die Apps haben gelegentlich Angebote für Neukunden',
    'fa':
        'اپ‌های پرداخت سر پمپ — پرداخت با موبایل؛ این اپ‌ها گاهی برای کاربران جدید پیشنهاد ویژه دارند',
    'tr':
        'Pompada ödeme uygulamaları — telefonla öde; uygulamalar zaman zaman yeni kullanıcılara kampanya sunar',
    'ru':
        'Приложения для оплаты у колонки — платите с телефона; иногда в них бывают акции для новых пользователей',
    'ar':
        'تطبيقات الدفع عند المضخة — ادفع من هاتفك؛ وأحياناً تقدم هذه التطبيقات عروضاً للمستخدمين الجدد',
    'uk':
        'Застосунки для оплати біля колонки — платіть із телефона; іноді в них бувають акції для нових користувачів',
    'ro':
        'Aplicații de plată la pompă — plătești din telefon; uneori au oferte pentru utilizatorii noi',
    'pl':
        'Aplikacje do płacenia przy dystrybutorze — płać telefonem; czasem mają oferty dla nowych użytkowników',
  },
  'deals_premium_b3': {
    'en':
        'Best time of day to fill up (Germany) — an estimate based on the usual evening price drop',
    'de':
        'Beste Tankzeit (Deutschland) – Schätzung auf Basis des üblichen Preisrückgangs am Abend',
    'fa':
        'بهترین ساعت سوخت‌گیری (آلمان) — تخمینی بر اساس افت معمول قیمت در عصر',
    'tr':
        'Yakıt almak için en iyi saat (Almanya) — akşamları görülen olağan fiyat düşüşüne dayalı tahmin',
    'ru':
        'Лучшее время для заправки (Германия) — оценка на основе обычного вечернего снижения цен',
    'ar':
        'أفضل وقت للتزود بالوقود (ألمانيا) — تقدير مبني على الانخفاض المعتاد للأسعار مساءً',
    'uk':
        'Найкращий час для заправки (Німеччина) — оцінка на основі звичного вечірнього зниження цін',
    'ro':
        'Cea mai bună oră de alimentare (Germania) — estimare pe baza scăderii obișnuite a prețurilor seara',
    'pl':
        'Najlepsza pora na tankowanie (Niemcy) — szacunek oparty na typowym wieczornym spadku cen',
  },
  'deals_premium_b4': {
    'en':
        'Deals shared by other drivers nearby — with directions to the station',
    'de':
        'Von anderen Fahrern geteilte Angebote in der Nähe – mit Route zur Tankstelle',
    'fa':
        'تخفیف‌هایی که راننده‌های دیگر در نزدیکی تو ثبت کرده‌اند — با مسیریابی تا پمپ',
    'tr':
        'Yakındaki diğer sürücülerin paylaştığı fırsatlar — istasyona yol tarifiyle',
    'ru':
        'Скидки рядом, которыми поделились другие водители, — с маршрутом до АЗС',
    'ar':
        'عروض قريبة يشاركها سائقون آخرون — مع الاتجاهات إلى المحطة',
    'uk':
        'Знижки поруч, якими поділилися інші водії, — з маршрутом до АЗС',
    'ro':
        'Oferte din apropiere distribuite de alți șoferi — cu traseu până la benzinărie',
    'pl':
        'Okazje w pobliżu udostępnione przez innych kierowców — z nawigacją do stacji',
  },
  'deals_title': {
    'en': 'Coupons & savings',
    'de': 'Coupons & Sparen',
    'fa': 'کوپن‌ها و صرفه‌جویی',
    'tr': 'Kuponlar ve tasarruf',
    'ru': 'Купоны и экономия',
    'ar': 'كوبونات وتوفير',
    'uk': 'Купони та економія',
    'ro': 'Cupoane și economii',
    'pl': 'Kupony i oszczędności',
  },
  'deals_loyalty_section': {
    'en': 'Active loyalty coupons',
    'de': 'Aktive Treue-Coupons',
    'fa': 'کوپن‌های فعال شبکه‌های وفاداری',
    'tr': 'Aktif sadakat kuponları',
    'ru': 'Активные купоны лояльности',
    'ar': 'كوبونات الولاء النشطة',
    'uk': 'Активні купони лояльності',
    'ro': 'Cupoane de loialitate active',
    'pl': 'Aktywne kupony lojalnościowe',
  },
  'deals_payapp_section': {
    'en': 'Pay-at-pump apps (referral / first fill)',
    'de': 'Apps zum Bezahlen an der Säule',
    'fa': 'اپ‌های پرداخت سر پمپ (دعوت / سوخت اول)',
    'tr': 'Pompa başı ödeme uygulamaları',
    'ru': 'Приложения оплаты у колонки',
    'ar': 'تطبيقات الدفع عند المضخة',
    'uk': 'Додатки оплати біля колонки',
    'ro': 'Aplicații plată la pompă',
    'pl': 'Aplikacje płatności przy dystrybutorze',
  },
  'deals_crowd_section': {
    'en': 'Deals shared by drivers',
    'de': 'Von Fahrern geteilte Deals',
    'fa': 'تخفیف‌های ثبت‌شده توسط کاربران',
    'tr': 'Sürücülerin paylaştığı fırsatlar',
    'ru': 'Скидки от водителей',
    'ar': 'عروض من السائقين',
    'uk': 'Знижки від водіїв',
    'ro': 'Oferte de la șoferi',
    'pl': 'Okazje od kierowców',
  },
  'deals_time_section': {
    'en': 'Smart timing (Germany)',
    'de': 'Günstig tanken nach Uhrzeit',
    'fa': 'تخفیف زمانی هوشمند (آلمان)',
    'tr': 'Akıllı zamanlama (Almanya)',
    'ru': 'Умное время заправки (Германия)',
    'ar': 'توقيت ذكي للتزود (ألمانيا)',
    'uk': 'Розумний час заправки (Німеччина)',
    'ro': 'Oră inteligentă (Germania)',
    'pl': 'Inteligentna pora (Niemcy)',
  },
  'deals_empty_loyalty': {
    'en': 'No curated loyalty promos for this country yet.',
    'de': 'Noch keine Treue-Promos für dieses Land.',
    'fa': 'فعلاً کوپن وفاداری آماده‌ای برای این کشور نیست.',
    'tr': 'Bu ülke için henüz sadakat kampanyası yok.',
    'ru': 'Пока нет купонов лояльности для этой страны.',
    'ar': 'لا كوبونات ولاء لهذا البلد بعد.',
    'uk': 'Поки немає купонів лояльності для цієї країни.',
    'ro': 'Încă nu există promoții de loialitate.',
    'pl': 'Brak promocji lojalnościowych dla tego kraju.',
  },
  'deals_empty_payapp': {
    'en': 'No pay-at-pump referral offers listed here yet.',
    'de': 'Noch keine Pay-at-pump Angebote gelistet.',
    'fa': 'فعلاً پیشنهاد دعوت اپ پرداخت سر پمپ برای اینجا نیست.',
    'tr': 'Henüz pompa başı ödeme teklifi yok.',
    'ru': 'Пока нет предложений оплаты у колонки.',
    'ar': 'لا عروض دفع عند المضخة بعد.',
    'uk': 'Поки немає пропозицій оплати біля колонки.',
    'ro': 'Încă nu există oferte plată la pompă.',
    'pl': 'Brak ofert płatności przy dystrybutorze.',
  },
  'deals_empty_crowd': {
    'en': 'No live local deals yet — be the first to share one.',
    'de': 'Noch keine lokalen Deals — teile den ersten.',
    'fa': 'هنوز تخفیف محلی ثبت نشده — اولین نفری باش که ثبت می‌کند.',
    'tr': 'Henüz yerel fırsat yok — ilk paylaşan sen ol.',
    'ru': 'Пока нет местных скидок — поделитесь первой.',
    'ar': 'لا عروض محلية بعد — كن أول من يشارك.',
    'uk': 'Поки немає місцевих знижок — поділіться першим.',
    'ro': 'Încă nu există oferte locale — fii primul.',
    'pl': 'Brak lokalnych okazji — udostępnij pierwszą.',
  },
  'deals_disclaimer': {
    'en':
        'Promos change often. Verify in the loyalty / pay-app before fueling. Time tips are estimates from the German evening-price pattern (MTS-K) plus your local TankerKönig samples — not a guarantee.',
    'de':
        'Aktionen ändern sich oft. Vor dem Tanken in der Treue-/Pay-App prüfen. Zeittipps schätzen das abendliche Preismuster (MTS-K) plus lokale TankerKönig-Stichproben — keine Garantie.',
    'fa':
        'پروموشن‌ها زود عوض می‌شوند؛ قبل از سوخت‌گیری در اپ وفاداری/پرداخت چک کن. راهنمای زمانی بر اساس الگوی شب آلمان (MTS-K) و نمونه‌های محلی TankerKönig است — تضمین قطعی نیست.',
    'tr':
        'Kampanyalar sık değişir. Yakıt almadan önce uygulamada kontrol edin. Zaman ipuçları tahmindir.',
    'ru':
        'Акции часто меняются. Проверяйте в приложении перед заправкой. Советы по времени — оценка.',
    'ar':
        'العروض تتغير كثيراً. تحقق في التطبيق قبل التزود. نصائح التوقيت تقديرية.',
    'uk':
        'Акції часто змінюються. Перевірте в додатку перед заправкою. Поради щодо часу — оцінка.',
    'ro':
        'Promoțiile se schimbă des. Verifică în aplicație înainte. Sfaturile de oră sunt estimări.',
    'pl':
        'Promocje często się zmieniają. Sprawdź w aplikacji przed tankowaniem. Wskazówki czasowe to szacunki.',
  },
  'deal_payback_title': {
    'en': 'Payback × points at Aral',
    'de': 'Payback Mehrfachpunkte bei Aral',
    'fa': 'Payback امتیاز چندبرابر در Aral',
    'tr': 'Aral’da Payback çoklu puan',
    'ru': 'Payback x баллов на Aral',
    'ar': 'Payback نقاط مضاعفة في Aral',
    'uk': 'Payback x балів на Aral',
    'ro': 'Payback puncte multiple la Aral',
    'pl': 'Payback x punkty na Aral',
  },
  'deal_payback_detail': {
    'en':
        'Collect {network} rewards when you fuel at {brand}. Current coupons and offers change regularly — check them in the app before fueling.',
    'de':
        'Sammle {network}-Vorteile beim Tanken bei {brand}. Aktuelle Coupons und Angebote wechseln regelmäßig – prüfe sie vor dem Tanken in der App.',
    'fa':
        'هنگام سوخت‌گیری در {brand} امتیاز/پاداش {network} بگیر. کوپن‌ها و پیشنهادهای فعلی مرتب عوض می‌شوند — قبل از سوخت‌گیری در اپ چک کن.',
    'tr':
        '{brand} istasyonlarında yakıt alırken {network} ödülleri kazan. Güncel kuponlar ve teklifler düzenli değişir — yakıt almadan önce uygulamadan kontrol et.',
    'ru':
        'Получайте бонусы {network} при заправке на {brand}. Актуальные купоны и предложения регулярно меняются — проверяйте их в приложении перед заправкой.',
    'ar':
        'احصل على مكافآت {network} عند التزود بالوقود في {brand}. الكوبونات والعروض الحالية تتغير باستمرار — تحقق منها في التطبيق قبل التزود.',
    'uk':
        'Отримуйте бонуси {network} під час заправки на {brand}. Актуальні купони й пропозиції регулярно змінюються — перевіряйте їх у застосунку перед заправкою.',
    'ro':
        'Primești recompense {network} când alimentezi la {brand}. Cupoanele și ofertele curente se schimbă des — verifică-le în aplicație înainte de alimentare.',
    'pl':
        'Zbieraj nagrody {network} podczas tankowania na {brand}. Aktualne kupony i oferty regularnie się zmieniają — sprawdź je w aplikacji przed tankowaniem.',
  },
  'deal_deutschlandcard_title': {
    'en': 'DeutschlandCard at Esso',
    'de': 'DeutschlandCard bei Esso',
    'fa': 'DeutschlandCard در Esso',
    'tr': 'Esso’da DeutschlandCard',
    'ru': 'DeutschlandCard на Esso',
    'ar': 'DeutschlandCard في Esso',
    'uk': 'DeutschlandCard на Esso',
    'ro': 'DeutschlandCard la Esso',
    'pl': 'DeutschlandCard na Esso',
  },
  'deal_deutschlandcard_detail': {
    'en':
        'Collect {network} rewards when you fuel at {brand}. Current coupons and offers change regularly — check them in the app before fueling.',
    'de':
        'Sammle {network}-Vorteile beim Tanken bei {brand}. Aktuelle Coupons und Angebote wechseln regelmäßig – prüfe sie vor dem Tanken in der App.',
    'fa':
        'هنگام سوخت‌گیری در {brand} امتیاز/پاداش {network} بگیر. کوپن‌ها و پیشنهادهای فعلی مرتب عوض می‌شوند — قبل از سوخت‌گیری در اپ چک کن.',
    'tr':
        '{brand} istasyonlarında yakıt alırken {network} ödülleri kazan. Güncel kuponlar ve teklifler düzenli değişir — yakıt almadan önce uygulamadan kontrol et.',
    'ru':
        'Получайте бонусы {network} при заправке на {brand}. Актуальные купоны и предложения регулярно меняются — проверяйте их в приложении перед заправкой.',
    'ar':
        'احصل على مكافآت {network} عند التزود بالوقود في {brand}. الكوبونات والعروض الحالية تتغير باستمرار — تحقق منها في التطبيق قبل التزود.',
    'uk':
        'Отримуйте бонуси {network} під час заправки на {brand}. Актуальні купони й пропозиції регулярно змінюються — перевіряйте їх у застосунку перед заправкою.',
    'ro':
        'Primești recompense {network} când alimentezi la {brand}. Cupoanele și ofertele curente se schimbă des — verifică-le în aplicație înainte de alimentare.',
    'pl':
        'Zbieraj nagrody {network} podczas tankowania na {brand}. Aktualne kupony i oferty regularnie się zmieniają — sprawdź je w aplikacji przed tankowaniem.',
  },
  'deal_shell_title': {
    'en': 'Shell ClubSmart boost',
    'de': 'Shell ClubSmart Extra-Punkte',
    'fa': 'تقویت Shell ClubSmart',
    'tr': 'Shell ClubSmart ekstra puan',
    'ru': 'Бонус Shell ClubSmart',
    'ar': 'تعزيز Shell ClubSmart',
    'uk': 'Бонус Shell ClubSmart',
    'ro': 'Bonus Shell ClubSmart',
    'pl': 'Bonus Shell ClubSmart',
  },
  'deal_shell_detail': {
    'en':
        'Collect {network} rewards when you fuel at {brand}. Current coupons and offers change regularly — check them in the app before fueling.',
    'de':
        'Sammle {network}-Vorteile beim Tanken bei {brand}. Aktuelle Coupons und Angebote wechseln regelmäßig – prüfe sie vor dem Tanken in der App.',
    'fa':
        'هنگام سوخت‌گیری در {brand} امتیاز/پاداش {network} بگیر. کوپن‌ها و پیشنهادهای فعلی مرتب عوض می‌شوند — قبل از سوخت‌گیری در اپ چک کن.',
    'tr':
        '{brand} istasyonlarında yakıt alırken {network} ödülleri kazan. Güncel kuponlar ve teklifler düzenli değişir — yakıt almadan önce uygulamadan kontrol et.',
    'ru':
        'Получайте бонусы {network} при заправке на {brand}. Актуальные купоны и предложения регулярно меняются — проверяйте их в приложении перед заправкой.',
    'ar':
        'احصل على مكافآت {network} عند التزود بالوقود في {brand}. الكوبونات والعروض الحالية تتغير باستمرار — تحقق منها في التطبيق قبل التزود.',
    'uk':
        'Отримуйте бонуси {network} під час заправки на {brand}. Актуальні купони й пропозиції регулярно змінюються — перевіряйте їх у застосунку перед заправкою.',
    'ro':
        'Primești recompense {network} când alimentezi la {brand}. Cupoanele și ofertele curente se schimbă des — verifică-le în aplicație înainte de alimentare.',
    'pl':
        'Zbieraj nagrody {network} podczas tankowania na {brand}. Aktualne kupony i oferty regularnie się zmieniają — sprawdź je w aplikacji przed tankowaniem.',
  },
  'deal_shell_us_title': {
    'en': 'Shell Fuel Rewards (USA)',
    'de': 'Shell Fuel Rewards (USA)',
    'fa': 'Shell Fuel Rewards (آمریکا)',
    'tr': 'Shell Fuel Rewards (ABD)',
    'ru': 'Shell Fuel Rewards (США)',
    'ar': 'Shell Fuel Rewards (أمريكا)',
    'uk': 'Shell Fuel Rewards (США)',
    'ro': 'Shell Fuel Rewards (SUA)',
    'pl': 'Shell Fuel Rewards (USA)',
  },
  'deal_shell_us_detail': {
    'en':
        'Collect {network} rewards when you fuel at {brand}. Current coupons and offers change regularly — check them in the app before fueling.',
    'de':
        'Sammle {network}-Vorteile beim Tanken bei {brand}. Aktuelle Coupons und Angebote wechseln regelmäßig – prüfe sie vor dem Tanken in der App.',
    'fa':
        'هنگام سوخت‌گیری در {brand} امتیاز/پاداش {network} بگیر. کوپن‌ها و پیشنهادهای فعلی مرتب عوض می‌شوند — قبل از سوخت‌گیری در اپ چک کن.',
    'tr':
        '{brand} istasyonlarında yakıt alırken {network} ödülleri kazan. Güncel kuponlar ve teklifler düzenli değişir — yakıt almadan önce uygulamadan kontrol et.',
    'ru':
        'Получайте бонусы {network} при заправке на {brand}. Актуальные купоны и предложения регулярно меняются — проверяйте их в приложении перед заправкой.',
    'ar':
        'احصل على مكافآت {network} عند التزود بالوقود في {brand}. الكوبونات والعروض الحالية تتغير باستمرار — تحقق منها في التطبيق قبل التزود.',
    'uk':
        'Отримуйте бонуси {network} під час заправки на {brand}. Актуальні купони й пропозиції регулярно змінюються — перевіряйте їх у застосунку перед заправкою.',
    'ro':
        'Primești recompense {network} când alimentezi la {brand}. Cupoanele și ofertele curente se schimbă des — verifică-le în aplicație înainte de alimentare.',
    'pl':
        'Zbieraj nagrody {network} podczas tankowania na {brand}. Aktualne kupony i oferty regularnie się zmieniają — sprawdź je w aplikacji przed tankowaniem.',
  },
  'deal_petro_title': {
    'en': 'Petro-Points (Canada)',
    'de': 'Petro-Points (Kanada)',
    'fa': 'Petro-Points (کانادا)',
    'tr': 'Petro-Points (Kanada)',
    'ru': 'Petro-Points (Канада)',
    'ar': 'Petro-Points (كندا)',
    'uk': 'Petro-Points (Канада)',
    'ro': 'Petro-Points (Canada)',
    'pl': 'Petro-Points (Kanada)',
  },
  'deal_petro_detail': {
    'en':
        'Collect {network} rewards when you fuel at {brand}. Current coupons and offers change regularly — check them in the app before fueling.',
    'de':
        'Sammle {network}-Vorteile beim Tanken bei {brand}. Aktuelle Coupons und Angebote wechseln regelmäßig – prüfe sie vor dem Tanken in der App.',
    'fa':
        'هنگام سوخت‌گیری در {brand} امتیاز/پاداش {network} بگیر. کوپن‌ها و پیشنهادهای فعلی مرتب عوض می‌شوند — قبل از سوخت‌گیری در اپ چک کن.',
    'tr':
        '{brand} istasyonlarında yakıt alırken {network} ödülleri kazan. Güncel kuponlar ve teklifler düzenli değişir — yakıt almadan önce uygulamadan kontrol et.',
    'ru':
        'Получайте бонусы {network} при заправке на {brand}. Актуальные купоны и предложения регулярно меняются — проверяйте их в приложении перед заправкой.',
    'ar':
        'احصل على مكافآت {network} عند التزود بالوقود في {brand}. الكوبونات والعروض الحالية تتغير باستمرار — تحقق منها في التطبيق قبل التزود.',
    'uk':
        'Отримуйте бонуси {network} під час заправки на {brand}. Актуальні купони й пропозиції регулярно змінюються — перевіряйте їх у застосунку перед заправкою.',
    'ro':
        'Primești recompense {network} când alimentezi la {brand}. Cupoanele și ofertele curente se schimbă des — verifică-le în aplicație înainte de alimentare.',
    'pl':
        'Zbieraj nagrody {network} podczas tankowania na {brand}. Aktualne kupony i oferty regularnie się zmieniają — sprawdź je w aplikacji przed tankowaniem.',
  },
  'deal_ryd_bonus': {
    'en':
        'Pay for fuel from your phone at the pump, without going to the kiosk. New-user offers appear from time to time — check the app.',
    'de':
        'Direkt an der Säule per Handy bezahlen, ohne zur Kasse zu gehen. Gelegentlich gibt es Angebote für Neukunden – schau in der App nach.',
    'fa':
        'پول سوخت را سر پمپ با موبایل بده، بدون رفتن به صندوق. گاهی برای کاربران جدید پیشنهاد ویژه هست — در اپ چک کن.',
    'tr':
        'Kasaya gitmeden, pompada telefonla yakıt öde. Zaman zaman yeni kullanıcılara kampanyalar olur — uygulamadan kontrol et.',
    'ru':
        'Оплачивайте топливо с телефона прямо у колонки, без похода в кассу. Иногда бывают акции для новых пользователей — проверьте в приложении.',
    'ar':
        'ادفع ثمن الوقود من هاتفك عند المضخة دون الذهاب إلى الكاشير. تظهر أحياناً عروض للمستخدمين الجدد — تحقق في التطبيق.',
    'uk':
        'Оплачуйте пальне з телефона прямо біля колонки, без походу до каси. Іноді бувають акції для нових користувачів — перевірте в застосунку.',
    'ro':
        'Plătești carburantul din telefon la pompă, fără să mergi la casă. Din când în când apar oferte pentru utilizatori noi — verifică în aplicație.',
    'pl':
        'Płać za paliwo telefonem przy dystrybutorze, bez chodzenia do kasy. Od czasu do czasu pojawiają się oferty dla nowych użytkowników — sprawdź w aplikacji.',
  },
  'deal_pace_bonus': {
    'en':
        'Pay for fuel from your phone at the pump, without going to the kiosk. New-user offers appear from time to time — check the app.',
    'de':
        'Direkt an der Säule per Handy bezahlen, ohne zur Kasse zu gehen. Gelegentlich gibt es Angebote für Neukunden – schau in der App nach.',
    'fa':
        'پول سوخت را سر پمپ با موبایل بده، بدون رفتن به صندوق. گاهی برای کاربران جدید پیشنهاد ویژه هست — در اپ چک کن.',
    'tr':
        'Kasaya gitmeden, pompada telefonla yakıt öde. Zaman zaman yeni kullanıcılara kampanyalar olur — uygulamadan kontrol et.',
    'ru':
        'Оплачивайте топливо с телефона прямо у колонки, без похода в кассу. Иногда бывают акции для новых пользователей — проверьте в приложении.',
    'ar':
        'ادفع ثمن الوقود من هاتفك عند المضخة دون الذهاب إلى الكاشير. تظهر أحياناً عروض للمستخدمين الجدد — تحقق في التطبيق.',
    'uk':
        'Оплачуйте пальне з телефона прямо біля колонки, без походу до каси. Іноді бувають акції для нових користувачів — перевірте в застосунку.',
    'ro':
        'Plătești carburantul din telefon la pompă, fără să mergi la casă. Din când în când apar oferte pentru utilizatori noi — verifică în aplicație.',
    'pl':
        'Płać za paliwo telefonem przy dystrybutorze, bez chodzenia do kasy. Od czasu do czasu pojawiają się oferty dla nowych użytkowników — sprawdź w aplikacji.',
  },
  'deal_fillgo_bonus': {
    'en':
        'Pay for fuel from your phone at the pump, without going to the kiosk. New-user offers appear from time to time — check the app.',
    'de':
        'Direkt an der Säule per Handy bezahlen, ohne zur Kasse zu gehen. Gelegentlich gibt es Angebote für Neukunden – schau in der App nach.',
    'fa':
        'پول سوخت را سر پمپ با موبایل بده، بدون رفتن به صندوق. گاهی برای کاربران جدید پیشنهاد ویژه هست — در اپ چک کن.',
    'tr':
        'Kasaya gitmeden, pompada telefonla yakıt öde. Zaman zaman yeni kullanıcılara kampanyalar olur — uygulamadan kontrol et.',
    'ru':
        'Оплачивайте топливо с телефона прямо у колонки, без похода в кассу. Иногда бывают акции для новых пользователей — проверьте в приложении.',
    'ar':
        'ادفع ثمن الوقود من هاتفك عند المضخة دون الذهاب إلى الكاشير. تظهر أحياناً عروض للمستخدمين الجدد — تحقق في التطبيق.',
    'uk':
        'Оплачуйте пальне з телефона прямо біля колонки, без походу до каси. Іноді бувають акції для нових користувачів — перевірте в застосунку.',
    'ro':
        'Plătești carburantul din telefon la pompă, fără să mergi la casă. Din când în când apar oferte pentru utilizatori noi — verifică în aplicație.',
    'pl':
        'Płać za paliwo telefonem przy dystrybutorze, bez chodzenia do kasy. Od czasu do czasu pojawiają się oferty dla nowych użytkowników — sprawdź w aplikacji.',
  },
  'deal_shell_app_bonus': {
    'en':
        'Pay for fuel from your phone at the pump, without going to the kiosk. New-user offers appear from time to time — check the app.',
    'de':
        'Direkt an der Säule per Handy bezahlen, ohne zur Kasse zu gehen. Gelegentlich gibt es Angebote für Neukunden – schau in der App nach.',
    'fa':
        'پول سوخت را سر پمپ با موبایل بده، بدون رفتن به صندوق. گاهی برای کاربران جدید پیشنهاد ویژه هست — در اپ چک کن.',
    'tr':
        'Kasaya gitmeden, pompada telefonla yakıt öde. Zaman zaman yeni kullanıcılara kampanyalar olur — uygulamadan kontrol et.',
    'ru':
        'Оплачивайте топливо с телефона прямо у колонки, без похода в кассу. Иногда бывают акции для новых пользователей — проверьте в приложении.',
    'ar':
        'ادفع ثمن الوقود من هاتفك عند المضخة دون الذهاب إلى الكاشير. تظهر أحياناً عروض للمستخدمين الجدد — تحقق في التطبيق.',
    'uk':
        'Оплачуйте пальне з телефона прямо біля колонки, без походу до каси. Іноді бувають акції для нових користувачів — перевірте в застосунку.',
    'ro':
        'Plătești carburantul din telefon la pompă, fără să mergi la casă. Din când în când apar oferte pentru utilizatori noi — verifică în aplicație.',
    'pl':
        'Płać za paliwo telefonem przy dystrybutorze, bez chodzenia do kasy. Od czasu do czasu pojawiają się oferty dla nowych użytkowników — sprawdź w aplikacji.',
  },
  'deal_open': {
    'en': 'Open',
    'de': 'Öffnen',
    'fa': 'باز کردن',
    'tr': 'Aç',
    'ru': 'Открыть',
    'ar': 'فتح',
    'uk': 'Відкрити',
    'ro': 'Deschide',
    'pl': 'Otwórz',
  },
  'deal_time_wait': {
    'en':
        'Now ~€{price}/L. If you wait about {hours}h until 18:00–22:00, you may save ~{cents} ¢/L — about €{euros} on {litres} L (evening pattern + TankerKönig samples).',
    'de':
        'Jetzt ca. €{price}/L. Warte ~{hours} Std. bis 18–22 Uhr: oft ~{cents} ct/L günstiger — ca. €{euros} auf {litres} L (Abendmuster + TankerKönig).',
    'fa':
        'الان حدود €{price}/L. اگر حدود {hours} ساعت تا بازهٔ ۱۸–۲۲ صبر کنی، ممکن است ~{cents} سنت/لیتر ارزان‌تر شود — روی {litres} لیتر حدود €{euros} (الگوی شب + نمونه‌های TankerKönig).',
    'tr':
        'Şu an ~€{price}/L. 18–22’ye ~{hours} saat beklersen ~{cents} ct/L, {litres} L’de ~€{euros} tasarruf olabilir.',
    'ru':
        'Сейчас ~€{price}/л. Подождите ~{hours} ч до 18–22: часто ~{cents} ¢/л, ≈ €{euros} на {litres} л.',
    'ar':
        'الآن ~€{price}/لتر. إن انتظرت ~{hours} ساعة حتى 18–22 قد توفر ~{cents} سنت/لتر ≈ €{euros} لـ {litres} لتر.',
    'uk':
        'Зараз ~€{price}/л. Зачекайте ~{hours} год до 18–22: часто ~{cents} ¢/л, ≈ €{euros} на {litres} л.',
    'ro':
        'Acum ~€{price}/L. Dacă aștepți ~{hours} h până la 18–22, poți economisi ~{cents} ct/L ≈ €{euros} pe {litres} L.',
    'pl':
        'Teraz ~€{price}/L. Poczekaj ~{hours} h do 18–22: często ~{cents} ct/L ≈ €{euros} na {litres} L.',
  },
  'deal_time_now_cheap': {
    'en':
        'You are in the typical cheap window (18:00–22:00). Evening prices are often ~{cents} ¢/L lower — about €{euros} on {litres} L vs morning.',
    'de':
        'Du bist im günstigen Fenster (18–22 Uhr). Abends oft ~{cents} ct/L günstiger — ca. €{euros} auf {litres} L gegenüber morgens.',
    'fa':
        'الان در بازهٔ ارزان معمول (۱۸–۲۲) هستی. شب معمولاً ~{cents} سنت/لیتر ارزان‌تر از صبح است — روی {litres} لیتر حدود €{euros}.',
    'tr':
        'Ucuz penceredesiniz (18–22). Akşam genelde ~{cents} ct/L daha ucuz — {litres} L’de ~€{euros}.',
    'ru':
        'Вы в дешёвом окне (18–22). Вечером часто на ~{cents} ¢/л дешевле — ≈ €{euros} на {litres} л.',
    'ar':
        'أنت في نافذة السعر الرخيص (18–22). المساء غالباً أرخص بـ ~{cents} سنت/لتر ≈ €{euros} لـ {litres} لتر.',
    'uk':
        'Ви в дешевому вікні (18–22). Увечері часто на ~{cents} ¢/л дешевше — ≈ €{euros} на {litres} л.',
    'ro':
        'Ești în fereastra ieftină (18–22). Seara adesea cu ~{cents} ct/L mai ieftin ≈ €{euros} pe {litres} L.',
    'pl':
        'Jesteś w tanim oknie (18–22). Wieczorem często o ~{cents} ct/L taniej ≈ €{euros} na {litres} L.',
  },
  'deal_time_night': {
    'en':
        'Overnight prices vary. The strongest pattern is evening 18:00–22:00 (~{cents} ¢/L, ≈ €{euros} on {litres} L vs morning).',
    'de':
        'Nachtpreise schwanken. Stärkstes Muster: 18–22 Uhr (~{cents} ct/L, ≈ €{euros} auf {litres} L vs. morgens).',
    'fa':
        'قیمت شبانه متغیر است. قوی‌ترین الگو بازهٔ ۱۸–۲۲ است (~{cents} سنت/لیتر، حدود €{euros} روی {litres} لیتر نسبت به صبح).',
    'tr':
        'Gece fiyatları değişir. En güçlü desen 18–22 (~{cents} ct/L, {litres} L’de ~€{euros}).',
    'ru':
        'Ночные цены плавают. Лучший паттерн 18–22 (~{cents} ¢/л, ≈ €{euros} на {litres} л).',
    'ar':
        'أسعار الليل تتقلب. أقوى نمط 18–22 (~{cents} سنت/لتر ≈ €{euros} لـ {litres} لتر).',
    'uk':
        'Нічні ціни плавають. Найкращий патерн 18–22 (~{cents} ¢/л ≈ €{euros} на {litres} л).',
    'ro':
        'Prețurile de noapte variază. Cel mai bun tipar: 18–22 (~{cents} ct/L ≈ €{euros} pe {litres} L).',
    'pl':
        'Ceny nocne bywają różne. Najsilniejszy wzorzec: 18–22 (~{cents} ct/L ≈ €{euros} na {litres} L).',
  },
  'deal_share_btn': {
    'en': 'Share',
    'de': 'Teilen',
    'fa': 'ثبت تخفیف',
    'tr': 'Paylaş',
    'ru': 'Поделиться',
    'ar': 'مشاركة',
    'uk': 'Поділитися',
    'ro': 'Distribuie',
    'pl': 'Udostępnij',
  },
  'deal_share_title': {
    'en': 'Share a local deal',
    'de': 'Lokalen Deal teilen',
    'fa': 'تخفیف محلی را ثبت کن',
    'tr': 'Yerel fırsat paylaş',
    'ru': 'Поделиться местной скидкой',
    'ar': 'شارك عرضاً محلياً',
    'uk': 'Поділитися місцевою знижкою',
    'ro': 'Distribuie o ofertă locală',
    'pl': 'Udostępnij lokalną okazję',
  },
  'deal_share_title_field': {
    'en': 'Title (e.g. JET −3 ct until 8pm)',
    'de': 'Titel (z. B. JET −3 ct bis 20 Uhr)',
    'fa': 'عنوان (مثلاً JET منهای ۳ سنت تا ۲۰)',
    'tr': 'Başlık (örn. JET −3 ct 20:00’e kadar)',
    'ru': 'Заголовок (напр. JET −3 ct до 20:00)',
    'ar': 'العنوان (مثل JET −3 سنت حتى 20)',
    'uk': 'Заголовок (напр. JET −3 ct до 20:00)',
    'ro': 'Titlu (ex. JET −3 ct până la 20)',
    'pl': 'Tytuł (np. JET −3 ct do 20:00)',
  },
  'deal_share_detail_field': {
    'en': 'Details (Kaufland card, hours, …)',
    'de': 'Details (Kaufland-Karte, Uhrzeit, …)',
    'fa': 'جزئیات (کارت Kaufland، ساعت، …)',
    'tr': 'Ayrıntı (Kaufland kartı, saat, …)',
    'ru': 'Детали (карта Kaufland, часы, …)',
    'ar': 'التفاصيل (بطاقة Kaufland، الساعات، …)',
    'uk': 'Деталі (картка Kaufland, години, …)',
    'ro': 'Detalii (card Kaufland, ore, …)',
    'pl': 'Szczegóły (karta Kaufland, godziny, …)',
  },
  'deal_share_station_field': {
    'en': 'Station / place (optional)',
    'de': 'Tankstelle / Ort (optional)',
    'fa': 'پمپ / مکان (اختیاری)',
    'tr': 'İstasyon / yer (isteğe bağlı)',
    'ru': 'АЗС / место (необязательно)',
    'ar': 'المحطة / المكان (اختياري)',
    'uk': 'АЗС / місце (необовʼязково)',
    'ro': 'Stație / loc (opțional)',
    'pl': 'Stacja / miejsce (opcjonalnie)',
  },
  'deal_share_code_field': {
    'en': 'Code (optional)',
    'de': 'Code (optional)',
    'fa': 'کد (اختیاری)',
    'tr': 'Kod (isteğe bağlı)',
    'ru': 'Код (необязательно)',
    'ar': 'الرمز (اختياري)',
    'uk': 'Код (необовʼязково)',
    'ro': 'Cod (opțional)',
    'pl': 'Kod (opcjonalnie)',
  },
  'deal_share_hours': {
    'en': 'Valid for about {n} hours',
    'de': 'Gültig ca. {n} Stunden',
    'fa': 'حدود {n} ساعت معتبر',
    'tr': 'Yaklaşık {n} saat geçerli',
    'ru': 'Действует около {n} ч',
    'ar': 'صالح نحو {n} ساعة',
    'uk': 'Діє близько {n} год',
    'ro': 'Valabil circa {n} ore',
    'pl': 'Ważne ok. {n} godzin',
  },
  'deal_share_submit': {
    'en': 'Publish',
    'de': 'Veröffentlichen',
    'fa': 'انتشار',
    'tr': 'Yayınla',
    'ru': 'Опубликовать',
    'ar': 'نشر',
    'uk': 'Опублікувати',
    'ro': 'Publică',
    'pl': 'Opublikuj',
  },
  'deal_submit_ok': {
    'en': 'Thanks! +{n} points. Your deal helps other drivers.',
    'de': 'Danke! +{n} Punkte. Dein Deal hilft anderen.',
    'fa': 'ممنون! +{n} امتیاز. تخفیف تو به بقیه راننده‌ها رسید.',
    'tr': 'Teşekkürler! +{n} puan. Fırsatın başkalarına yardımcı oldu.',
    'ru': 'Спасибо! +{n} очков. Ваша скидка помогает другим.',
    'ar': 'شكراً! +{n} نقطة. عرضك يساعد الآخرين.',
    'uk': 'Дякуємо! +{n} балів. Ваша знижка допомагає іншим.',
    'ro': 'Mulțumim! +{n} puncte. Oferta ta ajută pe alții.',
    'pl': 'Dziękujemy! +{n} punktów. Twoja okazja pomaga innym.',
  },
  'deal_err_country': {
    'en': 'Deals are not enabled for this country.',
    'de': 'Deals für dieses Land nicht aktiv.',
    'fa': 'تخفیف‌ها برای این کشور فعال نیست.',
    'tr': 'Bu ülke için fırsatlar kapalı.',
    'ru': 'Скидки для этой страны недоступны.',
    'ar': 'العروض غير مفعّلة لهذا البلد.',
    'uk': 'Знижки для цієї країни вимкнені.',
    'ro': 'Ofertele nu sunt active pentru această țară.',
    'pl': 'Okazje nie są włączone dla tego kraju.',
  },
  'deal_err_title': {
    'en': 'Enter a clearer title.',
    'de': 'Bitte einen klareren Titel eingeben.',
    'fa': 'عنوان واضح‌تری بنویس.',
    'tr': 'Daha net bir başlık girin.',
    'ru': 'Введите более понятный заголовок.',
    'ar': 'أدخل عنواناً أوضح.',
    'uk': 'Введіть зрозуміліший заголовок.',
    'ro': 'Introdu un titlu mai clar.',
    'pl': 'Podaj jaśniejszy tytuł.',
  },
  'deal_err_expiry': {
    'en': 'Expiry must be in the future.',
    'de': 'Ablauf muss in der Zukunft liegen.',
    'fa': 'تاریخ انقضا باید در آینده باشد.',
    'tr': 'Bitiş gelecekte olmalı.',
    'ru': 'Срок должен быть в будущем.',
    'ar': 'يجب أن يكون الانتهاء في المستقبل.',
    'uk': 'Термін має бути в майбутньому.',
    'ro': 'Expirarea trebuie să fie în viitor.',
    'pl': 'Wygaśnięcie musi być w przyszłości.',
  },
  'deal_err_cooldown': {
    'en': 'Please wait a few minutes before another deal.',
    'de': 'Bitte ein paar Minuten warten vor dem nächsten Deal.',
    'fa': 'چند دقیقه صبر کن و بعد دوباره تخفیف ثبت کن.',
    'tr': 'Yeni fırsattan önce birkaç dakika bekleyin.',
    'ru': 'Подождите несколько минут перед следующей скидкой.',
    'ar': 'انتظر بضع دقائق قبل عرض آخر.',
    'uk': 'Зачекайте кілька хвилин перед наступною знижкою.',
    'ro': 'Așteaptă câteva minute înainte de o nouă ofertă.',
    'pl': 'Poczekaj kilka minut przed kolejną okazją.',
  },
  'deal_expires_in': {
    'en': 'Expires in ~{h} h',
    'de': 'Läuft in ~{h} Std. ab',
    'fa': 'حدود {h} ساعت تا انقضا',
    'tr': '~{h} saat içinde bitiyor',
    'ru': 'Истекает через ~{h} ч',
    'ar': 'ينتهي خلال ~{h} ساعة',
    'uk': 'Закінчується за ~{h} год',
    'ro': 'Expiră în ~{h} h',
    'pl': 'Wygasa za ~{h} h',
  },
  'deal_copy_code': {
    'en': 'Copy code',
    'de': 'Code kopieren',
    'fa': 'کپی کد',
    'tr': 'Kodu kopyala',
    'ru': 'Копировать код',
    'ar': 'نسخ الرمز',
    'uk': 'Копіювати код',
    'ro': 'Copiază codul',
    'pl': 'Kopiuj kod',
  },
  'deal_copied': {
    'en': 'Code copied',
    'de': 'Code kopiert',
    'fa': 'کد کپی شد',
    'tr': 'Kod kopyalandı',
    'ru': 'Код скопирован',
    'ar': 'تم نسخ الرمز',
    'uk': 'Код скопійовано',
    'ro': 'Cod copiat',
    'pl': 'Kod skopiowany',
  },
  'deals_premium_required': {
    'en': 'Premium required to use deals.',
    'de': 'Premium nötig für Deals.',
    'fa': 'برای استفاده از تخفیف‌ها پرمیوم لازم است.',
    'tr': 'Fırsatlar için Premium gerekir.',
    'ru': 'Для скидок нужен Premium.',
    'ar': 'يلزم Premium لاستخدام العروض.',
    'uk': 'Для знижок потрібен Premium.',
    'ro': 'Premium necesar pentru oferte.',
    'pl': 'Do okazji potrzebne jest Premium.',
  },
  'deals_premium_b5': {
    'en':
        'Step-by-step instructions for each offer: how to actually get it',
    'de':
        'Schritt-für-Schritt-Anleitung zu jedem Angebot: So bekommst du es wirklich',
    'fa':
        'راهنمای قدم‌به‌قدم برای هر پیشنهاد: دقیقاً چطور آن را بگیری',
    'tr':
        'Her teklif için adım adım talimat: gerçekten nasıl alınır',
    'ru':
        'Пошаговая инструкция к каждому предложению: как действительно его получить',
    'ar':
        'تعليمات خطوة بخطوة لكل عرض: كيف تحصل عليه فعلاً',
    'uk':
        'Покрокова інструкція до кожної пропозиції: як справді її отримати',
    'ro':
        'Instrucțiuni pas cu pas pentru fiecare ofertă: cum o obții efectiv',
    'pl':
        'Instrukcja krok po kroku do każdej oferty: jak naprawdę z niej skorzystać',
  },
  'deals_premium_note': {
    'en':
        'Offers are run by the stations and apps themselves and change often; savings depend on the current promotion and are not guaranteed.',
    'de':
        'Die Angebote stammen von den Tankstellen und Apps selbst und ändern sich oft; die Ersparnis hängt von der aktuellen Aktion ab und ist nicht garantiert.',
    'fa':
        'پیشنهادها را خود پمپ‌بنزین‌ها و اپ‌ها ارائه می‌دهند و زود عوض می‌شوند؛ میزان صرفه‌جویی به پروموشن فعلی بستگی دارد و تضمینی نیست.',
    'tr':
        'Teklifler istasyonlar ve uygulamaların kendisi tarafından sunulur ve sık değişir; tasarruf mevcut kampanyaya bağlıdır ve garanti edilmez.',
    'ru':
        'Предложения проводят сами АЗС и приложения, и они часто меняются; размер экономии зависит от текущей акции и не гарантируется.',
    'ar':
        'تقدّم المحطات والتطبيقات هذه العروض بنفسها وهي تتغير كثيراً؛ يعتمد التوفير على العرض الحالي وليس مضموناً.',
    'uk':
        'Пропозиції проводять самі АЗС і застосунки, і вони часто змінюються; економія залежить від поточної акції та не гарантується.',
    'ro':
        'Ofertele sunt oferite chiar de benzinării și aplicații și se schimbă des; economia depinde de promoția curentă și nu este garantată.',
    'pl':
        'Oferty prowadzą same stacje i aplikacje i często się zmieniają; oszczędność zależy od bieżącej promocji i nie jest gwarantowana.',
  },
  'deal_howto_title': {
    'en':
        'How do I get it?',
    'de':
        'Wie bekomme ich das?',
    'fa':
        'چطوری بگیرم؟',
    'tr':
        'Nasıl alırım?',
    'ru':
        'Как получить?',
    'ar':
        'كيف أحصل عليه؟',
    'uk':
        'Як отримати?',
    'ro':
        'Cum îl obțin?',
    'pl':
        'Jak z tego skorzystać?',
  },
  'deal_howto_loyalty_1': {
    'en':
        'Install the {network} app (or get the card) and sign up — it is free.',
    'de':
        'Installiere die {network}-App (oder hol dir die Karte) und melde dich kostenlos an.',
    'fa':
        'اپ {network} را نصب کن (یا کارتش را بگیر) و ثبت‌نام کن — رایگان است.',
    'tr':
        '{network} uygulamasını yükle (veya kartını al) ve ücretsiz üye ol.',
    'ru':
        'Установите приложение {network} (или получите карту) и бесплатно зарегистрируйтесь.',
    'ar':
        'ثبّت تطبيق {network} (أو احصل على البطاقة) وسجّل مجاناً.',
    'uk':
        'Встановіть застосунок {network} (або отримайте картку) і безкоштовно зареєструйтеся.',
    'ro':
        'Instalează aplicația {network} (sau ia cardul) și înregistrează-te gratuit.',
    'pl':
        'Zainstaluj aplikację {network} (lub weź kartę) i zarejestruj się za darmo.',
  },
  'deal_howto_loyalty_2': {
    'en':
        'Before fueling, open the app and activate any coupon offered for {brand} — many coupons only count once activated.',
    'de':
        'Öffne vor dem Tanken die App und aktiviere passende Coupons für {brand} – viele Coupons zählen nur nach Aktivierung.',
    'fa':
        'قبل از سوخت‌گیری اپ را باز کن و کوپن‌های مربوط به {brand} را فعال (activate) کن — خیلی از کوپن‌ها فقط بعد از فعال‌سازی حساب می‌شوند.',
    'tr':
        'Yakıt almadan önce uygulamayı aç ve {brand} için sunulan kuponları etkinleştir — birçok kupon ancak etkinleştirilince geçerli olur.',
    'ru':
        'Перед заправкой откройте приложение и активируйте купоны для {brand} — многие купоны действуют только после активации.',
    'ar':
        'قبل التزود بالوقود افتح التطبيق وفعّل أي كوبون متاح لـ {brand} — كثير من الكوبونات لا تُحتسب إلا بعد تفعيلها.',
    'uk':
        'Перед заправкою відкрийте застосунок і активуйте купони для {brand} — багато купонів діють лише після активації.',
    'ro':
        'Înainte de alimentare, deschide aplicația și activează cupoanele disponibile pentru {brand} — multe cupoane contează doar după activare.',
    'pl':
        'Przed tankowaniem otwórz aplikację i aktywuj kupony dla {brand} — wiele kuponów działa dopiero po aktywacji.',
  },
  'deal_howto_loyalty_3': {
    'en':
        'Fuel at a {brand} station and show your card or app when paying (or enter your member ID if asked) — points and discounts are applied there.',
    'de':
        'Tanke bei {brand} und zeige beim Bezahlen deine Karte oder App (oder gib deine Mitglieds-ID ein) – Punkte und Rabatte werden dort verbucht.',
    'fa':
        'در یکی از پمپ‌های {brand} سوخت بزن و موقع پرداخت کارت یا اپ را نشان بده (یا اگر خواستند شماره عضویت را وارد کن) — امتیاز و تخفیف همان‌جا اعمال می‌شود.',
    'tr':
        'Bir {brand} istasyonunda yakıt al ve öderken kartını ya da uygulamanı göster (istenirse üye numaranı gir) — puan ve indirim orada uygulanır.',
    'ru':
        'Заправьтесь на АЗС {brand} и при оплате покажите карту или приложение (или введите номер участника) — баллы и скидки начисляются там.',
    'ar':
        'تزوّد بالوقود في محطة {brand} واعرض بطاقتك أو التطبيق عند الدفع (أو أدخل رقم العضوية إن طُلب) — تُطبق النقاط والخصومات هناك.',
    'uk':
        'Заправтеся на АЗС {brand} і під час оплати покажіть картку чи застосунок (або введіть номер учасника) — бали та знижки нараховуються там.',
    'ro':
        'Alimentează la o benzinărie {brand} și arată cardul sau aplicația la plată (sau introdu ID-ul de membru) — punctele și reducerile se aplică acolo.',
    'pl':
        'Zatankuj na stacji {brand} i przy płatności pokaż kartę lub aplikację (albo podaj numer członkowski) — punkty i zniżki nalicza się tam.',
  },
  'deal_howto_payapp_1': {
    'en':
        'Install {name} from the App Store or Google Play and create an account.',
    'de':
        'Installiere {name} aus dem App Store oder Google Play und erstelle ein Konto.',
    'fa':
        '{name} را از App Store یا Google Play نصب کن و حساب بساز.',
    'tr':
        '{name} uygulamasını App Store veya Google Play’den yükle ve hesap oluştur.',
    'ru':
        'Установите {name} из App Store или Google Play и создайте аккаунт.',
    'ar':
        'ثبّت {name} من App Store أو Google Play وأنشئ حساباً.',
    'uk':
        'Встановіть {name} з App Store або Google Play і створіть акаунт.',
    'ro':
        'Instalează {name} din App Store sau Google Play și creează un cont.',
    'pl':
        'Zainstaluj {name} z App Store lub Google Play i załóż konto.',
  },
  'deal_howto_payapp_2': {
    'en':
        'Add a payment method, and look in the app for any current offer for new users before your first fill.',
    'de':
        'Hinterlege eine Zahlungsmethode und prüfe vor dem ersten Tanken, ob es in der App ein aktuelles Neukunden-Angebot gibt.',
    'fa':
        'یک روش پرداخت اضافه کن و قبل از اولین سوخت‌گیری ببین در اپ پیشنهاد فعالی برای کاربران جدید هست یا نه.',
    'tr':
        'Bir ödeme yöntemi ekle ve ilk yakıt alımından önce uygulamada yeni kullanıcılar için güncel bir teklif olup olmadığına bak.',
    'ru':
        'Добавьте способ оплаты и перед первой заправкой проверьте в приложении, есть ли сейчас акция для новых пользователей.',
    'ar':
        'أضف وسيلة دفع، وتحقق في التطبيق قبل أول تعبئة مما إذا كان هناك عرض حالي للمستخدمين الجدد.',
    'uk':
        'Додайте спосіб оплати й перед першою заправкою перевірте в застосунку, чи є зараз акція для нових користувачів.',
    'ro':
        'Adaugă o metodă de plată și verifică în aplicație, înainte de prima alimentare, dacă există o ofertă curentă pentru utilizatori noi.',
    'pl':
        'Dodaj metodę płatności i przed pierwszym tankowaniem sprawdź w aplikacji, czy jest aktualna oferta dla nowych użytkowników.',
  },
  'deal_howto_payapp_3': {
    'en':
        'At a station supported by the app, select your pump number in the app and fuel up — payment is completed in the app.',
    'de':
        'Wähle an einer von der App unterstützten Tankstelle deine Säulennummer in der App und tanke – bezahlt wird direkt in der App.',
    'fa':
        'در پمپ‌بنزینی که اپ پشتیبانی می‌کند، شماره نازل را در اپ انتخاب کن و سوخت بزن؛ پرداخت داخل خود اپ انجام می‌شود.',
    'tr':
        'Uygulamanın desteklediği bir istasyonda uygulamadan pompa numaranı seç ve yakıtını al; ödeme uygulamada tamamlanır.',
    'ru':
        'На АЗС, которую поддерживает приложение, выберите номер колонки в приложении и заправьтесь — оплата пройдёт в приложении.',
    'ar':
        'في محطة يدعمها التطبيق، اختر رقم المضخة في التطبيق وتزوّد بالوقود — يتم الدفع داخل التطبيق.',
    'uk':
        'На АЗС, яку підтримує застосунок, оберіть у ньому номер колонки й заправтеся — оплата пройде в застосунку.',
    'ro':
        'La o benzinărie acceptată de aplicație, alege numărul pompei în aplicație și alimentează — plata se face în aplicație.',
    'pl':
        'Na stacji obsługiwanej przez aplikację wybierz w niej numer dystrybutora i zatankuj — płatność odbywa się w aplikacji.',
  },
  'deal_howto_crowd_1': {
    'en':
        'Tap “Directions” to get to the station.',
    'de':
        'Tippe auf „Route“, um zur Tankstelle zu navigieren.',
    'fa':
        'روی «مسیریابی» بزن تا تا پمپ راهنمایی شوی.',
    'tr':
        'İstasyona gitmek için “Yol tarifi”ne dokun.',
    'ru':
        'Нажмите «Маршрут», чтобы доехать до АЗС.',
    'ar':
        'اضغط «الاتجاهات» للوصول إلى المحطة.',
    'uk':
        'Натисніть «Маршрут», щоб доїхати до АЗС.',
    'ro':
        'Apasă „Traseu” pentru a ajunge la benzinărie.',
    'pl':
        'Stuknij „Nawiguj”, aby dojechać na stację.',
  },
  'deal_howto_crowd_2': {
    'en':
        'Before fueling, check that the price or offer at the pump matches the deal — another driver shared it and it may have ended.',
    'de':
        'Prüfe vor dem Tanken, ob Preis oder Angebot an der Säule noch stimmt – ein anderer Fahrer hat den Deal geteilt, er kann schon vorbei sein.',
    'fa':
        'قبل از سوخت‌گیری مطمئن شو قیمت یا پیشنهاد سر پمپ با این تخفیف یکی است — این را راننده دیگری ثبت کرده و ممکن است تمام شده باشد.',
    'tr':
        'Yakıt almadan önce pompadaki fiyatın veya teklifin fırsatla aynı olduğunu kontrol et — başka bir sürücü paylaştı, sona ermiş olabilir.',
    'ru':
        'Перед заправкой убедитесь, что цена или акция на колонке совпадает — скидкой поделился другой водитель, и она могла закончиться.',
    'ar':
        'قبل التزود تأكد أن السعر أو العرض عند المضخة مطابق — شاركه سائق آخر وربما انتهى.',
    'uk':
        'Перед заправкою переконайтеся, що ціна чи акція на колонці збігається — знижкою поділився інший водій, і вона могла закінчитися.',
    'ro':
        'Înainte de alimentare, verifică dacă prețul sau oferta de la pompă corespunde — a fost distribuită de alt șofer și poate s-a încheiat.',
    'pl':
        'Przed tankowaniem sprawdź, czy cena lub oferta przy dystrybutorze się zgadza — udostępnił ją inny kierowca i mogła się już skończyć.',
  },
  'deal_howto_crowd_3': {
    'en':
        'If there is a code, copy it and show it at the checkout or enter it where the deal says.',
    'de':
        'Gibt es einen Code, kopiere ihn und zeige ihn an der Kasse oder gib ihn dort ein, wo der Deal es beschreibt.',
    'fa':
        'اگر کدی دارد، کپی‌اش کن و موقع پرداخت نشان بده یا همان‌جایی که در توضیح تخفیف آمده وارد کن.',
    'tr':
        'Bir kod varsa kopyala ve kasada göster ya da fırsatta belirtilen yere gir.',
    'ru':
        'Если есть код, скопируйте его и покажите на кассе или введите там, где указано в описании.',
    'ar':
        'إن وُجد رمز، انسخه واعرضه عند الدفع أو أدخله حيث يذكر العرض.',
    'uk':
        'Якщо є код, скопіюйте його й покажіть на касі або введіть там, де вказано в описі.',
    'ro':
        'Dacă există un cod, copiază-l și arată-l la casă sau introdu-l unde indică oferta.',
    'pl':
        'Jeśli jest kod, skopiuj go i pokaż przy kasie albo wpisz tam, gdzie wskazuje oferta.',
  },
  'deal_navigate': {
    'en':
        'Directions',
    'de':
        'Route',
    'fa':
        'مسیریابی',
    'tr':
        'Yol tarifi',
    'ru':
        'Маршрут',
    'ar':
        'الاتجاهات',
    'uk':
        'Маршрут',
    'ro':
        'Traseu',
    'pl':
        'Nawiguj',
  },
  'deal_share_pick_station': {
    'en':
        'Station from the map (for directions)',
    'de':
        'Tankstelle aus der Karte (für die Route)',
    'fa':
        'انتخاب پمپ از نقشه (برای مسیریابی)',
    'tr':
        'Haritadan istasyon (yol tarifi için)',
    'ru':
        'АЗС с карты (для маршрута)',
    'ar':
        'محطة من الخريطة (للاتجاهات)',
    'uk':
        'АЗС з мапи (для маршруту)',
    'ro':
        'Benzinărie de pe hartă (pentru traseu)',
    'pl':
        'Stacja z mapy (do nawigacji)',
  },
  'deal_share_pick_none': {
    'en':
        'Not in the list',
    'de':
        'Nicht in der Liste',
    'fa':
        'در لیست نیست',
    'tr':
        'Listede yok',
    'ru':
        'Нет в списке',
    'ar':
        'ليست في القائمة',
    'uk':
        'Немає в списку',
    'ro':
        'Nu e în listă',
    'pl':
        'Nie ma na liście',
  },
};

String currentAppLanguage() => 'fa';

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