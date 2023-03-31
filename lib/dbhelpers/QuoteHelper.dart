import 'dart:convert'; //to convert json to maps and vice versa
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@JsonSerializable()
class Quote {
  final String name, content;

  Quote(this.name, this.content);
}
const QUOTE_START_KEY = 'QUOTE_START';
const QUOTES_FILE_PATH = "assets/quotes.json";
Future<Quote> getNewQuote() async {
  String data = await rootBundle.loadString(QUOTES_FILE_PATH);

  Map<String, dynamic> fileContent = Map<String,dynamic>.from(jsonDecode(data));
  final prefs = await SharedPreferences.getInstance();
  int? startPos = prefs.getInt(QUOTE_START_KEY);
  if (startPos == null) {
    startPos = new Random().nextInt(fileContent.length);
  }
  String quoteName = fileContent.keys.elementAt(startPos);
  prefs.setInt(QUOTE_START_KEY, (startPos + 1) % fileContent.length);
  return Quote(quoteName,fileContent[quoteName][fileContent[quoteName].keys.elementAt(0)]);
}

Future<Map<String, dynamic>> getAllQuotes() async {
  String data = await rootBundle.loadString(QUOTES_FILE_PATH);

  Map<String, dynamic> fileContent = Map<String,dynamic>.from(jsonDecode(data));
  return fileContent;
}

Future<Quote> getQuoteForKey(String quoteName) async {
  String data = await rootBundle.loadString(QUOTES_FILE_PATH);

  Map<String, dynamic> fileContent = Map<String,dynamic>.from(jsonDecode(data));
  return Quote(quoteName, fileContent[quoteName]);
}

Future<List<Quote>> getFavoriteQuotes() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? favList = prefs.getStringList("favorite_quotes");
  if (favList == null) {
    favList = <String>[];
  }
  List<Quote> quotelist = <Quote>[];
  String data = await rootBundle.loadString(QUOTES_FILE_PATH);

  Map<String, dynamic> fileContent = Map<String, dynamic>.from(
      jsonDecode(data));
  for (String key in favList) {
    quotelist.add(Quote(key, fileContent[key][fileContent[key].keys.elementAt(0)]));
  }
  return quotelist;
}

void addFavoriteQuote(String quotekey) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? favList = prefs.getStringList("favorite_quotes");
  if (favList == null) {
    favList = <String>[];
  }
  favList.add(quotekey);
  prefs.setStringList("favorite_quotes", favList);
}

Future<void> toggleFavoriteQuote(String quotekey) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? favList = prefs.getStringList("favorite_quotes");
  if (favList == null) {
    favList = <String>[];
    favList.add(quotekey);
  } else {
    if (favList.contains(quotekey)) {
      favList.remove(quotekey);
    } else {
      favList.add(quotekey);
    }
  }
  prefs.setStringList("favorite_quotes", favList);
}