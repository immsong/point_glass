import 'package:flutter/material.dart';

const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const titleHeight = 40.0;
const labelStyle = TextStyle(fontSize: 16);
const labelHeight = 30.0;

Widget title(String text) {
  return SizedBox(
    height: titleHeight,
    child: Row(
      children: [
        Text(text, style: titleStyle),
        const Spacer(),
      ],
    ),
  );
}

Widget label(String text) {
  return SizedBox(
    height: labelHeight,
    child: Row(
      children: [
        Text(text, style: labelStyle),
        const Spacer(),
      ],
    ),
  );
}

Widget horizontalLine() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    height: 1,
    color: Colors.grey.withAlpha(100),
  );
}

Widget radioButton({
  required String txt,
  required bool groupValue,
  required String trueLabel,
  required String falseLabel,
  required VoidCallback onTrueAction,
  required VoidCallback onFalseAction,
}) {
  return Row(
    children: [
      Expanded(child: label(txt)),
      Expanded(
        child: Row(
          children: [
            const Spacer(),
            Radio<bool>(
              value: true,
              groupValue: groupValue,
              onChanged: (value) {
                onTrueAction();
              },
            ),
            Expanded(child: label(trueLabel)),
            Radio<bool>(
              value: false,
              groupValue: groupValue,
              onChanged: (value) {
                onFalseAction();
              },
            ),
            Expanded(child: label(falseLabel)),
          ],
        ),
      ),
    ],
  );
}

Widget slider({
  required String txt,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
}) {
  return Row(
    children: [
      Expanded(flex: 2, child: label(txt)),
      Expanded(
        flex: 6,
        child: SizedBox(
          height: labelHeight,
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (value) {
              onChanged(value);
            },
          ),
        ),
      ),
      Expanded(child: label(value.toString())),
    ],
  );
}
