import 'package:flutter/material.dart';
import './dsp_dart/synth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter-Faust Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Faust with Dart:ffi'),
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
  static const _bufferSize = 512;
  static const _sampleRate = 44100;
  final Synth _synth = Synth(_bufferSize,_sampleRate);
  bool _gate = false;

  void _toggleGate() {
    setState(() {
      _gate= !_gate;
      if(_gate){
        playSynth();
      } else {
        _synth.isPlaying = false;
      }
    });
  }

  Future<void> playSynth() async {
    await for (final value in _synth.play()) {
      //value = List<Float32List>
      print('.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _gate ? 'Currently Playing!' : 'Currently Silent',
            ),
            Text(
              '$_gate',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleGate,
        tooltip: _gate ? 'Stop' : 'Start',
        child:   _gate ? const Icon(Icons.pause_circle) : 
                         const Icon(Icons.play_circle),
      ),
    );
  }
}
