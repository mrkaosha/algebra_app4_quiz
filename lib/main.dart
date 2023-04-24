import 'package:algebra_app4_quiz/calculate_slope.dart';
import 'package:algebra_app4_quiz/equation_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'action_buttons.dart';
import 'problem_statement.dart';
import 'package:math_expressions/math_expressions.dart';
//import 'grid_with_gestures.dart';
//import 'calculator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  CalculateSlope params = CalculateSlope();
  Map<String, dynamic> currentParams =
      {}; //parameters for the current math problem

  List<String> _userInput = [];
  Variable xVar = Variable('x');
  Variable yVar = Variable('y');
  Parser p = Parser();
  late Expression exp;
  ContextModel cm = ContextModel();
  String incorrectMessage = "none";

  FirebaseFirestore db = FirebaseFirestore.instance;
  String _uid = "guest";
  String _username = "Guest";

  @override
  _MainAppState() {
    currentParams = params.getNextParams();
    print(currentParams);
  }

  List<List<bool>> dataList = [];

  void nextEquation() {
    setState(() => currentParams = params.getNextParams());
    print(currentParams);
  }

  bool checkAnswer() {
    bool correct = false;
    String checkEquation =
        "${_userInput.join().replaceAll('∸', '-').replaceAll('⋅x', '*x').replaceFirst('=', '-(')})";
    cm.bindVariable(xVar, Number(currentParams['x1']));
    cm.bindVariable(yVar, Number(currentParams['y1']));
    try {
      exp = p.parse(checkEquation);
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      print(eval);
      if (eval == 0.0) {
        cm.bindVariable(
            xVar, Number(currentParams['x1'] + currentParams['den']));
        cm.bindVariable(
            yVar, Number(currentParams['y1'] + currentParams['num']));
        print(exp.evaluate(EvaluationType.REAL, cm) == 0.0);
        correct = exp.evaluate(EvaluationType.REAL, cm) == 0.0;
        return (correct);
      } else {
        setState(() {
          incorrectMessage = "none";
        });
        return (correct);
      }
    } catch (e) {
      print('syntax error');
      setState(() {
        incorrectMessage =
            "The expression you entered is not a standard format";
      });
    } finally {
      DocumentReference prevAnswer =
          db.collection(_username).doc(currentParams.toString());
      prevAnswer.get().then((d) => {
            if (d.exists)
              {
                prevAnswer.update({
                  "author_uid": _uid,
                  "author_name": _username,
                  'response': _userInput.join(),
                  'correct': correct,
                  'time': FieldValue.serverTimestamp(),
                  'attempts': FieldValue.increment(1)
                })
              }
            else
              {
                prevAnswer.set({
                  "author_uid": _uid,
                  "author_name": _username,
                  'response': _userInput.join(),
                  'correct': correct,
                  'time': FieldValue.serverTimestamp(),
                  'attempts': 1
                })
              }
          });
    }
/*
    db.collection('listtest').doc(_uid).set({
      "author_uid": _uid,
      "author_name": _username,
      'test': FieldValue.serverTimestamp()
    });
*/
    return correct;
  }

  String getIncorrectMessage() {
    return incorrectMessage;
  }

  void updateUserEquation(List<String> userInput) {
    setState(() {
      _userInput = userInput;
      print(
          'check:${userInput.join().replaceAll('∸', '-').replaceAll('⋅x', '*x').replaceFirst('=', '-(')})');
    });
  }

  void updateUser(String uid, String username) {
    setState(() {
      _uid = uid;
      _username = username;
    });
    print(_uid);
  }

  @override
  Widget build(BuildContext context) {
    print(_userInput);
    var theme = Theme.of(context);

    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            Align(
              child: LoginButton(
                updateUid: updateUser,
              ),
            ),
            Align(
              child: ProblemStatement(currentParams: currentParams),
            ),
            MyEquationInput(
              updateUserEquation: updateUserEquation,
            ),
            Align(
              child: ActionButtons(
                checkAnswer: checkAnswer,
                nextEquation: nextEquation,
                currentParams: currentParams,
                getIncorrectMessage: getIncorrectMessage,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 240.0),
            ),
            Card(
              color: theme.colorScheme.primary,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  child: Text(
                    "South Hills Academy",
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  LoginButton({
    required this.updateUid,
    super.key,
  });

  late dynamic updateUid;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  late bool loggedIn = false;
  late String userName = 'Guest User';

  _LoginButtonState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
        userName =
            user.email != null ? user.email!.split('@')[0] : 'Guest User';
        setState(() {
          widget.updateUid(user.uid, userName);
          loggedIn = true;
        });
      }
    });
  }

  Future<void> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    //return await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  //https://firebase.google.com/docs/auth/flutter/manage-users
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: loggedIn
          ? Column(
              children: [
                Text('Welcome $userName'),
                TextButton(
                  onPressed: () => setState(() {
                    loggedIn = false;
                    FirebaseAuth.instance.signOut;
                  }),
                  child: const Text('Log Out'),
                ),
              ],
            )
          : SignInButton(
              Buttons.GoogleDark,
              onPressed: signInWithGoogle,
            ),
    );
  }
}
