import 'package:flutter/material.dart';
import 'v2ray_service.dart';

void main() {
  runApp(const OctopusVpnApp());
}

class OctopusVpnApp extends StatelessWidget {
  const OctopusVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Octopus Core VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Fond Slate-900
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
        ),
      ),
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
  final V2RayService _v2rayService = V2RayService();

  bool _isConnected = false;
  String _status = "Déconnecté";
  String _coreVersion = "Chargement...";

  @override
  void initState() {
    super.initState();
    _initNetwork();
  }

  void _initNetwork() async {
    // 1. Initialiser V2Ray et récupérer la version
    final version = await _v2rayService.initialize();
    setState(() => _coreVersion = version);

    // 2. Écouter les changements d'état en temps réel
    _v2rayService.listenStatus((status, isConnected) {
      setState(() {
        _status = status;
        _isConnected = isConnected;
      });
    });
  }

  void _toggleVpn() async {
    await _v2rayService.toggleConnection(
      currentStatus: _isConnected,
      configPath: 'assets/config.json',
      onError: (errorMsg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Octopus 🐙 Core'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône d'état
              Icon(
                _isConnected ? Icons.shield_rounded : Icons.shield_outlined,
                size: 96,
                color: _isConnected ? Colors.greenAccent : Colors.white24,
              ),
              const SizedBox(height: 24),

              // État du tunnel
              Text(
                _isConnected ? "Tunnel Actif" : "Tunnel Inactif",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isConnected ? Colors.greenAccent : Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Statut : $_status",
                style: const TextStyle(fontSize: 14, color: Colors.white38),
              ),
              const SizedBox(height: 48),

              // Bouton Start / Stop
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: _toggleVpn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.redAccent : Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isConnected ? "STOP" : "START",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Pied de page
              Text(
                "Noyau V2Ray : $_coreVersion",
                style: const TextStyle(fontSize: 12, color: Colors.white24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
