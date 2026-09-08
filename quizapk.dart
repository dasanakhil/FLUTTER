import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the capital of India?',
      'options': ['Mumbai', 'Delhi', 'Chennai', 'Kolkata'],
      'answer': 'Delhi',
    },
    {
      'question': 'Which language is used to build Flutter apps?',
      'options': ['Java', 'Python', 'Dart', 'C++'],
      'answer': 'Dart',
    },
    {
      'question': 'Which company developed Flutter?',
      'options': ['Microsoft', 'Google', 'Apple', 'Amazon'],
      'answer': 'Google',
    },
    {
      'question': 'How many days are there in a week?',
      'options': ['5', '6', '7', '8'],
      'answer': '7',
    },
    {
      'question': 'Which widget is commonly used for text in Flutter?',
      'options': ['Text', 'Button', 'Image', 'Container'],
      'answer': 'Text',
    },
  ];

  void checkAnswer(String selectedAnswer) {
    if (selectedAnswer == questions[currentQuestion]['answer']) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Quiz Completed!',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Your score is $score / ${questions.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  setState(() {
                    currentQuestion = 0;
                    score = 0;
                  });
                },
                child: const Text('Restart Quiz'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestion + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
            ),

            const SizedBox(height: 40),

            Text(
              question['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ...question['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
