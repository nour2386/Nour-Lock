import 'package:flutter/material.dart';
import 'package:flutter_background_service_plus_android/flutter_background_service_plus_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.microphone.request();
  await Permission.notification.request();
  runApp(const NourApp());
}

class NourApp extends StatelessWidget {
  const NourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nour App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isServiceRunning = false;
  String _status = 'متوقف';

  Future<void> _startService() async {
    final service = FlutterBackgroundService();
    
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'nour_listen_channel',
        initialNotificationTitle: 'Nour App يعمل',
        initialNotificationContent: 'يستمع للأوامر الصوتية...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );

    await service.startService();
    setState(() {
      _isServiceRunning = true;
      _status = 'يعمل - قل "Lock Phone"';
    });
  }

  Future<void> _stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    setState(() {
      _isServiceRunning = false;
      _status = 'متوقف';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nour App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isServiceRunning ? Icons.mic : Icons.mic_off,
              size: 80,
              color: _isServiceRunning ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isServiceRunning ? _stopService : _startService,
              icon: Icon(_isServiceRunning ? Icons.stop : Icons.play_arrow),
              label: Text(_isServiceRunning ? 'إيقاف' : 'تشغيل'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}