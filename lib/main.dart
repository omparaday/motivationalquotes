import 'package:flutter/cupertino.dart';
import 'package:motivational_quotes/quoteoftheday.dart';
import 'package:motivational_quotes/l10n/Localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/settingspage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'listpage.dart';

const double VERYSMALL_FONTSIZE = 14;
const double SMALL_FONTSIZE = 16;
const double FONTSIZE = 18;
const double MEDIUM_FONTSIZE = 20;
const double LARGE_FONTSIZE = 28;
const Color commonBG = Color.fromARGB(255, 250, 240, 230);

void main() {
  runApp(new CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
          scaffoldBackgroundColor: commonBG.withOpacity(0.0),
          textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
            fontFamily: GoogleFonts.nunito().fontFamily,
            color: CupertinoColors.black,
          ))),
      localizationsDelegates: const [
        L10nDelegate(),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('ta', ''),
      ],
      home: new Main()));
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  SharedPreferences? sharedPreferences;
  late int _currentIndex;
  bool _showWelcome = false;
  int _welcomeIndex = 1;
  Color bgColor = DEFAULT_OVERALL_BG_COLOR;
  String bgImage = DEFAULT_OVERALL_BG_IMAGE;
  bool useImgBg = DEFAULT_OVERALL_USE_IMG_BG;

  @override
  void initState() {
    _currentIndex = 0;
    checkAndShowWelcomeScreen();
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Color usedColor = Color(
        sp.getInt(KEY_OVERALL_BG_COLOR) ?? DEFAULT_OVERALL_BG_COLOR.value);
    String usedImage =
        sp.getString(KEY_OVERALL_BG_IMAGE) ?? DEFAULT_OVERALL_BG_IMAGE;
    bool prevusedImgBg =
        sp.getBool(KEY_OVERALL_USE_IMAGE_BG) ?? DEFAULT_OVERALL_USE_IMG_BG;
    setState(() {
      sharedPreferences = sp;
      bgColor = usedColor;
      bgImage = usedImage;
      useImgBg = prevusedImgBg;
    });
  }

  void onColorSelected(Color color) {
    setState(() {
      bgColor = color;
    });
  }

  void onImageSelected(String image) {
    setState(() {
      bgImage = image;
    });
    print(bgImage);
  }

  void onUseImageChanged(bool value) {
    setState(() {
      useImgBg = value;
    });
  }

  Text getWelcomeText() {
    var textStyle = TextStyle(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        color: CupertinoColors.white);
    switch (_welcomeIndex) {
      case 1:
        return Text(
          L10n.of(context).resource('welcome'),
          style: textStyle,
        );
      case 2:
        return Text(L10n.of(context).resource('todayWelcome'),
            style: textStyle);
      case 3:
        return Text(L10n.of(context).resource('allQuotesWelcome'),
            style: textStyle);
      case 4:
        return Text(L10n.of(context).resource('settingsWelcome'),
            style: textStyle);
    }
    return Text(L10n.of(context).resource('getStarted'), style: textStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(
        child: Container(
          color: CupertinoColors.white,
        ),
      ),
      Positioned.fill(
        child: Image(
          image: AssetImage(bgImage),
          opacity: const AlwaysStoppedAnimation(0.2),
          fit: BoxFit.fill,
        ),
      ),
      CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: bgColor.withOpacity(0.4),
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: L10n.of(context).resource('quoteoftheday'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.list_bullet),
                label: L10n.of(context).resource('list'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: L10n.of(context).resource('settings'),
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return CupertinoTabView(
              builder: (BuildContext context) {
                return SafeArea(
                    child: CupertinoApp(
                  debugShowCheckedModeBanner: false,
                  theme: CupertinoThemeData(
                      scaffoldBackgroundColor:
                          useImgBg ? bgColor.withOpacity(0.0) : bgColor,
                      textTheme: CupertinoTextThemeData(
                          textStyle: TextStyle(
                              fontSize: FONTSIZE,
                              fontFamily: GoogleFonts.nunito().fontFamily,
                              color: CupertinoColors.black))),
                  localizationsDelegates: const [
                    L10nDelegate(),
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('en', ''),
                  ],
                  home: CupertinoPageScaffold(
                    resizeToAvoidBottomInset: false,
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        QuoteOfTheDay(),
                        AllQuotesPage(),
                        SettingsPage(
                          onColorSelected: onColorSelected,
                          onImageSelected: onImageSelected,
                          onUseImageChanged: onUseImageChanged,
                        ),
                      ],
                    ),
                  ),
                ));
              },
            );
          }),
      _showWelcome
          ? SizedBox.expand(
              child: CupertinoApp(
                  theme: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                          textStyle: TextStyle(
                    fontFamily: GoogleFonts.nunito().fontFamily,
                    color: CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.black,
                      darkColor: CupertinoColors.white,
                    ),
                  ))),
                  home: Container(
                      padding: const EdgeInsets.only(
                          top: 20, left: 20.0, bottom: 100.0, right: 20.0),
                      decoration: BoxDecoration(
                          color: CupertinoDynamicColor.withBrightness(
                        color: Color.fromARGB(100, 60, 60, 60),
                        darkColor: Color.fromARGB(100, 255, 255, 255),
                      )),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Spacer(),
                            Container(
                                padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 20.0,
                                    bottom: 20.0,
                                    right: 20.0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    color: CupertinoDynamicColor.withBrightness(
                                      color: Color.fromARGB(230, 60, 60, 60),
                                      darkColor:
                                          Color.fromARGB(230, 255, 255, 255),
                                    )),
                                child: Column(children: <Widget>[
                                  Row(children: <Widget>[
                                    CupertinoButton(
                                        child: Text(
                                          L10n.of(context).resource('prev'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: _welcomeIndex == 1
                                            ? null
                                            : previousWelcomeScreen),
                                    Spacer(),
                                    CupertinoButton(
                                        child: Text(
                                          _welcomeIndex == 5
                                              ? L10n.of(context)
                                                  .resource('close')
                                              : L10n.of(context)
                                                  .resource('next'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: nextWelcomeScreen)
                                  ]),
                                  getWelcomeText(),
                                ])),
                            (_welcomeIndex <= 4 && _welcomeIndex >= 2)
                                ? Container(child: getArrowWidget())
                                : SizedBox.shrink()
                          ]))))
          : SizedBox.shrink(),
    ]);
  }

  Widget getArrowWidget() {
    switch (_welcomeIndex) {
      case 2:
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(CupertinoIcons.arrow_down),
              SizedBox(
                width: 60,
                height: 10,
              ),
              SizedBox(
                width: 60,
                height: 10,
              )
            ]);
      case 3:
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                width: 60,
                height: 10,
              ),
              Icon(CupertinoIcons.arrow_down),
              SizedBox(
                width: 60,
                height: 10,
              )
            ]);
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            width: 60,
            height: 10,
          ),
          SizedBox(
            width: 60,
            height: 10,
          ),
          Icon(CupertinoIcons.arrow_down)
        ]);
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void nextWelcomeScreen() {
    if (_welcomeIndex == 5) {
      finishWelcome();
    } else {
      setState(() {
        _welcomeIndex++;
        if (_welcomeIndex < 5 && _welcomeIndex > 1) {
          _currentIndex = _welcomeIndex - 2;
        } else {
          _currentIndex = 0;
        }
      });
    }
  }

  void previousWelcomeScreen() {
    setState(() {
      _welcomeIndex--;
      if (_welcomeIndex < 5 && _welcomeIndex > 1) {
        _currentIndex = _welcomeIndex - 2;
      } else {
        _currentIndex = 0;
      }
    });
  }

  Future<void> checkAndShowWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showWelcome = prefs.getBool('SHOW_WELCOME') ?? true;
    });
  }

  Future<void> finishWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('SHOW_WELCOME', false);
      _showWelcome = false;
      _currentIndex = 0;
    });
  }

  Future<void> finishShowAppDownload() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('SHOW_APP_DOWNLOAD', false);
      _showWelcome = false;
      _currentIndex = 0;
    });
  }
}
