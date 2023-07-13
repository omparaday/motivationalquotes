import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/main.dart';
import 'package:motivational_quotes/settingspage.dart';
import 'package:motivational_quotes/widgets/BGImagePickerWidget.dart';
import 'package:motivational_quotes/widgets/FontPickerRow.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/Localizations.dart';
import 'ColorPickerWidget.dart';
import 'RounderSegmentControl.dart';

const String KEY_SHARE_FONT = 'shareFont';
const String KEY_USE_IMAGE_BG = 'shareUseImgBg';
const String KEY_BG_COLOR = 'shareBgColor';
const String KEY_BG_IMAGE = 'shareBgImage';

class ImageShare extends StatefulWidget {
  final String text, author;

  const ImageShare(String this.text, String this.author);

  @override
  ImageShareState createState() => ImageShareState(text, author);
}

const Color DEFAULT_BG_COLOR = Color.fromARGB(255, 224, 224, 224);
const String DEFAULT_BG_IMAGE = 'assets/bgarts/1.png';
const bool DEFAULT_USE_IMG_BG = true;

class ImageShareState extends State<ImageShare> {
  String text, author;
  bool isEditing = false, textFocussed = false;
  double preferredFontSize = LARGE_FONTSIZE;
  late TextEditingController writeTextController;

  ImageShareState(String this.text, String this.author) {
    if (text.isEmpty) {
      isEditing = true;
    }
  }

  GlobalKey globalKey = GlobalKey();
  late Uint8List pngBytes;
  bool captured = false;
  Color bgColor = DEFAULT_BG_COLOR;
  Color overallBgColor = DEFAULT_OVERALL_BG_COLOR;
  String bgImage = DEFAULT_BG_IMAGE;
  bool useImgBg = DEFAULT_USE_IMG_BG;
  String? font = GoogleFonts.caveat().fontFamily;

  late SharedPreferences sharedPrefs;

  List<Color> bgColorList = [
    DEFAULT_BG_COLOR,
    Color.fromARGB(255, 250, 218, 221),
    Color.fromARGB(255, 209, 231, 249),
    Color.fromARGB(255, 176, 230, 189),
    Color.fromARGB(255, 255, 246, 191),
    Color.fromARGB(255, 215, 190, 230),
    Color.fromARGB(255, 255, 211, 182),
    Color.fromARGB(255, 244, 245, 226)
  ];
  List<String> bgImages = [
    DEFAULT_BG_IMAGE,
    'assets/bgarts/2.png',
    'assets/bgarts/3.png',
    'assets/bgarts/4.png',
    'assets/bgarts/5.png',
    'assets/bgarts/6.png',
    'assets/bgarts/7.png',
    'assets/bgarts/8.png',
    'assets/bgarts/9.png'
  ];
  List<String?> fontList = [
    GoogleFonts.caveat().fontFamily,
    GoogleFonts.kalam().fontFamily,
    GoogleFonts.dancingScript().fontFamily,
    GoogleFonts.shadowsIntoLight().fontFamily
  ];

  changeColor(Color selectedColor) async {
    sharedPrefs.setInt(KEY_BG_COLOR, selectedColor.value);
    setState(() {
      bgColor = selectedColor;
    });
  }

  changeImage(String selectedImage) async {
    sharedPrefs.setString(KEY_BG_IMAGE, selectedImage);
    setState(() {
      bgImage = selectedImage;
    });
  }

