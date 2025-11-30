import 'dart:core';

class Video {
  final String link;
  final String name;
  final Uri baglanti;

  Video(this.link) : baglanti = Uri.parse(link), name = Uri.parse(link).pathSegments.last;
}

List<Video> videos = [
  Video("https://video-previews.elements.envatousercontent.com/9376b5da-eeec-4497-81ec-24974097b70c/watermarked_preview/watermarked_preview.mp4"),
  Video("https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"),
  Video("https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")
];

