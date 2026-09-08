import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  double? firstNumber;
  String? operator;

  void numberPressed(String number) {
    setState(() {
      if (display == '0') {
        display = number;
      } else {
        display += number;
      }
    });
  }

  void operatorPressed(String op) {
    setState(() {
      firstNumber = double.tryParse(display);
      operator = op;
      display = '0';
    });
  }

  void calculate() {
    if (firstNumber == null || operator == null) return;

    double secondNumber = double.tryParse(display) ?? 0;
    double result = 0;

    switch (operator) {
      case '+':
        result = firstNumber! + secondNumber;
        break;
      case '-':
        result = firstNumber! - secondNumber;
        break;
      case '×':
        result = firstNumber! * secondNumber;
        break;
      case '÷':
        if (secondNumber == 0) {
          display = 'Error';
          firstNumber = null;
          operator = null;
          return;
        }
        result = firstNumber! / secondNumber;
        break;
    }

    setState(() {
      display = result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(2);

      firstNumber = null;
      operator = null;
    });
  }

  void clear() {
    setState(() {
      display = '0';
      firstNumber = null;
      operator = null;
    });
  }

  Widget calculatorButton(
    String text, {
    VoidCallback? onPressed,
    Color? color,
    Color? textColor,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[850],
            foregroundColor: textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(25),
              child: Text(
                display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Column(
              children: [
                Row(
                  children: [
                    calculatorButton(
                      'C',
                      onPressed: clear,
                      color: Colors.red,
                    ),
                    calculatorButton(
                      '÷',
                      onPressed: () => operatorPressed('÷'),
                      color: Colors.orange,
                    ),
                    calculatorButton(
                      '×',
                      onPressed: () => operatorPressed('×'),
                      color: Colors.orange,
                    ),
                    calculatorButton(
                      '-',
                      onPressed: () => operatorPressed('-'),
                      color: Colors.orange,
                    ),
                  ],
                ),
                Row(
                  children: [
                    calculatorButton(
                      '7',
                      onPressed: () => numberPressed('7'),
                    ),
                    calculatorButton(
                      '8',
                      onPressed: () => numberPressed('8'),
                    ),
                    calculatorButton(
                      '9',
                      onPressed: () => numberPressed('9'),
                    ),
                    calculatorButton(
                      '+',
                      onPressed: () => operatorPressed('+'),
                      color: Colors.orange,
                    ),
                  ],
                ),
                Row(
                  children: [
                    calculatorButton(
                      '4',
                      onPressed: () => numberPressed('4'),
                    ),
                    calculatorButton(
                      '5',
                      onPressed: () => numberPressed('5'),
                    ),
                    calculatorButton(
                      '6',
                      onPressed: () => numberPressed('6'),
                    ),
                    calculatorButton(
                      '=',
                      onPressed: calculate,
                      color: Colors.green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    calculatorButton(
                      '1',
                      onPressed: () => numberPressed('1'),
                    ),
                    calculatorButton(
                      '2',
                      onPressed: () => numberPressed('2'),
                    ),
                    calculatorButton(
                      '3',
                      onPressed: () => numberPressed('3'),
                    ),
                    calculatorButton(
                      '0',
                      onPressed: () => numberPressed('0'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