  changeFont(String selectedFont) async {
    sharedPrefs.setString(KEY_SHARE_FONT, selectedFont);
    setState(() {
      font = selectedFont;
    });
  }

  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
    globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 4.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    setState(() {
      pngBytes = byteData!.buffer.asUint8List();
      captured = true;
    });
  }

  Future<void> shareImage() async {
    await _capturePng();
    final box = context.findRenderObject() as RenderBox?;
    Share.shareXFiles([XFile.fromData(pngBytes, mimeType: 'image/png')],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    writeTextController = TextEditingController();
    updateLastSettings();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              color: overallBgColor),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            RepaintBoundary(
                key: globalKey,
                child: Container(
                  color: !useImgBg ? bgColor : null,
                  decoration: useImgBg
                      ? BoxDecoration(
                    color: CupertinoColors.white,
                    image: DecorationImage(
                        image: AssetImage(bgImage),
                        fit: BoxFit.cover,
                        opacity: 0.4),
                  )
                      : null,
                  padding: EdgeInsets.all(10),
                  child: isEditing
                      ? Focus(
                      onFocusChange: (focus) => setState(() {
                        textFocussed = focus;
                      }),
                      child: CupertinoTextField(
                        autofocus: true,
                        keyboardType: TextInputType.multiline,
                        controller: writeTextController,
                        maxLines: null,
                        decoration: null,
                        placeholderStyle: TextStyle(
                            shadows: useImgBg
                                ? <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: CupertinoColors.secondaryLabel,
                              )
                            ]
                                : null,
                            fontFamily: font,
                            color: CupertinoColors.systemGrey,
                            fontSize: preferredFontSize),
                        style: TextStyle(
                            shadows: useImgBg
                                ? <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: CupertinoColors.secondaryLabel,
                              )
                            ]
                                : null,
                            fontFamily: font,
                            color: CupertinoColors.black,
                            fontSize: preferredFontSize),
                        suffix: textFocussed
                            ? CupertinoButton(
                          child:
                          new Icon(CupertinoIcons.checkmark_circle),
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        )
                            : SizedBox.shrink(),
                        placeholder:
                        L10n.of(context).resource('enterTextMessage'),
                      ))
                      : Column(
                    children: <Widget>[
                      Text(text,
                          style: TextStyle(
                              shadows: useImgBg
                                  ? <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: CupertinoColors.secondaryLabel,
                                )
                              ]
                                  : null,
                              fontFamily: font,
                              color: CupertinoColors.black,
                              fontSize: preferredFontSize)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Flexible(
                                child: Text(author,
                                style: TextStyle(
                                    shadows: useImgBg
                                        ? <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: CupertinoColors
                                            .secondaryLabel,
                                      )
                                    ]
                                        : null,
                                    fontFamily: font,
                                    color: CupertinoColors.black,
                                    fontSize: preferredFontSize*0.8)))
                          ]),
                    ],
                  ),
                )),
            SizedBox(
              height: 10,
            ),
            RoundedSegmentControl<bool>(
              groupValue: useImgBg,
              onValueChanged: (bool value) {
                setState(() {
                  useImgBg = value;
                  sharedPrefs.setBool(KEY_USE_IMAGE_BG, useImgBg);
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
                initialIndex: bgColorList.indexOf(bgColor)),
            useImgBg
                ? ImagePickerRow(
                assetList: bgImages,
                onImageSelected: changeImage,
                initialIndex: bgImages.indexOf(bgImage))
                : SizedBox.shrink(),
            FontPickerRow(
              fontList: fontList,
              onFontSelected: changeFont,
              initialIndex: fontList.indexOf(font),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              CupertinoButton(
                onPressed: preferredFontSize == 9
                    ? null
                    : () {
                  setState(() {
                    preferredFontSize--;
                  });
                },
                child: Text(
                  'Aa',
                  style: TextStyle(
                      color: preferredFontSize == 9
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.activeBlue,
                      fontSize: VERYSMALL_FONTSIZE),
                ),
              ),
              CupertinoButton(
                onPressed: preferredFontSize == 34
                    ? null
                    : () {
                  setState(() {
                    preferredFontSize++;
                  });
                },
                child: Text(
                  'Aa',
                  style: TextStyle(
                      color: preferredFontSize == 34
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.activeBlue,
                      fontSize: MEDIUM_FONTSIZE),
                ),
              ),
              CupertinoButton(
                onPressed: textFocussed ? null : () {
                  captured = false;
                  shareImage();},
                child: Icon(
                  CupertinoIcons.share,
                  color: textFocussed
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.activeBlue,
                ),
              )
            ]),
          ]),
        ));
  }

  Future<void> updateLastSettings() async {
    sharedPrefs = await SharedPreferences.getInstance();
    overallBgColor = Color(sharedPrefs.getInt(KEY_OVERALL_BG_COLOR) ??
        DEFAULT_OVERALL_BG_COLOR.value);
    Color usedColor =
    Color(sharedPrefs.getInt(KEY_BG_COLOR) ?? DEFAULT_BG_COLOR.value);
    String usedImage = sharedPrefs.getString(KEY_BG_IMAGE) ?? DEFAULT_BG_IMAGE;
    String? usedFont = sharedPrefs.getString(KEY_SHARE_FONT) ??
        GoogleFonts.caveat().fontFamily;
    bool prevusedImgBg =
        sharedPrefs.getBool(KEY_USE_IMAGE_BG) ?? DEFAULT_USE_IMG_BG;
    if (bgColor != usedColor ||
        bgImage != usedImage ||
        font != usedFont ||
        useImgBg != prevusedImgBg) {
      setState(() {
        bgColor = usedColor;
        bgImage = usedImage;
        font = usedFont;
        useImgBg = prevusedImgBg;
      });
    }
  }
}
