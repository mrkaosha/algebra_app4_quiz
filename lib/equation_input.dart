library equation_input;

import 'package:flutter/material.dart';
import 'buttons.dart';
import 'package:math_expressions/math_expressions.dart';

class MyEquationInput extends StatefulWidget {
  MyEquationInput() {
    key:
    super.key;
  }
  @override
  MyEquationInputState createState() => MyEquationInputState();
}

class MyEquationInputState extends State<MyEquationInput> {
  var userInput = '';
  var answer = '';

// Array of button
  final List<String> buttons = [
    'C',
    'DEL',
    'y = ',
    'x',
    '+',
    '-',
    '1',
    '2',
    '3',
    '4',
    '5',
    '/',
    '6',
    '7',
    '8',
    '9',
    '0',
  ];

  @override
  Widget build(BuildContext context) {
    print(userInput);
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
          horizontal: MediaQuery.of(context).size.width / 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,
                  child: Text(
                    userInput,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.centerRight,
                  child: Text(
                    answer,
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ]),
          GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, mainAxisExtent: 75),
              itemBuilder: (BuildContext context, int index) {
                // Clear Button
                if (index == 0) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        userInput = '';
                        answer = '0';
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }

                // % Button
                else if (index == 2 || index == 3) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        userInput += buttons[index];
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }
                // Delete Button
                else if (index == 1) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        userInput =
                            userInput.substring(0, userInput.length - 1);
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }
                // Equal_to Button
                else if (index == 18) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        equalPressed();
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.orange[700],
                    textColor: Colors.white,
                  );
                }

                // other buttons
                else {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        userInput += buttons[index];
                      });
                    },
                    buttonText: buttons[index],
                    color: isOperator(buttons[index])
                        ? Colors.blueAccent
                        : Colors.white,
                    textColor: isOperator(buttons[index])
                        ? Colors.white
                        : Colors.black,
                  );
                }
              }), // GridView.builder
        ],
      ),
    );
  }

  bool isOperator(String x) {
    if (x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

// function to calculate the input operation
  void equalPressed() {
    String finaluserinput = userInput;
    finaluserinput = userInput.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finaluserinput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    answer = eval.toString();
  }
}
