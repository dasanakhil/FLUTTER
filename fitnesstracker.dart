import 'package:flutter/material.dart';

void main() {
  runApp(FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FitnessHomePage(),
    );
  }
}

class FitnessHomePage extends StatefulWidget {
  @override
  _FitnessHomePageState createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage> {
  List<Map<String, dynamic>> workouts = [];

  TextEditingController workoutController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  void addWorkout() {
    if (workoutController.text.isNotEmpty &&
        caloriesController.text.isNotEmpty) {
      setState(() {
        workouts.add({
          "name": workoutController.text,
          "calories": int.parse(caloriesController.text),
        });
      });

      workoutController.clear();
      caloriesController.clear();
    }
  }

  int getTotalCalories() {
    return workouts.fold(
      0,
      (sum, item) => sum + (item["calories"] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fitness Tracker"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: workoutController,
              decoration: InputDecoration(
                labelText: "Workout Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Calories Burned",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: addWorkout,
              child: Text("Add Workout"),
            ),

            SizedBox(height: 20),

            Text(
              "Total Calories: ${getTotalCalories()}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.fitness_center),
                      title: Text(workouts[index]["name"]),
                      subtitle: Text(
                        "${workouts[index]["calories"]} Calories",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            workouts.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
