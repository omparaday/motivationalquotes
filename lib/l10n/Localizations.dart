import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class L10n {
  L10n(this.locale);

  final Locale locale;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'searchHelp': 'Search keyword or author name',
      'quoteoftheday': 'Today\'s Quote',
      'favorites': 'Favorites',
      'list': 'All Quotes',
      'authorFilter': 'Authors',
      'allFilter': 'All',
      'oscarwilde': 'Oscar Wilde',
      'victorhugo': 'Victor Hugo',
      'maryshelly': 'Mary Shelley',
      'charlottebronte': 'Charlotte Brontë',
      'waldoemerson': 'Ralph Waldo Emerson',
      'fuller': 'Margaret Fuller',
      'barnett': 'IDA B. WELLS-BARNETT',
      'whitman': 'Walt Whitman',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'hello': 'Hello',
      'dailyReminderNotificationTitle': 'Motivational Quotes',
      'dailyReminderNotificationBody': 'Check your today\'s Motivational Quote',
      'dailyReminderNotificationPayload': '',
      'art': 'Art',
      'color': 'Color',
      'theme': 'Background Theme',
      'prev': 'Previous',
      'next': 'Next',
      'close': 'Close',
      'getStarted': 'Your privacy is assured. Your data or anything you do in this app is not transferred outside your phone or used by anyone else.\n\nGet started.\nWishing you a motivational times ahead!',
      'settingsWelcome': 'Choose customized look and feel with appealing arts and colors. You can also set notification to read quotes everyday.',
      'allQuotesWelcome': 'More than 500 quotes from the great authors at All Quotes page. You can search quotes by author name or keywords.',
      'todayWelcome': 'Get a new quote everyday. Mark your favorite quotes and share them with your friends and family with personalized fonts and background.',
      'welcome': 'Welcome to Motivational Quotes!\nEnergize your day and that of your friends and family with carefully handpicked quotes from great authors.',
    }
  };

  static List<String> languages ()=> _localizedValues.keys.toList();

  String resource(String name) {
    return _localizedValues[locale.languageCode]![name]!;
  }
}
// #enddocregion Demo

// #docregion Delegate
class L10nDelegate
    extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) => L10n.languages().contains(locale.languageCode);


  @override
  Future<L10n> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<L10n>(L10n(locale));
  }

  @override
  bool shouldReload(L10nDelegate old) => false;
}