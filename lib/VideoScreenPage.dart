import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'VideoFullScreenPage.dart';
import 'Video.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController ?_controller;
  late Future<void> _initFuture;

  bool _muted = false;
  bool _looping = true;

  late double _dragStartHorizontalPosition;
  late double _currentVolume;

  void _handleVolumeGesture(double currentDy) {
    final double dy = _dragStartHorizontalPosition - currentDy;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double volumeChange = dy / (screenHeight / 10);
    final double newVolume = (_currentVolume + volumeChange).clamp(0.0, 1.0);

    _controller!.setVolume(newVolume);
    newVolume == 0 ? _muted = true : _muted = false;
    setState(() {});
  }

  void adjustPlayer(Uri vdo) {
    if (_controller != null) {
      _controller!.dispose();
    }
    final newController = VideoPlayerController.networkUrl(
      vdo,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = newController;

    _initFuture = _controller!.initialize().then((_) {
      setState(() {});
    });

    _controller!.setLooping(_looping);
    _controller!.setVolume(1.0);
  }

  @override
  void initState() {
    super.initState();
    adjustPlayer(videos.first.baglanti);
    /* ValueListenableBuilder'e taşındı.
    _controller.addListener(() {
      setState(() {});

      if (_controller.value.hasError)
        debugPrint("Video Error: ${_controller.value.errorDescription}");
    });
     */
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Video Oynatıcı",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = _controller!.value;

          if (value.hasError) {
            return Center(child: Text("Hata: ${value.errorDescription}"));
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onVerticalDragStart: (details) {
                  _dragStartHorizontalPosition = details.globalPosition.dy;
                  _currentVolume = _controller!.value.volume;
                },
                onVerticalDragUpdate: (details) {
                  _handleVolumeGesture(details.globalPosition.dy);
                },
                child: AspectRatio(
                  aspectRatio: value.aspectRatio == 0
                      ? 16 / 9
                      : value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _controller!,
                builder: (context, VideoPlayerValue value, child) {
                  if (value.hasError) {
                    return Center(
                      child: Text("Hata: ${value.errorDescription}"),
                    );
                  }
                  return controlCard(value);
                },
              ),
              Expanded(
                child: Card(
                  margin: const EdgeInsetsGeometry.only(
                    left: 10,
                    right: 10,
                    bottom: 30,
                    top: 0,
                  ),
                  child: ListView.builder(
                    itemBuilder: (context, index) => videoCard(videos[index]),
                    itemCount: videos.length,
                    padding: const EdgeInsets.all(5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ElevatedButton videoCard(Video vdeo) {
    return ElevatedButton(
      onPressed: () {
        adjustPlayer(vdeo.baglanti);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(vdeo.name)],
      ),
    );
  }

  Card controlCard(VideoPlayerValue value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 6),
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
                      await _controller!.seekTo(
                        Duration(milliseconds: ms.toInt()),
                      );
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
                    value.isPlaying ? _controller!.pause() : _controller!.play();
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
                  final back = value.position - Duration(seconds: 10);
                  _controller!.seekTo(
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
                  final forward = value.position + Duration(seconds: 10);
                  _controller!.seekTo(
                    forward < value.duration ? forward : value.duration,
                  );
                },
                icon: const Icon(Icons.forward_10),
              ),

              /// Ses
              IconButton(
                iconSize: 22,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  setState(() => _muted = !_muted);
                  await _controller!.setVolume(_muted ? 0.0 : 1.0);
                },
                icon: _muted ? const Icon(Icons.volume_off) : const Icon(Icons.volume_up),
              ),

              /// Loop
              IconButton(
                iconSize: 22,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _looping = !_looping);
                  _controller!.setLooping(_looping);
                },
                icon: _looping ? const Icon(Icons.repeat_one) : const Icon(Icons.repeat),
                color: _looping ? Colors.red : Colors.white,
              ),

              /// Full Ekran
              IconButton(
                iconSize: 22,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenPlayer(controller: _controller!),
                    ),
                  );
                },
                icon: const Icon(Icons.fullscreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
