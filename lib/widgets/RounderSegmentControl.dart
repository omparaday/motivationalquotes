import 'package:flutter/cupertino.dart';

class RoundedSegmentControl<T extends Object> extends StatefulWidget {
  final Map<T, String> children;
  final T groupValue;
  final Function onValueChanged;

  RoundedSegmentControl({required this.children, required this.onValueChanged, required this.groupValue});

  @override
  _RoundedSegmentControlState createState() => _RoundedSegmentControlState();
}

class _RoundedSegmentControlState<T extends Object> extends State<RoundedSegmentControl<T>> {
  late T current;

  @override
  void initState() {
    super.initState();
    current = widget.groupValue;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 7,
      children: List.generate(
        widget.children.length,
            (index) {
          T elementAtIndex = widget.children.keys.elementAt(index);
          return GestureDetector(
            onTap: () async {
              setState(() => current = elementAtIndex);
              widget.onValueChanged(current);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 2, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                color: elementAtIndex == current ? CupertinoColors.systemBlue : CupertinoColors.systemGrey2,
              ),
              child: Text(widget.children[elementAtIndex] ?? '', style: TextStyle(color: CupertinoColors.white)),
            ),
          );
        },
      ),
    );
  }
}