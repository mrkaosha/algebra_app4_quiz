library equation_input;

import 'package:flutter/material.dart';
import 'buttons.dart';
import 'package:catex/catex.dart';

class MyEquationInput extends StatefulWidget {
  MyEquationInput({super.key, required this.updateUserEquation}) {}

  final dynamic updateUserEquation;

  @override
  MyEquationInputState createState() => MyEquationInputState();
}

class MyEquationInputState extends State<MyEquationInput> {
  List<String> userInput = [' '];
  var uiEqn = '';
  bool allowX = true;
  bool allowOperator = true;

// Array of button
  final List<String> buttons = [
    'C',
    'DEL',
    'y=',
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
    '*',
  ];

  void createUIEqn() {
    List<String> splitString = List<String>.from(userInput);
    splitString.asMap().forEach((index, element) {
      if (index == splitString.length - 1) {
        return;
      }
      if (element.contains('/')) {
        splitString[index - 1] = '\\frac\{${splitString[index - 1]}\}';
        splitString[index + 1] = '\{${splitString[index + 1]}\}';
        splitString[index] = '';
      }
    });
    uiEqn = splitString.join();
    uiEqn = uiEqn.replaceAll('∸', '-');
    //print(uiEqn);
  }

  @override
  Widget build(BuildContext context) {
    createUIEqn();

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
          horizontal: MediaQuery.of(context).size.width / 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.centerLeft,
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        child: CaTeX(userInput == []
                            ? r'\text{ }'
                            : uiEqn + r'\text{ }'),
                      )),
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
                        userInput = [' '];
                        widget.updateUserEquation(userInput);
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }

                // y= Button
                else if (index == 2) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        userInput.add(buttons[index]);
                        widget.updateUserEquation(userInput);
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }

                // x button
                else if (index == 3) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        if (allowX) {
                          userInput.add(
                            isOperator(userInput.last) || userInput.last == '∸'
                            ? 'x'
                            : '⋅x'
                          );
                          widget.updateUserEquation(userInput);
                          allowX = false;
                        }
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
                        if (userInput.length > 1) {
                          userInput.removeLast();
                          allowX = checkForAllowX(userInput.length - 1);
                          widget.updateUserEquation(userInput);
                        }
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }
                // + button
                else if (index == 4) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        if (!isOperator(userInput.last)) {
                          userInput.add(buttons[index]);
                          widget.updateUserEquation(userInput);
                          allowX = true;
                        }
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                  );
                }
                // - button
                else if (index == 5) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        if (isOperator(userInput.last)) {
                          userInput.add('∸');
                          widget.updateUserEquation(userInput);
                        } else if (userInput.last.split('').last == '∸') {
                          userInput.last += '∸';
                          widget.updateUserEquation(userInput);
                        } else {
                          userInput.add(buttons[index]);
                          widget.updateUserEquation(userInput);
                          allowX = true;
                        }
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                  );
                }
                // / button
                else if (index == 11) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        if (!isOperator(userInput.last)) {
                          userInput.add(buttons[index]);
                          widget.updateUserEquation(userInput);
                          allowX = false;
                        }
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                  );
                }
                // * button
                else if (index == 17) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        if (!isOperator(userInput.last)) {
                          userInput.add(buttons[index]);
                          widget.updateUserEquation(userInput);
                        }
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                  );
                }
                // other buttons (there is a hack to check for operator)
                // TODO: It still allows weird things like -/5 and -*5
                else {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        if (isOperator(userInput.last)) {
                          userInput.add(buttons[index]);
                          widget.updateUserEquation(userInput);
                          allowX = checkForAllowX(userInput.length - 1);
                        } else {
                          userInput.last += buttons[index];
                          widget.updateUserEquation(userInput);
                          allowX = true;
                        }
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
    if (x == '-' || x == '+' || x == '/' || x == '*' || x == 'y=' || x == ' ') {
      return true;
    }
    return false;
  }

  bool checkForAllowX(int i) {
    if(i <= 0 || userInput[i] == 'y=' || userInput[i] == '+' || userInput[i] == '-') {
      return true;
    } else if(userInput[i] == '*') {
      return (true && checkForAllowX(i-1));
    } else if(userInput[i] == 'x' || userInput[i] == '⋅x') {
      return false;
    } else {
      return checkForAllowX(i-1);
    }
  }

/** function to calculate the input operation
  void equalPressed() {
    String finaluserinput = userInput;
    finaluserinput = userInput.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finaluserinput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    answer = eval.toString();
  }
*/
}
