import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_v2ray/flutter_v2ray.dart';

class V2RayService {
  late final FlutterV2ray _v2ray;
  
  // Callback personnalisé pour notifier la vue des changements d'état
  Function(String status, bool isConnected)? _onStatusChangeCallback;

  V2RayService() {
    // Le paramètre 'onStatusChanged' est désormais obligatoire à l'instanciation
    _v2ray = FlutterV2ray(
      onStatusChanged: (status) {
        if (_onStatusChangeCallback != null) {
          final statusString = status.state.toString();
          final isConnected = statusString.contains("CONNECTED");
          _onStatusChangeCallback!(statusString, isConnected);
        }
      },
    );
  }

  /// Initialise le noyau V2Ray et récupère sa version
  Future<String> initialize() async {
    await _v2ray.initializeV2Ray();
    return await _v2ray.getCoreVersion();
  }

  /// Écoute les changements d'état du tunnel en temps réel
  void listenStatus(Function(String status, bool isConnected) onStatusChange) {
    _onStatusChangeCallback = onStatusChange;
  }

  /// Démarre ou arrête la connexion VPN
  Future<bool> toggleConnection({
    required bool currentStatus,
    required String configPath,
    required Function(String error) onError,
  }) async {
    if (currentStatus) {
      await _v2ray.stopV2Ray();
      return false;
    } else {
      try {
        // Demande de permission au système Android
        final hasPermission = await _v2ray.requestPermission();
        if (!hasPermission) {
          onError("Permission VPN refusée par l'utilisateur.");
          return false;
        }

        // Chargement du fichier de configuration JSON
        final configString = await rootBundle.loadString(configPath);

        // Lancement du tunnel VPN global
        await _v2ray.startV2Ray(
          remark: "Octopus Core Node",
          config: configString,
          proxyOnly: false, // Route tout le trafic du téléphone
        );
        return true;
      } catch (e) {
        onError("Erreur d'initialisation : $e");
        return false;
      }
    }
  }
}
