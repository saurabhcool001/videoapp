import 'dart:async';
import 'package:videoapp/pages/call_page.dart';
import 'package:videoapp/pages/audio_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have an error
  bool _validateError = false;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Flutter video Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                      controller: _channelController,
                      decoration: InputDecoration(
                        errorText:
                        _validateError ? 'Channel name is mandatory' : null,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                        hintText: 'Channel name',
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: onJoinVideo,
                    child: const Text('Join Video'),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10.0)),
                Expanded(child: ElevatedButton(
                  onPressed: onJoinAudio,
                  child: const Text('Voice call'),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
  Future<void> onJoinVideo() async {
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(channelName: _channelController.text),
        ));
  }

  Future<void> onJoinAudio() async {
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    await _handleCameraAndMic(Permission.microphone);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPage(channelName: _channelController.text),
        ));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}