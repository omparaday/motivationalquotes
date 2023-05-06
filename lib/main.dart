import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:motivational_quotes/quoteoftheday.dart';
import 'package:motivational_quotes/l10n/Localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/settingspage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
        scaffoldBackgroundColor: commonBG,
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
  late int _currentIndex;
  bool _showWelcome = false, _showAppDownload = false;
  int _welcomeIndex = 1;

  @override
  void initState() {
    _currentIndex = 0;
    checkAndShowWelcomeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: commonBG,
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
                      scaffoldBackgroundColor: commonBG,
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
                          SettingsPage(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
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
      if (_showWelcome == false) {
        _showAppDownload = prefs.getBool('SHOW_APP_DOWNLOAD') ?? true;
      }
    });
  }

  Future<void> finishWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('SHOW_WELCOME', false);
      _showWelcome = false;
      _showAppDownload = true;
      _currentIndex = 0;
    });
  }

  Future<void> finishShowAppDownload() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('SHOW_APP_DOWNLOAD', false);
      _showWelcome = false;
      _showAppDownload = false;
      _currentIndex = 0;
    });
  }
}
