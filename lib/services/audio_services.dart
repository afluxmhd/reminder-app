import 'package:audioplayers/audioplayers.dart';

class AudioServices {
  static playAudio(String url) async {
    final AudioPlayer player = AudioPlayer();
    var path = AssetSource(url);
    player.play(path);
  }
}
