import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivational_quotes/main.dart';

import '../l10n/Localizations.dart';

class FontPickerRow extends StatefulWidget {
  final List<String?> fontList;
  final Function(String) onFontSelected;

  const FontPickerRow({Key? key, required this.fontList, required this.onFontSelected})
      : super(key: key);

  @override
  _FontPickerRowState createState() => _FontPickerRowState();
}

class _FontPickerRowState extends State<FontPickerRow> {
  int _selectedIndex = 0;

  void _selectColor(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onFontSelected(widget.fontList[index]?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.fontList.length,
            (index) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () => _selectColor(index),
            child: Container(
              child: Text(L10n.of(context).resource('hello'),
                  style: TextStyle(
                      fontFamily: widget.fontList[index],
                      color: CupertinoColors.black,
                      fontSize: SMALL_FONTSIZE)),
              decoration: BoxDecoration(
                border: _selectedIndex == index
                    ? Border.all(width: 4, color: CupertinoColors.white)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
