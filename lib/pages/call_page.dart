import 'package:videoapp/model/user.dart';
import 'package:videoapp/utils/settings.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;

  const CallPage({Key? key, this.channelName}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  Map<int, User> _userMap = new Map<int, User>();
  bool _muted = false;
  int? _localUid;

  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  bool isVisible = false;

  @override
  void dispose() {
    //clear users
    _userMap.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      print("'APP_ID missing, please provide your APP_ID in settings.dart");
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.joinChannel(TOKEN, widget.channelName ?? "", null, 0);
    await _engine.joinChannel(TOKEN, 'test', null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    // Enables the audioVolumeIndication
    await _engine.enableAudioVolumeIndication(250, 3, true);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess ${channel} ${uid}');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group call"),
      ),
      body: Stack(
        children: [_buildGridVideoView(), _toolbar()],
      ),
    );
  }

  _buildGridVideoView() {
    return Stack(
      children: [
        Center(
          child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _switch = !_switch;
                });
              },
              child: Center(
                child:
                _switch ? _renderLocalPreview() : _renderRemoteVideo(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return const Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: "test",
      );
    } else {
      return const Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              color: _muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: _muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchVideo,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isVisible ? Colors.white : Colors.blue),
              child: isVisible
                  ? Icon(
                Icons.visibility,
                color: Colors.blue,
                size: 20,
              )
                  : Icon(
                Icons.visibility_off,
                color: Colors.white,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onSwitchVideo() {
    setState(() {
      isVisible = !isVisible;
    });

    //_engine.muteLocalVideoStream(isVisible);
    _engine.enableLocalVideo(isVisible);

    // if(isVisible){
    //   _engine.enableVideo();
    // }else {
    //   _engine.disableVideo();
    // }
    //_engine.muteLocalAudioStream(_muted);
  }
}