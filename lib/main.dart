import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Measurable of async vs isolate'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  String result = '';
  Duration takenTime = Duration.zero;
  Stopwatch stopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isLoading == true ? const CircularProgressIndicator() : Container(),
            const SizedBox(height: 8),
            Text(
              result.isNotEmpty ? result : 'Please press the button to start',
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFloatingActionButton(
            executeFuntion: () => executeAsyncFunction(),
            label: 'Run async',
          ),
          const SizedBox(width: 16),
          _buildFloatingActionButton(
            executeFuntion: () => executeIsolateFunction(),
            label: 'Run isolate',
          ),
        ],
      ),
    );
  }

  _buildFloatingActionButton({
    required Function() executeFuntion,
    required String label,
  }) {
    return FloatingActionButton.extended(
      label: Text(label),
      onPressed: executeFuntion,
      tooltip: 'Increment',
    );
  }

  executeAsyncFunction() async {
    isLoading = true;
    stopwatch.start();

    setState(() {});

    takenTime = stopwatch.elapsed;
    await runAsyncFunction();
    result = takenTime.toString();

    isLoading = false;
    setState(() {});
  }

  executeIsolateFunction() async {
    isLoading = true;
    stopwatch.start();

    setState(() {});

    var receivePort = ReceivePort();

    // await Isolate.spawn(runIsolateFunction, receivePort.sendPort);
    takenTime = stopwatch.elapsed;
    // var isolateResult = await receivePort.first;

    var isolateResult = await compute<String, int>(
        runIsolateComputeFunction, 'This message from compute');
    result = takenTime.toString();

    log('compute result: $isolateResult');

    isLoading = false;
    setState(() {});
  }

  runAsyncFunction() async {
    var number = 0;
    await Future.delayed(const Duration(seconds: 5));

    for (var i = 0; i < 1000000000; i++) {
      number += i;
    }
    log('async: $number');
  }
}

runIsolateFunction(SendPort mainSendPort) async {
  var number = 0;

  await Future.delayed(const Duration(seconds: 5));

  for (var i = 0; i < 1000000000; i++) {
    number += i;
  }

  mainSendPort.send(number);
  log('isolate: $number');
}

Future<int> runIsolateComputeFunction(String message) async {
  var number = 0;

  await Future.delayed(const Duration(seconds: 5));

  for (var i = 0; i < 1000000000; i++) {
    number += i;
  }

  log('compute: $message');
  return number;
}
