import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _isNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? false;
    setState(() {
      _isNotificationsEnabled = isNotificationsEnabled;
    });
  }

  void _toggleNotificationSettings(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationsEnabled', value);
    setState(() {
      _isNotificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Notifications'),
      value: _isNotificationsEnabled,
      onChanged: (value) {
        _toggleNotificationSettings(value);
      },
    );
  }
}
