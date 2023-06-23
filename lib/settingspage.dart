import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/Localizations.dart';

const bool DEFAULT_NOTIFICATION_ENABLED = true;
const String KEY_NOTIFICATION_SETTINGS = 'isNotificationsEnabled';
const String KEY_OVERALL_USE_IMAGE_BG = 'overallUseImgBg';
const String KEY_OVERALL_BG_COLOR = 'overallBgColor';
const String KEY_OVERALL_BG_IMAGE = 'overallBgImage';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationsEnabled =
        prefs.getBool(KEY_NOTIFICATION_SETTINGS) ?? true;
    setState(() {
      _isNotificationsEnabled = isNotificationsEnabled;
    });
  }

  void _toggleNotificationSettings(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_NOTIFICATION_SETTINGS, value);
    setState(() {
      _isNotificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: SingleChildScrollView(
            child: SafeArea(
                child: Row(children: <Widget>[
          Text(L10n.of(context).resource('notifications'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Spacer(),
          CupertinoSwitch(
            value: _isNotificationsEnabled,
            onChanged: (value) {
              _toggleNotificationSettings(value);
            },
          )
        ]))));
  }
}
