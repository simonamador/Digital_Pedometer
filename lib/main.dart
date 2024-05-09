import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pedometer/pedometer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _stepCountValue = 'Unknown';
  late StreamSubscription _subscription;

  // Definir controladores para los campos de edad, peso y estatura
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setUpPedometer();
  }

  void setUpPedometer() {
    Pedometer pedometer = Pedometer();
    _subscription = Pedometer.stepCountStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void _onData(stepCountValue) async {
    setState(() {
      _stepCountValue = "$stepCountValue";
    });
  }

  void _onDone() {}

  void _onError(error) {
    print("Flutter Pedometer Error: $error");
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Step Counter app'),
          backgroundColor: Colors.black54,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFFA9F5F2), Color(0xFF01DFD7)],
                    ),
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                  child: CircularPercentIndicator(
                    radius: 100.0, // Reducir el tamaño del indicador circular
                    lineWidth: 10.0, // Reducir el ancho de la línea
                    animation: true,
                    center: const Icon(
                      Icons.directions_walk,
                      size: 40.0, // Reducir el tamaño del ícono
                      color: Colors.white,
                    ),
                    percent: 0.217,
                    footer: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Pasos: $_stepCountValue",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0, // Reducir el tamaño del texto
                          color: Colors.purple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: _ageController, // Asignar el controlador
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Edad',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) =>
                      _updateRecommendedSteps(), // Actualizar al cambiar el valor
                ),
                const SizedBox(height: 10.0), // Espacio entre los TextField
                TextField(
                  controller: _weightController, // Asignar el controlador
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) =>
                      _updateRecommendedSteps(), // Actualizar al cambiar el valor
                ),
                const SizedBox(height: 10.0), // Espacio entre los TextField
                TextField(
                  controller: _heightController, // Asignar el controlador
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Estatura (cm)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) =>
                      _updateRecommendedSteps(), // Actualizar al cambiar el valor
                ),
                const SizedBox(height: 20.0),
                _buildInfoCard(
                  'Recomendados: $_recommendedSteps pasos',
                  const AssetImage("assets/images/distance.png"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _recommendedSteps = 0;

  void _updateRecommendedSteps() {
    setState(() {
      _recommendedSteps = calculateRecommendedSteps(
        int.tryParse(_ageController.text) ?? 0,
        double.tryParse(_weightController.text) ?? 0,
        double.tryParse(_heightController.text) ?? 0,
      );
    });
  }

  int calculateRecommendedSteps(int age, double weight, double height) {
    // Factor de actividad física (si es sedentario, poco activo, activo, muy activo)
    double activityFactor = 1.0;

    // Ajuste según la edad (para niños, adolescentes, adultos)
    if (age <= 18) {
      // Para niños y adolescentes
      activityFactor *= 1.3;
    } else if (age <= 64) {
      // Para adultos menores de 65 años
      activityFactor *= 1.0;
    } else {
      // Para adultos mayores de 65 años
      activityFactor *= 0.8;
    }

    // Índice de masa corporal (IMC)
    double bmi = weight / ((height / 100) * (height / 100));

    // Ajuste según el IMC (para personas con bajo peso, peso normal, sobrepeso, obesidad)
    if (bmi < 18.5) {
      // Bajo peso
      activityFactor *= 1.2;
    } else if (bmi < 25) {
      // Peso normal
      activityFactor *= 1.0;
    } else if (bmi < 30) {
      // Sobrepeso
      activityFactor *= 0.8;
    } else {
      // Obesidad
      activityFactor *= 0.6;
    }

    // Calcular los pasos recomendados basados en el factor de actividad física
    return (10000 * activityFactor).toInt();
  }

  Widget _buildInfoCard(String text, ImageProvider<Object> image) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: image,
              height: 40.0,
              width: 40.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
