import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts flutterTts = FlutterTts();
  int iterations = 0;
  bool solving = false;
  Set initpuzzle = Set();
  List initial = [];
  int initpointer = 1;
  List<List> sudoku = [
    [
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
    ],
    [
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
    ],
    [
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
      [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ],
    ]
  ];
  generate() async {
    await flutterTts.speak("Generated random problem");
    initial = [];
    int numbers = 24;
    Set<int> index = Set();
    int number = 1 + Random().nextInt(9 - 1);
    index.add(number);
    for (int k = 0; index.length < numbers; k++) {
      number = number + 5 + Random().nextInt(8 - 5);
      index.add(number);
    }
    initpuzzle = index;
    print(index);
    int val = 1;
    for (int a = 0; a < 3; a++) {
      for (int b = 0; b < 3; b++) {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            if (index.contains(val)) {
              initial.add(
                  a.toString() + b.toString() + i.toString() + j.toString());
              for (int x = 1; x < 10; x++) {
                int put = 1 + Random().nextInt(9 - 1);
                if (check(a, b, i, j, put)) {
                  setState(() {
                    sudoku[a][b][i][j] = put;
                  });
                  break;
                }
              }
            } else {
              setState(() {
                sudoku[a][b][i][j] = 0;
              });
            }

            val += 1;
          }
        }
      }
    }
    print(initial);
  }

  bool check(a, b, i, j, num) {
    if (rowcheck(a, b, i, j, num)) {
      if (colcheck(a, b, i, j, num)) {
        if (sectorcheck(a, b, i, j, num)) {
          return true;
        }
        return false;
      } else
        return false;
    } else
      return false;
  }

  bool rowcheck(a, b, i, j, num) {
    List checklist = [];
    for (b = 0; b < 3; b++) {
      for (j = 0; j < 3; j++) {
        checklist.add(sudoku[a][b][i][j]);
      }
    }
    if (checklist.contains(num)) {
      return false;
    } else
      return true;
  }

  bool colcheck(a, b, i, j, num) {
    List checklist = [];
    for (a = 0; a < 3; a++) {
      for (i = 0; i < 3; i++) {
        checklist.add(sudoku[a][b][i][j]);
      }
    }
    if (checklist.contains(num)) {
      return false;
    } else
      return true;
  }

  bool sectorcheck(a, b, i, j, num) {
    List checklist = [];
    for (i = 0; i < 3; i++) {
      for (j = 0; j < 3; j++) {
        checklist.add(sudoku[a][b][i][j]);
      }
    }
    if (checklist.contains(num)) {
      return false;
    } else
      return true;
  }

  searchempty() {
    List empty = [];
    int val = 1;
    for (int a = 0; a < 3; a++) {
      for (int b = 0; b < 3; b++) {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            if (sudoku[a][b][i][j] == 0) {
              empty.add(val);
            }
            val += 1;
          }
        }
      }
    }
    return empty;
  }

  findval(a, b, i, j, val) {
    iterations += 1;
    print(iterations);
    for (int x = sudoku[a][b][i][j] + 1; x < 10; x++) {
      if (check(a, b, i, j, x)) {
        setState(() {
          sudoku[a][b][i][j] = x;
        });
        print("found: " + val.toString() + "=" + sudoku[a][b][i][j].toString());
        break;
      }
    }
  }

  solve() async {
    await flutterTts.speak("Solving problem");
    List empty = searchempty();
    iterations = 0;
    print(empty);
    for (int pointer = 0; pointer < empty.length; pointer++) {
      int val = 1;
      OUTER:
      for (int a = 0; a < 3; a++) {
        for (int b = 0; b < 3; b++) {
          for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
              if (val == empty[pointer]) {
                int oldval = sudoku[a][b][i][j];
                findval(a, b, i, j, val);
                if (iterations > 30000) {
                  return;
                }
                if (sudoku[a][b][i][j] == oldval) {
                  setState(() {
                    sudoku[a][b][i][j] = 0;
                  });
                  pointer = pointer - 2;
                  print("backtracing to: " + empty[pointer].toString());
                }
                break OUTER;
              }
              val += 1;
            }
          }
        }
      }
    }
  }

  clear() async {
    for (int a = 0; a < 3; a++) {
      for (int b = 0; b < 3; b++) {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            setState(() {
              sudoku[a][b][i][j] = 0;
            });
          }
        }
      }
    }
    await flutterTts.speak("Board Cleared");
  }

  reset() async {
    int val = 1;
    for (int a = 0; a < 3; a++) {
      for (int b = 0; b < 3; b++) {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            if (initpuzzle.contains(val)) {
            } else {
              setState(() {
                sudoku[a][b][i][j] = 0;
              });
            }
            val += 1;
          }
        }
      }
    }
    await flutterTts.speak("Board Reset");
  }

  @override
  void initState() {
    FlutterTts().speak(
        "Press Generate to generate a random problem then press solve to solve the problem with backtracing algorithm");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Center(
          child: Container(
            height: 800,
            width: 800,
            color: Colors.white,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int a = 0; a < 3; a++)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int b = 0; b < 3; b++)
                    Container(
                      margin: EdgeInsets.all(3),
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 1.8, color: Colors.blueGrey),
                              bottom: BorderSide(
                                  width: 1.8, color: Colors.blueGrey))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 0; i < 3; i++)
                            Row(
                              children: [
                                for (int j = 0; j < 3; j++)
                                  Container(
                                    margin: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        color: sudoku[a][b][i][j] == 0
                                            ? Colors.transparent
                                            : initial.contains(a.toString() +
                                                    b.toString() +
                                                    i.toString() +
                                                    j.toString())
                                                ? Colors.blueGrey[700]
                                                : Colors.blueGrey[400],
                                        border: Border(
                                            left:
                                                BorderSide(color: Colors.white),
                                            top:
                                                BorderSide(color: Colors.white),
                                            right: BorderSide(
                                                color: Colors.blueGrey),
                                            bottom: BorderSide(
                                                color: Colors.blueGrey))),
                                    width: 50,
                                    height: 50,
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: "    " +
                                              sudoku[a][b][i][j].toString()),
                                      style: TextStyle(
                                          color: sudoku[a][b][i][j] == 0
                                              ? Colors.blueGrey
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 19),
                                      onChanged: (value) {
                                        setState(() {
                                          sudoku[a][b][i][j] = int.parse(value);
                                        });
                                      },
                                    ),
                                  )
                              ],
                            )
                        ],
                      ),
                    ),
                ]),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                    hoverColor: Colors.blueGrey[100],
                    padding: EdgeInsets.all(8),
                    splashColor: Colors.white,
                    color: Colors.white,
                    onPressed: () {
                      generate();
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                          right: BorderSide(color: Colors.blueGrey, width: 2),
                          bottom: BorderSide(color: Colors.blueGrey, width: 2),
                        )),
                        padding: EdgeInsets.all(8),
                        width: 200,
                        child: Center(
                          child: Text(
                            "Generate",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ))),
                SizedBox(width: 80),
                RaisedButton(
                  hoverColor: Colors.blueGrey[100],
                  padding: EdgeInsets.all(8),
                  splashColor: Colors.white,
                  color: Colors.white,
                  onPressed: () async {
                    print(solving);
                    await solve();
                    List empty = searchempty();
                    print(empty);
                    if (empty.length == 0) {
                      print("success");
                      await flutterTts.speak("Problem Solved");
                    }
                    if (empty.length > 0) {
                      print("no solution found");
                      await flutterTts.speak("Solution Not Found");
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                        right: BorderSide(color: Colors.blueGrey, width: 2),
                        bottom: BorderSide(color: Colors.blueGrey, width: 2),
                      )),
                      padding: EdgeInsets.all(8),
                      width: 200,
                      child: Center(
                          child: Text(
                        "Solve",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w600),
                      ))),
                )
              ]),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                    hoverColor: Colors.blueGrey[100],
                    padding: EdgeInsets.all(8),
                    splashColor: Colors.white,
                    color: Colors.white,
                    onPressed: () {
                      reset();
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                          right: BorderSide(color: Colors.blueGrey, width: 2),
                          bottom: BorderSide(color: Colors.blueGrey, width: 2),
                        )),
                        padding: EdgeInsets.all(8),
                        width: 200,
                        child: Center(
                          child: Text(
                            "Reset",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600),
                          ),
                        ))),
                SizedBox(width: 80),
                RaisedButton(
                  hoverColor: Colors.blueGrey[100],
                  padding: EdgeInsets.all(8),
                  splashColor: Colors.white,
                  color: Colors.white,
                  onPressed: () {
                    clear();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                        right: BorderSide(color: Colors.blueGrey, width: 2),
                        bottom: BorderSide(color: Colors.blueGrey, width: 2),
                      )),
                      padding: EdgeInsets.all(8),
                      width: 200,
                      child: Center(
                          child: Text(
                        "Clear",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w600),
                      ))),
                )
              ]),
            ]),
          ),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.45,
            child: Opacity(
              opacity: solving ? 1 : 0,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Column(children: [
                  Container(
                      width: 150,
                      height: 150,
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/8/8c/Sudoku_solved_by_bactracking.gif",
                        fit: BoxFit.contain,
                      )),
                  SizedBox(height: 10),
                  Text(
                    "Solving",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  )
                ]),
              ),
            )),
      ]),
    );
  }
}
