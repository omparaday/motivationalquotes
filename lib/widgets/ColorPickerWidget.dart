import 'package:flutter/cupertino.dart';

class ColorPickerRow extends StatefulWidget {
  final List<Color> colorList;
  final Function(Color) onColorSelected;
  final int initialIndex;
  double? iconSize;

  ColorPickerRow({Key? key, required this.colorList, required this.onColorSelected, required this.initialIndex, this.iconSize})
      : super(key: key);

  @override
  _ColorPickerRowState createState() => _ColorPickerRowState();
}

class _ColorPickerRowState extends State<ColorPickerRow> {
  late int _selectedIndex;
  double _iconSize = 35;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.initialIndex;
      _iconSize = widget.iconSize?? 35;
    });
  }

  @override
  void didUpdateWidget(covariant ColorPickerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedIndex = widget.initialIndex;
      _iconSize = widget.iconSize?? 35;
    });
  }

  void _selectColor(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onColorSelected(widget.colorList[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 7,
      children: List.generate(
        widget.colorList.length,
            (index) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () => _selectColor(index),
            child: Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.colorList[index],
                border: _selectedIndex == index
                    ? Border.all(width: 4, color: CupertinoColors.systemOrange)
                    : Border.all(width: 4, color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
