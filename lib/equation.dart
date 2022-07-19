import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:function_tree/function_tree.dart';

class Equation extends StatefulWidget {
  Equation({Key? key}) : super(key: key);

  @override
  State<Equation> createState() => _EquationState();
}

class _EquationState extends State<Equation> {
  List<String> numOfVars = ['2', '3', '4', '5', '6', '7', '8', '9', '10'];
  List<String> operators = ['+', '-', '*', '/'];
  String dropdownValue = '2';
  String operatorValue = '+';

  List<String> operatorValues = [];
  List<TextEditingController> textEditingControllers = [];
  TextEditingController equationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool solutionPossible = true;
  bool entered = false;
  var x;
  var y;

  bool isUnique(String p) {
    List<String> comp = p.split("");
    if (comp.length == comp.toSet().length) {
      return true;
    } else {
      return false;
    }
  }

  void calculate(String equation) {
    int numOfVars = int.parse(dropdownValue);
    int min = pow(10, numOfVars - 1).toInt();
    int max = min * 10 - 1;
    for (int i = min; i <= max; i++) {
      String perm = i.toString();
      if (isUnique(perm) && !perm.contains('0')) {
        String temp = equation;
        for (int j = 0; j < numOfVars; j++) {
          temp = temp.replaceFirst(textEditingControllers[j].text, perm[j]);
        }
        if (temp.interpret() == int.parse(equationController.text)) {
          setState(() {
            y = '';
            for (int j = 0; j < numOfVars; j++) {
              y += '${perm[j]}, ';
            }
            solutionPossible = true;
          });
          return;
        }
      }
    }
    setState(() {
      solutionPossible = false;
    });
  }

  void evaluateEquation() {
    _formKey.currentState!.save();
    String equation = '';
    for (int i = 0; i < textEditingControllers.length; i++) {
      if (i != 0) {
        equation += operatorValues[i - 1];
      }
      equation += textEditingControllers[i].text;
    }
    calculate(equation);
  }

  @override
  void initState() {
    textEditingControllers.add(TextEditingController());
    textEditingControllers.add(TextEditingController());
    operatorValues.add('+');
    super.initState();
  }

  @override
  void dispose() {
    equationController.dispose();
    for (TextEditingController textEditingController
        in textEditingControllers) {
      textEditingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Solver'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    equationController.clear();
                    operatorValues = [];
                    textEditingControllers.clear();
                    for (int i = 0; i < int.parse(dropdownValue); i++) {
                      textEditingControllers.add(TextEditingController());
                      operatorValues.add('+');
                    }
                    entered = false;
                    isLoading = false;
                  });
                }),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Number of variables: ',
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton(
                value: dropdownValue,
                items: numOfVars.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    textEditingControllers.clear();
                    operatorValues.clear();
                    for (int i = 0; i < int.parse(dropdownValue); i++) {
                      textEditingControllers.add(TextEditingController());
                    }
                    for (int i = 0; i < int.parse(dropdownValue) - 1; i++) {
                      operatorValues.add('+');
                    }
                    entered = false;
                  });
                },
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 55,
                          child: TextFormField(
                            controller: textEditingControllers[0],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                        for (int i = 1; i < int.parse(dropdownValue); i++)
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 15),
                                width: 30,
                                child: DropdownButtonFormField(
                                  value: operatorValues[i - 1],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  decoration: const InputDecoration(
                                      border: InputBorder.none),
                                  icon: const Visibility(
                                      visible: false,
                                      child: Icon(Icons.arrow_downward)),
                                  items: operators.map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      operatorValues[i - 1] = newValue!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                height: 55,
                                child: TextFormField(
                                  controller: textEditingControllers[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "=",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 55,
                          child: IntrinsicWidth(
                            child: TextFormField(
                              controller: equationController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 75),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            evaluateEquation();
                            setState(() {
                              x = '';
                              for (TextEditingController t
                                  in textEditingControllers) {
                                x += '${t.text}, ';
                              }
                              entered = true;
                              isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(160, 40)),
                        child: const Text(
                          "Calculate",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: solutionPossible
                    ? RichText(
                        text: TextSpan(
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                            children: [
                              const TextSpan(text: "The value for "),
                              !entered
                                  ? const TextSpan(
                                      text: "? ",
                                      style: TextStyle(color: Colors.red))
                                  : TextSpan(
                                      text: x.toString(),
                                      style:
                                          const TextStyle(color: Colors.red)),
                              const TextSpan(text: " is "),
                              !entered
                                  ? const TextSpan(
                                      text: "? ",
                                      style: TextStyle(color: Colors.red))
                                  : TextSpan(
                                      text: y.toString(),
                                      style:
                                          const TextStyle(color: Colors.red)),
                              const TextSpan(text: "respectively."),
                            ]),
                      )
                    : Column(
                        children: const [
                          Text(
                            "Solution Not Possible",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          Text(
                            "1. Variable should be between 0 and 9.\n2. Variables should be different.",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
