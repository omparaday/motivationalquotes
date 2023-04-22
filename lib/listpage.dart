import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivational_quotes/dbhelpers/DailyData.dart';
import 'package:motivational_quotes/dbhelpers/QuoteHelper.dart';
import 'package:motivational_quotes/widgets/DecoratedText.dart';
import 'package:motivational_quotes/widgets/ImageShare.dart';
import 'package:share_plus/share_plus.dart';

class AllQuotesPage extends StatefulWidget {
  @override
  State<AllQuotesPage> createState() => _AllQuotesPageState();
}

class _AllQuotesPageState extends State<AllQuotesPage> {
  late List<Widget> allQuotesWidgetList;

  void dataChangeCallback() {
    fetchAllQuotes();
  }

  @override
  void initState() {
    super.initState();
    allQuotesWidgetList = [];
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
                children: allQuotesWidgetList,
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchAllQuotes() async {
    Map<String, dynamic> quoteList = await QuoteHelper.getAllQuotes();
    allQuotesWidgetList.clear();
    quoteList?.forEach((key, value) {
      allQuotesWidgetList.add(DecoratedText(key, value[value.keys.elementAt(0)], value.keys.elementAt(0), showSharePopup));
    });
    setState(() {
      allQuotesWidgetList = allQuotesWidgetList;
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
