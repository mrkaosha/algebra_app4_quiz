library action_buttons;

import 'package:flutter/material.dart';

class ActionButtons extends StatefulWidget {
  final dynamic checkAnswer;
  final dynamic nextEquation;
  final dynamic currentParams;
  final dynamic getIncorrectMessage;
  const ActionButtons(
      {required this.checkAnswer,
      required this.nextEquation,
      required this.currentParams,
      required this.getIncorrectMessage,
      super.key});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool correct = false;
  String incorrectMessage = "none";
  @override
  Widget build(BuildContext context) {
    String message = "";
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              correct = widget.checkAnswer();
              incorrectMessage = widget.getIncorrectMessage();
              if (incorrectMessage == "none") {
                message =
                    "Incorrect, make sure your slope is ${widget.currentParams['num']}/${widget.currentParams['den']} or ${widget.currentParams['num'] * -1}/${widget.currentParams['den'] * -1} or a reduced fraction form of either";
              } else {
                message = incorrectMessage;
              }
            });
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: Text(correct ? "Correct!" : message),
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
            widget.nextEquation();
          },
          child: const Text("Next Equation"),
        ),
      ],
    );
  }
}
