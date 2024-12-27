import 'package:flutter/material.dart';
import 'package:tes_venteny/core/utils/extension/context_ext.dart';

class PopupMenuHorizontal extends StatelessWidget {
  final List<Widget> children;
  const PopupMenuHorizontal({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: context.theme.secondaryHeaderColor,
          width: 3,
        ),
      ),
      offset: const Offset(42, -10),
      color: context.theme.secondaryHeaderColor,
      icon: Icon(
        Icons.more_horiz,
        color: context.theme.secondaryHeaderColor,
      ),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuWidget(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          )
        ];
      },
    );
  }
}

class PopupMenuWidget<T> extends PopupMenuEntry<T> {
  const PopupMenuWidget({super.key, required this.height, required this.child});

  final Widget child;

  @override
  final double height;

  bool get enabled => false;

  @override
  createState() => _PopupMenuWidgetState();

  @override
  bool represents(T? value) {
    return false;
  }
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}
