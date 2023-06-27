import 'package:flutter/cupertino.dart';

class ImagePickerRow extends StatefulWidget {
  final List<String> assetList;
  final Function(String) onImageSelected;
  final int initialIndex;
  double? iconSize;

  ImagePickerRow({Key? key, required this.assetList, required this.onImageSelected, required this.initialIndex, this.iconSize})
      : super(key: key);

  @override
  _ImagePickerRowState createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
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
  void didUpdateWidget(covariant ImagePickerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedIndex = widget.initialIndex;
      _iconSize = widget.iconSize?? 35;
    });
  }

  void _selectImage(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onImageSelected(widget.assetList[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 7,
      children: List.generate(
        widget.assetList.length,
            (index) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () => _selectImage(index),
            child: Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(widget.assetList[index]),
                    fit: BoxFit.cover
                ),
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
