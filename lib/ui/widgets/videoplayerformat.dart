import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support_agent/ui/shared/color.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerFormat extends StatefulWidget {
  final String url, messageType;
  VideoPlayerFormat({@required this.url, this.messageType});

  @override
  _VideoPlayerFormatState createState() => _VideoPlayerFormatState();
}

class _VideoPlayerFormatState extends State<VideoPlayerFormat> {
  VideoPlayerController _controller;
  bool startedPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {
          startedPlaying = true;
        }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return startedPlaying
        ? Container(
            width: 250,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          )
        : Text("Loading Video...",
            style: GoogleFonts.roboto(
                fontSize: 15,
                // fontWeight: FontWeight.w700,
                color:
                    widget.messageType == "USER" ? Colors.white : AccentBlue));
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
