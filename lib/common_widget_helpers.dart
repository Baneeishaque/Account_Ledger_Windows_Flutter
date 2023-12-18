import 'package:flutter/material.dart';

Widget getFullWidthOutlinedButton({
  required String text,
  required VoidCallback? onPressed,
  EdgeInsets padding = const EdgeInsets.only(top: 16.0),
}) {
  return SizedBox(
    width: double.infinity,
    child: Padding(
      padding: padding,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    ),
  );
}

Widget getTopPaddingWidget({
  required Widget widget,
  EdgeInsets padding = const EdgeInsets.only(top: 16.0),
}) {
  return Padding(
    padding: padding,
    child: widget,
  );
}

void clearTextEditingControllers(
    List<TextEditingController> textEditingControllers) {
  for (TextEditingController textEditingController in textEditingControllers) {
    textEditingController.clear();
  }
}
