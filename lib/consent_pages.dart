import 'package:flutter/material.dart';
import 'translations.dart';

bool isRtlLanguage(String lang) => lang == 'fa' || lang == 'ar';

Future<bool> showLocationConsentPage(BuildContext context, String lang) {
  return _showConsentPage(
    context: context,
    lang: lang,
    icon: Icons.navigation,
    titleKey: 'consent_location_title',
    bodyKey: 'consent_location_body',
  );
}

Future<bool> showNotificationConsentPage(BuildContext context, String lang) {
  return _showConsentPage(
    context: context,
    lang: lang,
    icon: Icons.notifications_active_outlined,
    titleKey: 'consent_notification_title',
    bodyKey: 'consent_notification_body',
  );
}

Future<bool> _showConsentPage({
  required BuildContext context,
  required String lang,
  required IconData icon,
  required String titleKey,
  required String bodyKey,
}) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ConsentDisclosurePage(
        lang: lang,
        icon: icon,
        titleKey: titleKey,
        bodyKey: bodyKey,
      ),
    ),
  );
  return result == true;
}

class _ConsentDisclosurePage extends StatelessWidget {
  final String lang;
  final IconData icon;
  final String titleKey;
  final String bodyKey;

  const _ConsentDisclosurePage({
    required this.lang,
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });

  @override
  Widget build(BuildContext context) {
    final rtl = isRtlLanguage(lang);
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(translate(titleKey, lang)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(icon, size: 40, color: Colors.blue.shade700),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        translate(titleKey, lang),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        translate(bodyKey, lang),
                        style: const TextStyle(fontSize: 15, height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(translate('consent_continue', lang)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(translate('consent_not_now', lang)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
