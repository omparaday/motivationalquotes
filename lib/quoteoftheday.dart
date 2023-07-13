import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart' as dailydata;
import 'package:motivational_quotes/settingspage.dart';
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NotificationService.dart';
import 'dbhelpers/QuoteHelper.dart' as quote;
import 'l10n/Localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';

import 'dart:math' as math;

import 'main.dart';

const int ID_DAILY_NOTIFICATION = 1;
const String KEY_LAST_REVIEW_REQUESTED = 'last_review_requested';
class QuoteOfTheDay extends StatefulWidget {
  @override
  State<QuoteOfTheDay> createState() => _QuoteOfTheDayState();
}

class _QuoteOfTheDayState extends State<QuoteOfTheDay>
    with WidgetsBindingObserver {
  late quote.Quote? _quote;
  bool _isFavoriteQuote = false;
  late List<Widget> _favoriteQuoteWidgets;
  late List<quote.Quote> _favoriteQuoteList;
  late final NotificationService notificationService;
  late String _dateKey;
  GlobalKey globalKey = GlobalKey();
  InterstitialAd? _interstitialAd;
  int counter = 0;

  // Testing
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

/*
  // Production
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8924486974511569/1126645458'
      : 'ca-app-pub-8924486974511569/2631298817';
 */

  /// Loads an interstitial ad.
  void _loadAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void showSharePopup(String content, String author) {
    if (!kIsWeb) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Dialog(
              backgroundColor:
              CupertinoTheme.of(context).scaffoldBackgroundColor,
              child: ImageShare(content ?? '', author))).then((value) {
        counter++;
        if (counter == 3) {
          _loadAd();
        }
        if (_dateKey != dailydata.getDateKeyFormat(DateTime.now())) {
          _dateKey = dailydata.getDateKeyFormat(DateTime.now());
        }
        if (counter >= 3) {
          _interstitialAd?.show();
          counter = 0;
        } else {
          requestAppReview();
        }
      });
    } else {
      Share.share(content ?? '');
    }
  }

  void requestAppReview() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    if (!_prefs.containsKey(KEY_LAST_REVIEW_REQUESTED)) {
      await _prefs.setInt(KEY_LAST_REVIEW_REQUESTED, now.subtract(Duration(days: 25)).millisecondsSinceEpoch);
    }
    DateTime lastDateReviewRequested = DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(KEY_LAST_REVIEW_REQUESTED) ?? 0,
    );
    if (now.difference(lastDateReviewRequested).inDays > 30) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
      await _prefs.setInt(KEY_LAST_REVIEW_REQUESTED, now.millisecondsSinceEpoch);
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        notificationService.cancelSingleNotifications(ID_DAILY_NOTIFICATION);
        initTodaysPage();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (await prefs.getBool('isNotificationsEnabled') ??
            DEFAULT_NOTIFICATION_ENABLED) {
          await notificationService.showScheduledLocalNotification(
              id: ID_DAILY_NOTIFICATION,
              title:
              L10n.of(context).resource('dailyReminderNotificationTitle'),
              body: L10n.of(context).resource('dailyReminderNotificationBody'),
              payload: L10n.of(context)
                  .resource('dailyReminderNotificationPayload'));
        }
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
    initTodaysPage();
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
                  SizedBox(height: 20,),
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
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text(_quote?.author ?? '',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      GoogleFonts
                                                          .caveat()
                                                          .fontFamily,
                                                      color: CupertinoColors
                                                          .black,
                                                      fontSize:
                                                      MEDIUM_FONTSIZE))
                                            ])
                                      ],
                                    ),
                                  )),
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    CupertinoButton(
                                      onPressed: () => {
                                        showSharePopup('', '')
                                      },
                                      child: Icon(CupertinoIcons.pencil_ellipsis_rectangle),
                                    ),
                                    VerticalDivider(
                                      color: Colors.black,
                                      thickness: 40,
                                      width: 20,
                                    ),
                                    CupertinoButton(
                                      onPressed: () => {
                                        showSharePopup(
                                            _quote?.content ?? '',
                                            _quote?.author ?? '')
                                      },
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

  Future<void> initTodaysPage() async {
    quote.Quote? q = await quote.QuoteHelper.fetchDataIfNeeded();
    setState(() {
      _quote = q;
    });
    fetchFavoriteQuotes();
  }
}
