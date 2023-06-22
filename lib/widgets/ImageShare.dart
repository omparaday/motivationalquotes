import 'dart:typed_data';
import 'package:motivational_quotes/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/widgets/BGImagePickerWidget.dart';
import 'package:motivational_quotes/widgets/FontPickerRow.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'ColorPickerWidget.dart';

class ImageShare extends StatefulWidget {
  final String name, text, author;
  const ImageShare(String this.name, String this.text, String this.author);

  @override
  ImageShareState createState() => ImageShareState(name, text, author);
}
const Color DEFAULT_BG_COLOR = Color.fromARGB(255,224,224,224);
const String DEFAULT_BG_IMAGE =  'assets/bgarts/1.png';
const bool DEFAULT_USE_IMG_BG = true;
class ImageShareState extends State<ImageShare> {
  String name, text, author;

  ImageShareState(String this.name, String this.text, String this.author);

  GlobalKey globalKey = GlobalKey();
  late Uint8List pngBytes;
  bool clicked = false;
  Color bgColor = DEFAULT_BG_COLOR;
  String bgImage = DEFAULT_BG_IMAGE;
  bool useImgBg = DEFAULT_USE_IMG_BG;
  String? font = GoogleFonts.caveat().fontFamily;
  List<Color> bgColorList = [DEFAULT_BG_COLOR,Color.fromARGB(255,250,218,221),Color.fromARGB(255,209,231,249),Color.fromARGB(255,176,230,189),Color.fromARGB(255,255,246,191),
    Color.fromARGB(255,215,190,230),Color.fromARGB(255,255,211,182),Color.fromARGB(255,244,245,226)];
  List<String> bgImages = [
    DEFAULT_BG_IMAGE,'assets/bgarts/2.png','assets/bgarts/3.png','assets/bgarts/4.png','assets/bgarts/5.png','assets/bgarts/6.png','assets/bgarts/7.png','assets/bgarts/8.png','assets/bgarts/9.png'];
  List<String?> fontList = [GoogleFonts.caveat().fontFamily, GoogleFonts.kalam().fontFamily, GoogleFonts.dancingScript().fontFamily, GoogleFonts.shadowsIntoLight().fontFamily];
  changeColor(Color selectedColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('bgColor', selectedColor.value);
    setState(() {
      bgColor = selectedColor;
    });
  }
  changeImage(String selectedImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('bgImage', selectedImage);
    setState(() {
      bgImage = selectedImage;
    });
  }
  changeFont(String selectedFont) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('shareFont', selectedFont);
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
      clicked = true;
    });
  }

  Future<void> shareImage() async {
    if (!clicked) {
      await _capturePng();
    }
    final box = context.findRenderObject() as RenderBox?;
    Share.shareXFiles([XFile.fromData(pngBytes, mimeType: 'image/png')], sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    updateLastSettings();
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        RepaintBoundary(
            key: globalKey,
            child: Container(
              width: math.min(300, MediaQuery.of(context).size.width),
              color: !useImgBg? bgColor : null,
              decoration: useImgBg ? BoxDecoration(
                image: DecorationImage(image: AssetImage(bgImage),
                  fit: BoxFit.cover,
                  opacity: 0.4
                ),
              ) : null,
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Text(text,
                      style: TextStyle(
                          fontFamily: font,
                          fontWeight: FontWeight.w400,
                          color: CupertinoColors.black,
                          fontSize: LARGE_FONTSIZE)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[Text(author,
                          style: TextStyle(
                              fontFamily: GoogleFonts.caveat().fontFamily,
                              color: CupertinoColors.black,
                              fontSize: MEDIUM_FONTSIZE))]),
                ],
              ),
            )),
        ColorPickerRow(colorList: bgColorList, onColorSelected: changeColor,),
        ImagePickerRow(assetList: bgImages, onImageSelected: changeImage),
        FontPickerRow(fontList: fontList, onFontSelected: changeFont,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoButton(
                onPressed: shareImage,
                child: Icon(CupertinoIcons.share),
              )
            ]),
      ]),
    );
  }

  Future<void> updateLastSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Color usedColor = Color(prefs.getInt('bgColor') ?? DEFAULT_BG_COLOR.value);
    String usedImage = prefs.getString('bgImage')?? DEFAULT_BG_IMAGE;
    String? usedFont = prefs.getString('shareFont')?? GoogleFonts.caveat().fontFamily;
    bool prevusedImgBg = prefs.getBool('useImgBg') ?? DEFAULT_USE_IMG_BG;
    if (bgColor != usedColor || bgImage != usedImage || font != usedFont || useImgBg != prevusedImgBg) {
      setState(() {
        bgColor = usedColor;
        bgImage = usedImage;
        font = usedFont;
        useImgBg = prevusedImgBg;
      });
    }
  }
}
