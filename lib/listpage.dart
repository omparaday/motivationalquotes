import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart';
import 'package:motivational_quotes/dbhelpers/QuoteHelper.dart';
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:motivational_quotes/widgets/RounderSegmentControl.dart';
import 'package:share_plus/share_plus.dart';

import 'l10n/Localizations.dart';

class AllQuotesPage extends StatefulWidget {
  @override
  State<AllQuotesPage> createState() => _AllQuotesPageState();
}

class _AllQuotesPageState extends State<AllQuotesPage> {
  late List<Widget> recentData;

  void dataChangeCallback() {
    fetchAllQuotes();
  }

  @override
  void initState() {
    super.initState();
    recentData = [];
    registerWriteCallback(dataChangeCallback);
    fetchAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Icon(CupertinoIcons.doc_text_search),
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: recentData,
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchAllQuotes() async {
    Map<String, dynamic> quoteList = await QuoteHelper.getAllQuotes();
    recentData.clear();
    quoteList?.forEach((key, value) {
      recentData.add(DecoratedText(key, value[value.keys.elementAt(0)], value.keys.elementAt(0), showSharePopup));
    });
    setState(() {
      recentData = recentData;
    });
  }

  void showSharePopup(String name, String quote) {
    if (!kIsWeb) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Dialog(
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
              child: ImageShare(name, quote)));
    } else {
      Share.share(quote);
    }
  }
}
