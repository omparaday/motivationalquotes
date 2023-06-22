import 'package:flutter/cupertino.dart';

class ImagePickerRow extends StatefulWidget {
  final List<String> assetList;
  final Function(String) onImageSelected;

  const ImagePickerRow({Key? key, required this.assetList, required this.onImageSelected})
      : super(key: key);

  @override
  _ImagePickerRowState createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
  int _selectedIndex = 0;

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
                    fit: BoxFit.cover,
                    opacity: 0.4
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
