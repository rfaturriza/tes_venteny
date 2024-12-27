import 'package:flutter/material.dart';
import '/core/utils/extension/context_ext.dart';


class CheckBoxListTileMuslimBook extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CheckBoxListTileMuslimBook({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          checkColor: context.theme.primaryColor,
          activeColor: context.theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(
            color: context.theme.primaryColor,
            width: 2,
          ),
        ),
        Text(title),
      ],
    );
  }
}