import 'package:audioplayers/audio_cache.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

AudioPlayer advancedPlayer;
AudioCache audioCache;

void initPlayer() {
  advancedPlayer = AudioPlayer();
  audioCache = AudioCache(fixedPlayer: advancedPlayer, prefix: 'sounds/');
}

Future<void> playSound(String url) async {
  await audioCache.play(url);
  return;
}
