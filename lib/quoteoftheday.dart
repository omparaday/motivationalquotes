import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart' as dailydata;
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:share_plus/share_plus.dart';

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
class _QuoteOfTheDayState extends State<QuoteOfTheDay> with WidgetsBindingObserver {
  late quote.Quote? _quote;
  late bool _isFavoriteQuote;
  late List<Widget> _favoriteQuoteWidgets;
  late List<quote.Quote> _favoriteQuoteList;
  late final NotificationService notificationService;
  late String _dateKey;
  GlobalKey globalKey = GlobalKey();

  void showSharePopup(String name, String content) {
    if (!kIsWeb) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Dialog(
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
              child: ImageShare(name, content ?? '')));
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
        int secondsToNotify = nextTimeToNotify.difference(DateTime.now()).inSeconds;
        notificationService.cancelSingleNotifications(ID_DAILY_NOTIFICATION);
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
    _dateKey = dailydata.getDateKeyFormat(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    Timer.periodic(Duration(hours: 1), (timer) async {
      if (_dateKey != dailydata.getDateKeyFormat(DateTime.now())) {
        _dateKey = dailydata.getDateKeyFormat(DateTime.now());
        startFlow();
      }
    });
    _quote = null;
    _favoriteQuoteWidgets = <Widget>[];
    startFlow();
    fetchFavoriteQuotes();
    notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
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
                  _quote != null ? GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) {
                        print(details.primaryVelocity);
                        print('pps' + details.velocity.pixelsPerSecond.toString());
                        if (details.velocity.pixelsPerSecond.dx.abs() > details.velocity.pixelsPerSecond.dy.abs()) {
                          if (details.primaryVelocity! > 0) {
                            // User swiped Left
                            print('left');
                          } else if (details.primaryVelocity! < 0) {
                            // User swiped Right
                            print('right');
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          RepaintBoundary(
                              key: globalKey,
                              child: Container(
                                width: math.min(300, MediaQuery.of(context).size.width),
                                color: Color.fromARGB(255, 250, 224, 190),
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
                                            fontFamily: GoogleFonts.caveat().fontFamily,
                                            color: CupertinoColors.black,
                                            fontSize: VERYSMALL_FONTSIZE),
                                      )
                                    ]),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(_quote?.content ?? "",
                                        style: TextStyle(
                                            fontFamily: GoogleFonts.caveat().fontFamily,
                                            color: CupertinoColors.black,
                                            fontSize: LARGE_FONTSIZE))
                                  ],
                                ),
                              )),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CupertinoButton(
                                  onPressed: null,
                                  child: Icon(CupertinoIcons.share),
                                ),
                                CupertinoButton(
                                  onPressed: toggleFavoriteQuote,
                                  child: _isFavoriteQuote ? Icon(CupertinoIcons.heart_fill) : Icon(CupertinoIcons.heart),
                                )
                              ]),
                        ]),
                      )) : SizedBox.shrink(),
                  Text(
                    L10n.of(context).resource('favorites'),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Container(
                      child: Column(
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
    await quote.toggleFavoriteQuote(_quote?.name ?? "");
    fetchFavoriteQuotes();
  }

  Future<void> fetchFavoriteQuotes() async {
    _favoriteQuoteList = await quote.getFavoriteQuotes();
    _favoriteQuoteWidgets = <Widget>[];
    setState(() {
      for(quote.Quote q in _favoriteQuoteList.reversed) {
        _favoriteQuoteWidgets.add(DecoratedText(q.name, q.content, showSharePopup));
      }
      _isFavoriteQuote = isFavoriteQuote(_quote?.name?? '');
    });
  }

  bool isFavoriteQuote(String name) {
    bool result = false;
    for (quote.Quote q in _favoriteQuoteList) {
      result = result || q.name == name;
    }
    return result;
  }

  startFlow() async {
    quote.Quote q = await quote.getNewQuote();
    setState(() {
    _quote = q;});
  }

}