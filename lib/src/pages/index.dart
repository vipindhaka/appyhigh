import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
//import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';

import './call.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  static const _adUnitId = 'ca-app-pub-3940256099942544/2247696110';
  //final _nativeAdMob = NativeAdmob();
  final _nativeAdController = NativeAdmobController();
  double _height = 0;

  StreamSubscription _subscription;
  @override
  void initState() {
    _subscription = _nativeAdController.stateChanged.listen(_onStateChanged);
    //_nativeAdMob.initialize(appID: 'ca-app-pub-8549334720437751~3444336048');
    super.initState();
  }

  void _onStateChanged(AdLoadState state) {
    switch (state) {
      case AdLoadState.loading:
        setState(() {
          _height = 0;
        });
        break;

      case AdLoadState.loadCompleted:
        setState(() {
          _height = 330;
        });
        break;

      default:
        break;
    }
  }

  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;
  // bool _isLoading = false;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    //_nativeAdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Chat App'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Channel name',
                    ),
                  ))
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: NativeAdmob(
                        // Your ad unit id
                        adUnitID: _adUnitId,
                        controller: _nativeAdController,

                        // Don't show loading widget when in loading state
                        loading: Container(),
                      ),
                    ),
                    // NativeAdmobBannerView(
                    //   adUnitID: _adUnitId,
                    //   showMedia: true,
                    //   style: BannerStyle.dark,
                    //   //contentPadding: EdgeInsets.fromLTRB(9.0, 8.0, 8.0, 8.0),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      // _isLoading = true;
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      final rooms =
          await FirebaseFirestore.instance.collection('rooms').limit(1).get();
      if (rooms.docs.length >= 1) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc('vipin')
            .update({'user2': _channelController.text});
      }
      if (rooms.docs.length <= 0) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(_channelController.text)
            .set({'user1': _channelController.text});
      }

      //print(rooms.docs.length);

      // push video page with given channel name
      //_isLoading = false;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: rooms.docs.length > 0
                ? rooms.docs[0].id
                : _channelController.text,
            role: _role,
          ),
        ),
      );
      if (result == true)
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('No User Available')));
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
