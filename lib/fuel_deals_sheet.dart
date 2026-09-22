import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fuel_deals_service.dart';
import 'translations.dart';

/// Bottom sheet: loyalty coupons, pay-at-pump referrals, time tip, crowd deals.
class FuelDealsSheet extends StatefulWidget {
  final String lang;
  final String countryCode;
  final double lat;
  final double lng;
  final String selectedFuel;
  final List stations;
  final double fontScale;

  const FuelDealsSheet({
    super.key,
    required this.lang,
    required this.countryCode,
    required this.lat,
    required this.lng,
    required this.selectedFuel,
    required this.stations,
    this.fontScale = 1.0,
  });

  static Future<void> open(
    BuildContext context, {
    required String lang,
    required String countryCode,
    required double lat,
    required double lng,
    required String selectedFuel,
    required List stations,
    double fontScale = 1.0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FuelDealsSheet(
        lang: lang,
        countryCode: countryCode,
        lat: lat,
        lng: lng,
        selectedFuel: selectedFuel,
        stations: stations,
        fontScale: fontScale,
      ),
    );
  }

  @override
  State<FuelDealsSheet> createState() => _FuelDealsSheetState();
}

class _FuelDealsSheetState extends State<FuelDealsSheet> {
  TimeDiscountTip? _timeTip;
  List<CrowdDeal> _crowd = [];
  bool _loading = true;

