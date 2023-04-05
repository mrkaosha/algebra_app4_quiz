library action_buttons;
import 'package:flutter/material.dart';


class ActionButtons extends StatelessWidget {
  final dynamic checkAnswer;
  final dynamic nextEquation;
  final dynamic currentParams;
  const ActionButtons(
      {required this.checkAnswer,
      required this.nextEquation,
      required this.currentParams,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextButton(
          onPressed: () {
            bool correct = checkAnswer();
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: Text(correct
                    ? "Correct!"
                    : "Incorrect, make sure your slope is ${currentParams['num']}/${currentParams['den']} or ${currentParams['num'] * -1}/${currentParams['den'] * -1} or a reduced fraction form of either"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
          child: const Text("Check Answer"),
        ),
        TextButton(
          onPressed: () {
            nextEquation();
          },
          child: const Text("Next Equation"),
        ),
      ],
    );
  }
}
