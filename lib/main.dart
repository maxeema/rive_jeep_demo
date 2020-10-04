import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gone fishing.',
      home: Scaffold(
        body: MyRiveAnimation(),
      ),
    );
  }
}

class MyRiveAnimation extends StatefulWidget {
  @override
  _MyRiveAnimationState createState() => _MyRiveAnimationState();
}

class _MyRiveAnimationState extends State<MyRiveAnimation> {
  final riveFileName = 'assets/off_road_car.riv';
  Artboard _artboard;
  WiperAnimation _wipersController;
  SimpleAnimation _idleController;
  // Flag to turn wipers on and off
  bool _wipers = false;
  bool get isPlaying => _idleController?.isActive ?? false;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile();

    if (file.import(bytes)) {
      setState(() {
        _artboard = file.mainArtboard
        ..addController(
          _idleController = SimpleAnimation('idle'),
        );
      });
    }
  }

  void _wipersChange(bool wipersOn) {
    if (_wipersController == null) {
      _artboard.addController(
        _wipersController = WiperAnimation('windshield_wipers'),
      );
    }
    if (wipersOn) {
      _wipersController.start();
    } else {
      _wipersController.stop();
    }
    setState(() => _wipers = wipersOn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _artboard != null
              ? Rive(
            artboard: _artboard,
            fit: BoxFit.cover,
          )
              : Container(),
        ),
        Positioned(
          bottom: 40, left: 40,
          child: SizedBox(
            height: 50,
            width: 200,
            child: SwitchListTile(
              title: Text('Wipers', style: TextStyle(color: Colors.white),),
              value: _wipers,
              onChanged: _wipersChange,
            ),
          ),
        ),
        Positioned(
          right: 40, bottom: 40,
          child: FloatingActionButton(
            onPressed: _togglePlay,
            tooltip: isPlaying ? 'Pause' : 'Play',
            child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        )
      ],
    );
  }

  void _togglePlay() {
    setState(() => _idleController.isActive = !_idleController.isActive);
  }
}

class WiperAnimation extends SimpleAnimation {
  WiperAnimation(String animationName) : super(animationName);

  start() {
    instance.animation.loop = Loop.loop;
    isActive = true;
  }

  stop() => instance.animation.loop = Loop.oneShot;
}