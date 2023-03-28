library problem_statement;

import 'package:flutter/material.dart';

class ProblemStatement extends StatelessWidget {
  const ProblemStatement({
    super.key,
    required this.currentParams,
  });

  final Map<String, dynamic> currentParams;

  @override
  Widget build(BuildContext context) {
    String eqnString = "${currentParams['num']}, ${currentParams['den']}, ${currentParams['x1']}, ${currentParams['y1']}";
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        "Graph $eqnString",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
