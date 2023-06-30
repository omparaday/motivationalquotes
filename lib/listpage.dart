import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart';
import 'package:motivational_quotes/dbhelpers/QuoteHelper.dart';
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'l10n/Localizations.dart';

class AllQuotesPage extends StatefulWidget {
  @override
  State<AllQuotesPage> createState() => _AllQuotesPageState();
}

class _AllQuotesPageState extends State<AllQuotesPage> {
  late List<Widget> allQuotesWidgetList;
  late Map<String, dynamic> filteredQuotesList;
  late Map<String, dynamic> originalQuotesList;
  InterstitialAd? _interstitialAd;
  int counter = 0;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

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

  void dataChangeCallback() {
    fetchAllQuotes();
  }

  @override
  void initState() {
    super.initState();
    allQuotesWidgetList = [];
    filteredQuotesList = {};
    originalQuotesList = {};
    registerWriteCallback(dataChangeCallback);
    fetchAllQuotes();
  }

  void filterQuotes(String text) {
    allQuotesWidgetList.clear();
    filteredQuotesList.clear();
    if (text.isEmpty) {
      addAllQuoteWidgets();
    } else {
      filteredQuotesList.clear();
      originalQuotesList.forEach((key, value) {
        String quote = value[value.keys.elementAt(0)].toString().toLowerCase();
        String author = value.keys.elementAt(0).toString().toLowerCase();
        if (quote.contains(text.toLowerCase()) ||
            author.contains(text.toLowerCase())) {
          filteredQuotesList.putIfAbsent(key, () {
            return value;
          });
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              CupertinoSearchTextField(
                placeholder: L10n.of(context).resource('searchHelp'),
                onChanged: (value) => filterQuotes(value),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredQuotesList.length,
                itemBuilder: (context, index) {
                  String name = filteredQuotesList.keys.elementAt(index);
                  dynamic value = filteredQuotesList[name];
                  return DecoratedText(
                    name,
                    value[value.keys.elementAt(0)].toString(),
                    value.keys.elementAt(0), showSharePopup,
                    key: ValueKey<String>(name), // Assigning a unique key
                  );
                },
                addAutomaticKeepAlives: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchAllQuotes() async {
    if (filteredQuotesList.isEmpty) {
      filteredQuotesList = await QuoteHelper.getAllQuotes();
      originalQuotesList.addAll(filteredQuotesList);
    }
    addAllQuoteWidgets();
  }

  void addAllQuoteWidgets() {
    filteredQuotesList.clear();
    filteredQuotesList.addAll(originalQuotesList);
    setState(() {});
  }

  void showSharePopup(String name, String quote, String author) {
    if (!kIsWeb) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Dialog(
              backgroundColor:
              CupertinoTheme.of(context).scaffoldBackgroundColor,
              child: ImageShare(name, quote, author))).then((value) {
        counter++;
        if (counter == 2) {
          _loadAd();
        }
        if (counter >= 3) {
          _interstitialAd?.show();
          counter = 0;
        }
      });
    } else {
      Share.share(quote);
    }
  }
}
