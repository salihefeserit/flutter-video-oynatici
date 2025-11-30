import 'package:flutter/material.dart';
import 'package:video_odev/VideoScreenPage.dart';

void main() => runApp(const VideoApp());

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        )
      ),
      home: VideoScreen(),
    );
  }
}
