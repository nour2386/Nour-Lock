import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service_plus_android/flutter_background_service_plus_android.dart';
import 'package:flutter_speech_to_text/flutter_speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

const MethodChannel _lockChannel = MethodChannel('com.nour.app/lock');

// دالة الخدمة — يجب أن تكون top-level
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final SpeechToText speech = SpeechToText();
  final AudioPlayer audioPlayer = AudioPlayer();

  await speech.initialize();
  speech.onResult.listen((result) async {
    if (result.recognizedWords.toLowerCase().trim() == 'lock phone') {
      // تشغيل الصوت
      await audioPlayer.play(AssetSource('G.mp3'));
      
      // قفل الشاشة
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        await _lockChannel.invokeMethod('lockScreen');
      } catch (e) {
        debugPrint('Lock failed: $e');
      }
    }
  });

  speech.onEnd.listen((_) {
    // إعادة التشغيل التلقائي إذا انتهى الاستماع
    if (service is AndroidServiceInstance) {
      speech.start();
    }
  });

  await speech.start();

  // الاستماع لأوامر إيقاف الخدمة
  service.on('stopService').listen((event) {
    speech.stop();
    audioPlayer.dispose();
    service.stopSelf();
  });
}