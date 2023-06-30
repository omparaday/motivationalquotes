import 'package:flutter/cupertino.dart';
import 'package:motivational_quotes/main.dart';
import 'package:motivational_quotes/widgets/BGImagePickerWidget.dart';
import 'package:motivational_quotes/widgets/ColorPickerWidget.dart';
import 'package:motivational_quotes/widgets/RounderSegmentControl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/Localizations.dart';

const bool DEFAULT_NOTIFICATION_ENABLED = true;
const String KEY_NOTIFICATION_SETTINGS = 'isNotificationsEnabled';
const String KEY_OVERALL_USE_IMAGE_BG = 'overallUseImgBg';
const String KEY_OVERALL_BG_COLOR = 'overallBgColor';
const String KEY_OVERALL_BG_IMAGE = 'overallBgImage';

const Color DEFAULT_OVERALL_BG_COLOR = commonBG;
const String DEFAULT_OVERALL_BG_IMAGE = 'assets/bgarts/1.png';
const bool DEFAULT_OVERALL_USE_IMG_BG = true;

class SettingsPage extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Function(String) onImageSelected;
  final Function(bool) onUseImageChanged;

  const SettingsPage({Key? key, required this.onColorSelected, required this.onImageSelected, required this.onUseImageChanged}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationsEnabled = false;
  late SharedPreferences sharedPreferences;
  Color bgColor = DEFAULT_OVERALL_BG_COLOR;
  String bgImage = DEFAULT_OVERALL_BG_IMAGE;
  bool useImgBg = DEFAULT_OVERALL_USE_IMG_BG;

  List<Color> bgColorList = [
    DEFAULT_OVERALL_BG_COLOR,
    Color.fromARGB(255, 224, 224, 224),
    Color.fromARGB(255, 250, 218, 221),
    Color.fromARGB(255, 209, 231, 249),
    Color.fromARGB(255, 176, 230, 189),
    Color.fromARGB(255, 255, 246, 191),
    Color.fromARGB(255, 215, 190, 230),
    Color.fromARGB(255, 255, 211, 182),
    Color.fromARGB(255, 244, 245, 226)
  ];
  List<String> bgImages = [
    'assets/bgarts/1.png',
    'assets/bgarts/2.png',
    'assets/bgarts/3.png',
    'assets/bgarts/4.png',
    'assets/bgarts/5.png',
    'assets/bgarts/6.png',
    'assets/bgarts/7.png',
    'assets/bgarts/8.png',
    'assets/bgarts/9.png'
  ];

  changeColor(Color selectedColor) async {
    await sharedPreferences.setInt(KEY_OVERALL_BG_COLOR, selectedColor.value);
    setState(() {
      bgColor = selectedColor;
    });
    widget.onColorSelected(selectedColor);
  }

  changeImage(String selectedImage) async {
    await sharedPreferences.setString(KEY_OVERALL_BG_IMAGE, selectedImage);
    setState(() {
      bgImage = selectedImage;
    });
    print(selectedImage);
    widget.onImageSelected(selectedImage);
  }

  @override
  void initState() {
    super.initState();
    updateLastSettings();
  }

  void _loadNotificationSettings() async {
    bool isNotificationsEnabled =
        sharedPreferences.getBool(KEY_NOTIFICATION_SETTINGS) ?? true;
    setState(() {
      _isNotificationsEnabled = isNotificationsEnabled;
    });
  }

  void _toggleNotificationSettings(bool value) async {
    await sharedPreferences.setBool(KEY_NOTIFICATION_SETTINGS, value);
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
                child: Column(children: <Widget>[
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(L10n.of(context).resource('notifications'),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10,),
                      CupertinoSwitch(
                        value: _isNotificationsEnabled,
                        onChanged: (value) {
                          _toggleNotificationSettings(value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(L10n.of(context).resource('theme'),
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                  RoundedSegmentControl<bool>(
                    groupValue: useImgBg,
                    onValueChanged: (bool value) {
                      setState(() {
                        useImgBg = value;
                        sharedPreferences.setBool(
                            KEY_OVERALL_USE_IMAGE_BG, useImgBg);
                        widget.onUseImageChanged(value);
                      });
                    },
                    children: <bool, String>{
                      true: L10n.of(context).resource('art'),
                      false: L10n.of(context).resource('color'),
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  useImgBg
                      ? SizedBox.shrink()
                      : ColorPickerRow(
                      colorList: bgColorList,
                      onColorSelected: changeColor,
                      initialIndex: bgColorList.indexOf(bgColor), iconSize: 75,),
                  useImgBg
                      ? ImagePickerRow(
                      assetList: bgImages,
                      onImageSelected: changeImage,
                      initialIndex: bgImages.indexOf(bgImage), iconSize: 75,)
                      : SizedBox.shrink(),
                ]))));
  }

  Future<void> updateLastSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _loadNotificationSettings();
    Color usedColor =
    Color(sharedPreferences.getInt(KEY_OVERALL_BG_COLOR) ??
        DEFAULT_OVERALL_BG_COLOR.value);
    String usedImage = sharedPreferences.getString(KEY_OVERALL_BG_IMAGE) ??
        DEFAULT_OVERALL_BG_IMAGE;
    bool prevusedImgBg = sharedPreferences.getBool(KEY_OVERALL_USE_IMAGE_BG) ??
        DEFAULT_OVERALL_USE_IMG_BG;
    if (bgColor != usedColor ||
        bgImage != usedImage ||
        useImgBg != prevusedImgBg) {
      setState(() {
        bgColor = usedColor;
        bgImage = usedImage;
        useImgBg = prevusedImgBg;
      });
    }
  }
}
