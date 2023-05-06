import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart';
import 'package:motivational_quotes/dbhelpers/QuoteHelper.dart';
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:share_plus/share_plus.dart';

import 'l10n/Localizations.dart';

class AllQuotesPage extends StatefulWidget {
  @override
  State<AllQuotesPage> createState() => _AllQuotesPageState();
}

class _AllQuotesPageState extends State<AllQuotesPage> {
  late List<Widget> allQuotesWidgetList;
  late Map<String, dynamic> allQuotesList;

  void dataChangeCallback() {
    fetchAllQuotes();
  }

  @override
  void initState() {
    super.initState();
    allQuotesWidgetList = [];
    allQuotesList = {};
    registerWriteCallback(dataChangeCallback);
    fetchAllQuotes();
  }

  void filterQuotes(String text) {
    allQuotesWidgetList.clear();
    if (text.isEmpty) {
      addAllQuoteWidgets();
    } else {
      allQuotesList?.forEach((key, value) {
        if (value.keys
                .elementAt(0)
                .toString()
                .toLowerCase()
                .contains(text.toLowerCase()) ||
            value[value.keys.elementAt(0)]
                .toString()
                .toLowerCase()
                .contains((text.toLowerCase()))) {
          allQuotesWidgetList.add(DecoratedText(
              key,
              value[value.keys.elementAt(0)],
              value.keys.elementAt(0),
              showSharePopup));
        }
      });
      setState(() {
        allQuotesWidgetList = allQuotesWidgetList;
      });
    }
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
              Container(
                  child: Column(
                key: UniqueKey(),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: allQuotesWidgetList,
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchAllQuotes() async {
    allQuotesList = await QuoteHelper.getAllQuotes();
    addAllQuoteWidgets();
  }

  void addAllQuoteWidgets() {
    allQuotesWidgetList.clear();
    allQuotesList?.forEach((key, value) {
      allQuotesWidgetList.add(DecoratedText(key, value[value.keys.elementAt(0)],
          value.keys.elementAt(0), showSharePopup));
    });
    setState(() {
      allQuotesWidgetList = allQuotesWidgetList;
    });
  }

  void showSharePopup(String name, String quote, String author) {
    if (!kIsWeb) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => Dialog(
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
              child: ImageShare(name, quote, author)));
    } else {
      Share.share(quote);
    }
  }
}
