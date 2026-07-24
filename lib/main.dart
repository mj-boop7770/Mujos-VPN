import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

// Instance globale du noyau V2Ray
final FlutterV2ray flutterV2ray = FlutterV2ray();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation obligatoire avant de charger l'interface
  await flutterV2ray.initializeV2Ray();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Octopus VPN',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  
  // Remplacer par votre propre lien de serveur (VLESS, VMess, Trojan, etc.)
  String serverConfig = "vless://00000000-0000-0000-0000-000000000000@v2ray.example.com:443?type=ws&security=tls#Octopus-Server";

  Future<void> toggleVpn() async {
    if (isConnected) {
      await flutterV2ray.stopV2Ray();
      setState(() => isConnected = false);
    } else {
      if (await flutterV2ray.requestPermission()) {
        final V2RayURL parsedUrl = FlutterV2ray.parseFromURL(serverConfig);
        await flutterV2ray.startV2Ray(
          remark: parsedUrl.remark,
          config: parsedUrl.fullConfiguration,
          proxyOnly: false,
        );
        setState(() => isConnected = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Octopus VPN Core')),
      body: Center(
        child: ElevatedButton(
          onPressed: toggleVpn,
          style: ElevatedButton.styleFrom(
            backgroundColor: isConnected ? Colors.red : Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          child: Text(
            isConnected ? 'STOP' : 'START',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
