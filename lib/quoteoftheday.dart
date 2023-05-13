import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart' as dailydata;
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NotificationService.dart';
import 'dbhelpers/QuoteHelper.dart' as quote;
import 'l10n/Localizations.dart';

import 'dart:math' as math;

import 'main.dart';

const int ID_DAILY_NOTIFICATION = 1;

class QuoteOfTheDay extends StatefulWidget {
  @override
  State<QuoteOfTheDay> createState() => _QuoteOfTheDayState();
}

class _QuoteOfTheDayState extends State<QuoteOfTheDay>
    with WidgetsBindingObserver {
  late SharedPreferences _prefs;
  late DateTime _lastFetchTime;
  late quote.Quote? _quote;
  bool _isFavoriteQuote = false;
  late List<Widget> _favoriteQuoteWidgets;
  late List<quote.Quote> _favoriteQuoteList;
  late final NotificationService notificationService;
  late String _dateKey;
  GlobalKey globalKey = GlobalKey();

  void showSharePopup(String name, String content, String author) {
    if (!kIsWeb) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Dialog(
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
              child: ImageShare(name, content ?? '', author)));
    } else {
      Share.share(content ?? '');
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_dateKey != dailydata.getDateKeyFormat(DateTime.now())) {
          _dateKey = dailydata.getDateKeyFormat(DateTime.now());
        }
        DateTime nextTimeToNotify = DateTime.now().add(Duration(minutes: 5));
        //nextTimeToNotify = new DateTime(nextTimeToNotify.year, nextTimeToNotify.month, nextTimeToNotify.day, 20, 30);
        int secondsToNotify =
            nextTimeToNotify.difference(DateTime.now()).inSeconds;
        notificationService.cancelSingleNotifications(ID_DAILY_NOTIFICATION);
        fetchFavoriteQuotes();
        _initPrefs();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    quote.QuoteHelper.registerFavoriteUpdateCallback(() {
      fetchFavoriteQuotes();
    });
    _dateKey = dailydata.getDateKeyFormat(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    _quote = null;
    _favoriteQuoteWidgets = <Widget>[];
    _initPrefs();
    fetchFavoriteQuotes();
    notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt('last_fetch_time') ?? 0,
    );
    _fetchDataIfNeeded();
  }

  _fetchDataIfNeeded() async {
    final now = DateTime.now();
    if (_lastFetchTime.year != now.year ||
        _lastFetchTime.month != now.month ||
        _lastFetchTime.day != now.day ||
        _prefs.getString('todays_quote') == null) {
      await fetchData();
    } else {
      quote.Quote q = await quote.QuoteHelper.getQuoteForKey(_prefs.getString('todays_quote')?? '');
      setState(() {
        _quote = q;
      });
    }
  }

  fetchData() async {
    _lastFetchTime = DateTime.now();
    await _prefs.setInt('last_fetch_time', _lastFetchTime.millisecondsSinceEpoch);
    quote.Quote q = await quote.QuoteHelper.getNewQuote();
    setState(() {
      _quote = q;
    });
    await _prefs.setString('todays_quote', q.name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    L10n.of(context).resource('quoteoftheday'),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  _quote != null
                      ? GestureDetector(
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (details.velocity.pixelsPerSecond.dx.abs() >
                                details.velocity.pixelsPerSecond.dy.abs()) {
                              if (details.primaryVelocity! > 0) {
                                // User swiped Left
                              } else if (details.primaryVelocity! < 0) {
                                // User swiped Right
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  RepaintBoundary(
                                      key: globalKey,
                                      child: Container(
                                        width: math.min(300,
                                            MediaQuery.of(context).size.width),
                                        color:
                                            commonBG,
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(_quote?.content ?? "",
                                                style: TextStyle(
                                                    fontFamily:
                                                        GoogleFonts.caveat()
                                                            .fontFamily,
                                                    color:
                                                        CupertinoColors.black,
                                                    fontSize: LARGE_FONTSIZE)),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[Text(_quote?.author ?? '',
                                                    style: TextStyle(
                                                        fontFamily: GoogleFonts.caveat().fontFamily,
                                                        color: CupertinoColors.black,
                                                        fontSize: MEDIUM_FONTSIZE))])
                                          ],
                                        ),
                                      )),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        CupertinoButton(
                                          onPressed: () => {showSharePopup(_quote?.name ?? '', _quote?.content ?? '', _quote?.author?? '')},
                                          child: Icon(CupertinoIcons.share),
                                        ),
                                        CupertinoButton(
                                          onPressed: toggleFavoriteQuote,
                                          child: _isFavoriteQuote
                                              ? Icon(CupertinoIcons.heart_fill)
                                              : Icon(CupertinoIcons.heart),
                                        )
                                      ]),
                                ]),
                          ))
                      : SizedBox.shrink(),
                  Text(
                    L10n.of(context).resource('favorites'),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Container(
                      child: Column(
                    key: UniqueKey(),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _favoriteQuoteWidgets,
                  ))
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> toggleFavoriteQuote() async {
    await quote.QuoteHelper.toggleFavoriteQuote(_quote?.name ?? "");
    fetchFavoriteQuotes();
  }

  Future<void> fetchFavoriteQuotes() async {
    _favoriteQuoteList = await quote.QuoteHelper.getFavoriteQuotes();
    _favoriteQuoteWidgets = <Widget>[];
    _favoriteQuoteWidgets.clear();
    for (quote.Quote q in _favoriteQuoteList.reversed) {
      _favoriteQuoteWidgets
          .add(new DecoratedText(q.name, q.content, q.author, showSharePopup));
    }
    setState(() {
      _isFavoriteQuote = isFavoriteQuote(_quote?.name ?? '');
    });
  }

  bool isFavoriteQuote(String name) {
    bool result = false;
    for (quote.Quote q in _favoriteQuoteList) {
      result = result || q.name == name;
    }
    return result;
  }
}