  String get _cc => widget.countryCode.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    TimeDiscountTip? tip;
    if (_cc == 'de') {
      tip = await FuelDealsService.timeTipForGermany(
        stations: widget.stations,
      );
      // Keep hour samples fresh from TankerKönig near map center.
      FuelDealsService.refreshGermanySampleNear(
        lat: widget.lat,
        lng: widget.lng,
        fuelType: widget.selectedFuel,
      );
    }
    final crowd = await FuelDealsService.fetchCrowdDeals(
      countryCode: _cc,
      lat: widget.lat,
      lng: widget.lng,
    );
    if (!mounted) return;
    setState(() {
      _timeTip = tip;
      _crowd = crowd;
      _loading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareDealDialog() async {
    final titleCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    final stationCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    var hoursValid = 6.0;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(translate('deal_share_title', widget.lang)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: translate('deal_share_title_field', widget.lang),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: detailCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: translate('deal_share_detail_field', widget.lang),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stationCtrl,
                  decoration: InputDecoration(
                    labelText:
                        translate('deal_share_station_field', widget.lang),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeCtrl,
                  decoration: InputDecoration(
                    labelText: translate('deal_share_code_field', widget.lang),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  translate(
                    'deal_share_hours',
                    widget.lang,
                    {'n': hoursValid.toStringAsFixed(0)},
                  ),
                ),
                Slider(
                  value: hoursValid,
                  min: 1,
                  max: 48,
                  divisions: 47,
                  label: hoursValid.toStringAsFixed(0),
                  onChanged: (v) => setLocal(() => hoursValid = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(translate('cancel', widget.lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(translate('deal_share_submit', widget.lang)),
            ),
          ],
        ),
      ),
    );

    final title = titleCtrl.text;
    final detail = detailCtrl.text;
    final station = stationCtrl.text;
    final code = codeCtrl.text;
    titleCtrl.dispose();
    detailCtrl.dispose();
    stationCtrl.dispose();
    codeCtrl.dispose();

    if (ok != true || !mounted) return;

    final result = await FuelDealsService.submitCrowdDeal(
      countryCode: _cc,
      title: title,
      detail: detail,
      stationHint: station,
      code: code,
      expiresAt: DateTime.now().add(Duration(hours: hoursValid.round())),
      lat: widget.lat,
      lng: widget.lng,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translate(
            result.messageKey,
            widget.lang,
            {'n': '${result.points}'},
          ),
        ),
      ),
    );
    if (result.points > 0) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final loyalty = FuelDealsService.loyaltyForCountry(_cc);
    final payApps = FuelDealsService.payAtPumpForCountry(_cc);
    final h = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: h,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F4EF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    translate('deals_title', widget.lang),
                    style: TextStyle(
                      fontSize: 18 * widget.fontScale,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (_timeTip != null) _buildTimeCard(_timeTip!),
                _sectionTitle(translate('deals_loyalty_section', widget.lang)),
                if (loyalty.isEmpty)
                  _empty(translate('deals_empty_loyalty', widget.lang))
                else
                  ...loyalty.map(_loyaltyTile),
                const SizedBox(height: 12),
                _sectionTitle(translate('deals_payapp_section', widget.lang)),
                if (payApps.isEmpty)
                  _empty(translate('deals_empty_payapp', widget.lang))
                else
                  ...payApps.map(_payAppTile),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _sectionTitle(
                        translate('deals_crowd_section', widget.lang),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _shareDealDialog,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text(translate('deal_share_btn', widget.lang)),
                    ),
                  ],
                ),
                if (_crowd.isEmpty)
                  _empty(translate('deals_empty_crowd', widget.lang))
                else
                  ..._crowd.map(_crowdTile),
                const SizedBox(height: 16),
                Text(
                  translate('deals_disclaimer', widget.lang),
                  style: TextStyle(
                    fontSize: 11 * widget.fontScale,
                    color: Colors.brown.shade400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15 * widget.fontScale,
          fontWeight: FontWeight.w700,
          color: Colors.brown.shade800,
        ),
      ),
    );
  }

  Widget _empty(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13 * widget.fontScale,
          color: Colors.brown.shade500,
        ),
      ),
    );
  }

  Widget _buildTimeCard(TimeDiscountTip tip) {
    final bg = tip.isCheapWindowNow
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF3E0);
    final icon = tip.isCheapWindowNow
        ? Icons.thumb_up_alt_outlined
        : Icons.schedule;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.brown.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate('deals_time_section', widget.lang),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14 * widget.fontScale,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translate(tip.messageKey, widget.lang, tip.params),
                  style: TextStyle(
                    fontSize: 13 * widget.fontScale,
                    height: 1.4,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loyaltyTile(LoyaltyCoupon c) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade100,
          child: Text(
            c.network.substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          translate(c.titleKey, widget.lang),
          style: TextStyle(fontSize: 14 * widget.fontScale),
        ),
        subtitle: Text(
          translate(c.detailKey, widget.lang, {
            'cents': c.approxCentsPerLitre.toStringAsFixed(1),
            if (c.brandHint != null) 'brand': c.brandHint!,
            'network': c.network,
          }),
          style: TextStyle(fontSize: 12 * widget.fontScale, height: 1.35),
        ),
        trailing: c.infoUrl == null
            ? null
            : IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                onPressed: () => _openUrl(c.infoUrl!),
              ),
      ),
    );
  }

  Widget _payAppTile(PayAtPumpOffer o) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.phone_android, color: Colors.blue),
        title: Text(o.name, style: TextStyle(fontSize: 14 * widget.fontScale)),
        subtitle: Text(
          translate(o.bonusKey, widget.lang),
          style: TextStyle(fontSize: 12 * widget.fontScale, height: 1.35),
        ),
        trailing: ElevatedButton(
          onPressed: () => _openUrl(o.url),
          child: Text(translate('deal_open', widget.lang)),
        ),
      ),
    );
  }

  Widget _crowdTile(CrowdDeal d) {
    final left = d.expiresAt.difference(DateTime.now());
    final hours = left.inHours.clamp(0, 99);
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.local_offer, color: Colors.deepOrange),
        title: Text(d.title, style: TextStyle(fontSize: 14 * widget.fontScale)),
        subtitle: Text(
          [
            if (d.detail.isNotEmpty) d.detail,
            if (d.stationHint != null && d.stationHint!.isNotEmpty)
              d.stationHint!,
            if (d.code != null && d.code!.isNotEmpty) 'Code: ${d.code}',
            translate('deal_expires_in', widget.lang, {'h': '$hours'}),
          ].join('\n'),
          style: TextStyle(fontSize: 12 * widget.fontScale, height: 1.35),
        ),
        isThreeLine: true,
        trailing: d.code == null || d.code!.isEmpty
            ? null
            : IconButton(
                tooltip: translate('deal_copy_code', widget.lang),
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: d.code!));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(translate('deal_copied', widget.lang)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
