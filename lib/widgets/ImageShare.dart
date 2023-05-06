import 'dart:typed_data';
import 'package:motivational_quotes/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/widgets/FontPickerRow.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import 'ColorPickerWidget.dart';

class ImageShare extends StatefulWidget {
  final String name, text, author;
  const ImageShare(String this.name, String this.text, String this.author);

  @override
  ImageShareState createState() => ImageShareState(name, text, author);
}

class ImageShareState extends State<ImageShare> {
  String name, text, author;

  ImageShareState(String this.name, String this.text, String this.author);

  GlobalKey globalKey = GlobalKey();
  late Uint8List pngBytes;
  bool clicked = false;
  Color bgColor = commonBG;
  String? font = GoogleFonts.caveat().fontFamily;
  List<Color> bgColorList = [commonBG,Color.fromARGB(255,250,218,221),Color.fromARGB(255,209,231,249),Color.fromARGB(255,176,230,189),Color.fromARGB(255,255,246,191),
    Color.fromARGB(255,215,190,230),Color.fromARGB(255,255,211,182),Color.fromARGB(255,224,224,224),];
  List<String?> fontList = [GoogleFonts.caveat().fontFamily, GoogleFonts.kalam().fontFamily, GoogleFonts.dancingScript().fontFamily, GoogleFonts.shadowsIntoLight().fontFamily];
  changeColor(Color selectedColor) {
    setState(() {
      bgColor = selectedColor;
    });
  }
  changeFont(String selectedFont) {
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
              color: bgColor,
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Image.asset(
                      'assets/goodnessOldPaper.png',
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'goodness.day',
                      style: TextStyle(
                          fontFamily: font,
                          color: CupertinoColors.black,
                          fontSize: VERYSMALL_FONTSIZE),
                    )
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Text(text,
                      style: TextStyle(
                          fontFamily: font,
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
}
