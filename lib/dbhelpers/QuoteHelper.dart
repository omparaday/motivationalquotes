import 'dart:convert'; //to convert json to maps and vice versa
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@JsonSerializable()
class Quote {
  final String name, content, author;

  Quote(this.name, this.content, this.author);
}
const QUOTE_START_KEY = 'QUOTE_START';
const QUOTES_FILE_PATH = "assets/quotes.json";
class QuoteHelper {
  static List<Function> callbacks = [];
  static List<Quote> favoriteQuoteList = [];
  static Map<String, dynamic> allQuoteFileContent = {};

  static void registerFavoriteUpdateCallback(Function callback) {
    callbacks.add(callback);
  }

  static void removeFavoriteUpdateCallback(Function callback) {
    callbacks.remove(callback);
  }

  static Future<Quote> getNewQuote() async {
    if (allQuoteFileContent.isEmpty) {
      await fetchAllQuotes();
    }
    final prefs = await SharedPreferences.getInstance();
    int? startPos = prefs.getInt(QUOTE_START_KEY);
    if (startPos == null) {
      startPos = new Random().nextInt(allQuoteFileContent.length);
    }
    String quoteName = allQuoteFileContent.keys.elementAt(startPos);
    prefs.setInt(QUOTE_START_KEY, (startPos + 1) % allQuoteFileContent.length);
    return Quote(quoteName,
        allQuoteFileContent[quoteName][allQuoteFileContent[quoteName].keys
            .elementAt(0)], allQuoteFileContent[quoteName].keys
            .elementAt(0));
  }

  static Future<Quote> getQuoteForKey(String quoteName) async {
    String data = await rootBundle.loadString("assets/quotes.json");

    Map<String, dynamic> allQuoteFileContent = Map<String,dynamic>.from(jsonDecode(data));
    return Quote(quoteName, allQuoteFileContent[quoteName][allQuoteFileContent[quoteName].keys.elementAt(0)], allQuoteFileContent[quoteName].keys.elementAt(0));
  }

  static Future<Map<String, dynamic>> getAllQuotes() async {
    await fetchAllQuotes();
    return allQuoteFileContent;
  }

  static Future<void> fetchAllQuotes() async {
    String data = await rootBundle.loadString(QUOTES_FILE_PATH);
    allQuoteFileContent = Map<String, dynamic>.from(
        jsonDecode(data));
  }

  static Future<List<Quote>> getFavoriteQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favList = prefs.getStringList("favorite_quotes");
    if (favList == null) {
      favList = <String>[];
    }
    List<Quote> quotelist = <Quote>[];
    if (allQuoteFileContent.isEmpty) {
      await fetchAllQuotes();
    }
    for (String key in favList) {
      quotelist.add(Quote(key,
          allQuoteFileContent[key][allQuoteFileContent[key].keys.elementAt(0)], allQuoteFileContent[key].keys.elementAt(0)));
    }
    favoriteQuoteList = quotelist;
    return favoriteQuoteList;
  }

  static bool isFavoriteQuote(String name) {
    bool result = false;
    for (Quote q in favoriteQuoteList) {
      result = result || q.name == name;
      if (result == true) {
        break;
      }
    }
    return result;
  }

  static void addFavoriteQuote(String quotekey) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favList = prefs.getStringList("favorite_quotes");
    if (favList == null) {
      favList = <String>[];
    }
    favList.add(quotekey);
    prefs.setStringList("favorite_quotes", favList);
    getFavoriteQuotes();
  }

  static Future<void> toggleFavoriteQuote(String quotekey) async {
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
    await getFavoriteQuotes();
    for (Function callback in callbacks) {
      callback();
    }
  }
}