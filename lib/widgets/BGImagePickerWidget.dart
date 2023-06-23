import 'package:flutter/cupertino.dart';

class ImagePickerRow extends StatefulWidget {
  final List<String> assetList;
  final Function(String) onImageSelected;
  final int initialIndex;

  ImagePickerRow({Key? key, required this.assetList, required this.onImageSelected, required this.initialIndex})
      : super(key: key);

  @override
  _ImagePickerRowState createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.initialIndex;
    });
  }

  @override
  void didUpdateWidget(covariant ImagePickerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _selectedIndex = widget.initialIndex;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.assetList.length,
            (index) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () => _selectImage(index),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(widget.assetList[index]),
                    fit: BoxFit.cover
                ),
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
