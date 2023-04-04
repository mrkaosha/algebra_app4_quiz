import 'package:algebra_app4_quiz/calculate_slope.dart';
import 'package:algebra_app4_quiz/equation_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'problem_statement.dart';
import 'grid_with_gestures.dart';
import 'calculator.dart';

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
  double x = 0.0;
  double y = 0.0;
  double canvasWidth = 500;
  double canvasHeight = 500;
  double gridSize = 25;
  double margins = 0.05; //the margin size as a percent of canvasWidth
  CalculateSlope params = CalculateSlope();
  Map<String, dynamic> currentParams = {};
  bool drawCursor = false;
  bool tapUp = true;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _uid = "";

  @override
  _MainAppState() {
    currentParams = params.getNextParams();
    _resetDataList();
    print(currentParams);
  }

  List<List<bool>> dataList = [];

  void _resetDataList() {
    dataList = List.generate(
      (canvasHeight / gridSize as int) + 1,
      (i) => List.generate(
        (canvasWidth / gridSize as int) + 1,
        (j) => false,
        growable: false,
      ),
      growable: false,
    );
  }

  void nextEquation() {
    setState(() => currentParams = params.getNextParams());
    print(currentParams);
  }

  bool checkAnswer() {


    db.collection('listtest').doc(_uid).set({
      "author_uid": _uid,
      "author_name": 'mrkaosha',
      'test': FieldValue.serverTimestamp()
    });

    db.collection('listtest').get().then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    return false;
  }

  void updateUser(String uid) {
    _uid = uid;
    print(_uid);
  }

  @override
  Widget build(BuildContext context) {
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
            MyEquationInput(),
            Align(
              child: ActionButtons(
                checkAnswer: checkAnswer,
                nextEquation: nextEquation,
                currentParams: currentParams,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _resetDataList());
              },
              child: const Text("Clear graph"),
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
        widget.updateUid(user.uid);
        userName =
            user.email != null ? user.email!.split('@')[0] : 'Guest User';
        setState(() {
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
