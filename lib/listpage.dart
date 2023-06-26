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
  late Map<String, dynamic> filteredQuotesList;
  late Map<String, dynamic> originalQuotesList;

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
              child: ImageShare(name, quote, author)));
    } else {
      Share.share(quote);
    }
  }
}
