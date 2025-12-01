import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class FullScreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenPlayer({super.key, required this.controller});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  bool _muted = false;
  bool _looping = true;

  late double _dragStartHorizontalPosition;
  late double _currentVolume;

  void _handleVolumeGesture(double currentDy) {
    final double dy = _dragStartHorizontalPosition - currentDy;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double volumeChange = dy / (screenHeight / 2);
    final double newVolume = (_currentVolume + volumeChange).clamp(0.0, 1.0);

    widget.controller.setVolume(newVolume);
    newVolume == 0 ? _muted = true : _muted = false;
    setState(() {});
  }

  @override
  void initState() {
    _enterFullScreen();
    super.initState();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  Future<void> _enterFullScreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullScreen() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes;
    final s = d.inSeconds;
    return h > 0 ? "${two(h)}:${two(m)}:${two(s)}" : "${two(m)}:${two(s)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onVerticalDragStart: (details) {
            _dragStartHorizontalPosition = details.globalPosition.dy;
            _currentVolume = widget.controller.value.volume;
          },
          onVerticalDragUpdate: (details) {
            _handleVolumeGesture(details.globalPosition.dy);
          },
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(widget.controller),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (context, VideoPlayerValue value, child) {
                      if (value.hasError) Text("Hata: ${value.errorDescription}");
                      return controlCard(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox controlCard(VideoPlayerValue value) {
    return SizedBox(
      height: 100,
      child: Card(
        elevation: 4,
        margin: const EdgeInsetsGeometry.symmetric(horizontal: 50, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 5),
                Text(_format(value.position)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: value.position.inMilliseconds.toDouble().clamp(
                        0,
                        value.duration.inMilliseconds.toDouble(),
                      ),
                      min: 0,
                      max: value.duration.inMilliseconds == 0
                          ? 0
                          : value.duration.inMilliseconds.toDouble(),
                      onChanged: (ms) async {
                        await widget.controller.seekTo(Duration(milliseconds: ms.toInt()));
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Text(_format(value.duration)),
                const SizedBox(width: 5),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// Oynat
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      value.isPlaying ? widget.controller.pause() : widget.controller.play();
                    });
                  },
                  icon: value.isPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                ),

                /// Geri Sar
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final back = value.position - const Duration(seconds: 10);
                    widget.controller.seekTo(
                      back > const Duration(seconds: 0) ? back : Duration.zero,
                    );
                  },
                  icon: const Icon(Icons.replay_10),
                ),

                /// İleri Sar
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final forward = value.position + const Duration(seconds: 10);
                    widget.controller.seekTo(
                      forward < value.duration ? forward : value.duration,
                    );
                  },
                  icon: Icon(Icons.forward_10),
                ),

                /// Ses
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    setState(() => _muted = !_muted);
                    await widget.controller.setVolume(_muted ? 0.0 : 1.0);
                  },
                  icon: _muted ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
                ),

                /// Loop
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _looping = !_looping);
                    widget.controller.setLooping(_looping);
                  },
                  icon: _looping ? const Icon(Icons.repeat_one) : const Icon(Icons.repeat),
                  color: _looping ? Colors.red : Colors.white,
                ),

                /// Full Ekran
                IconButton(
                  iconSize: 22,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.fullscreen_exit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




