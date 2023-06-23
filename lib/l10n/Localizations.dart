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
      'color': 'Color'
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