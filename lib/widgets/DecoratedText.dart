import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:motivational_quotes/dbhelpers/QuoteHelper.dart';

class DecoratedText extends StatefulWidget {
  String _name;
  String _text, _author;
  Function _onTap;
  TextStyle? textStyle;
  Color? backgroundColor;
  String get text => _text;

  DecoratedText(String this._name, String this._text, String this._author,
      Function this._onTap,
      {Key? key, TextStyle? this.textStyle, Color? this.backgroundColor})
      : super(key: key);

  @override
  DecoratedTextState createState() =>
      DecoratedTextState(_name, _text, _author, _onTap,
          textStyle: textStyle, backgroundColor: backgroundColor);
}

class DecoratedTextState extends State<DecoratedText> {
  DecoratedTextState(String this._name, String this._text, String this._author,
      Function this._onTap,
      {Key? key, TextStyle? this.textStyle, Color? this.backgroundColor});

  final String _name, _text, _author;
  final Function _onTap;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  bool showOverflow = false;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      child: GestureDetector(
          onTap: () {
            print('dt tapped');
            _onTap(_name, _text);
            setState(() {
              showOverflow = false;
            });
          },
          child: Container(
              child: Container(
                  margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  color: QuoteHelper.isFavoriteQuote(_name) ? Color.fromARGB(125, 247, 195, 104)
                      : Color.fromARGB(125, 184, 204, 245),
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Text(
                          _text,
                          style: textStyle,
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[Text(_author)]),
                      ]))))),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: toggleFavoriteQuote,
            backgroundColor: QuoteHelper.isFavoriteQuote(_name) ? Color.fromARGB(255, 212, 84, 70) :
            Color.fromARGB(255, 102, 145, 84),
            foregroundColor: CupertinoColors.white,
            icon: CupertinoIcons.infinite,
            label: QuoteHelper.isFavoriteQuote(_name) ? 'Remove Favorite' : 'Add Favorite',
          ),
        ],
      ),
    );
  }

  Future<void> toggleFavoriteQuote(BuildContext context) async {
    print('toggling fav uote');
    await QuoteHelper.toggleFavoriteQuote(_name);
    setState(() {});
  }
}
