import 'dart:async';
import 'dart:io'; // For Platform.isIOS
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colour_change.dart'; // Import your ColorWheelPainter/ColourChange
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Wifi_Devices.dart';

class ConnectWifiScreen extends StatelessWidget {
  const ConnectWifiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect WiFi'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Firstly connect WiFi manually',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WiFiProvisionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'CONNECT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Provisioner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const WiFiProvisionScreen(),
    );
  }
}

class WiFiProvisionScreen extends StatefulWidget {
  const WiFiProvisionScreen({super.key});

  @override
  State<WiFiProvisionScreen> createState() => _WiFiProvisionScreenState();
}

class _WiFiProvisionScreenState extends State<WiFiProvisionScreen> {
  String? _connectedSSID;
  String? _connectedBSSID;
  Timer? _timer;
  bool _hasRequestedLocationPermission = false;
  bool _hasRequestedNetworkPermission = false;
  bool _showAddText = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndFetchNetworkInfo();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchCurrentNetworkInfo();
    });
  }

  Future<void> _requestPermissionsAndFetchNetworkInfo() async {
    final locationStatus = await Permission.locationWhenInUse.status;
    if (!_hasRequestedLocationPermission || locationStatus.isDenied) {
      if (!locationStatus.isGranted) {
        final requestStatus = await Permission.locationWhenInUse.request();
        setState(() {
          _hasRequestedLocationPermission = true;
        });
        if (!requestStatus.isGranted) {
          _showMessage('Location permission is required to fetch WiFi info.');
          return;
        }
      }
    }

    if (Platform.isIOS && !_hasRequestedNetworkPermission) {
      final localNetworkStatus = await Permission.nearbyWifiDevices.status;
      if (!localNetworkStatus.isGranted) {
        final requestStatus = await Permission.nearbyWifiDevices.request();
        setState(() {
          _hasRequestedNetworkPermission = true;
        });
        if (!requestStatus.isGranted) {
          _showMessage('Local network access is required on iOS.');
          return;
        }
      }
    }

    await _fetchCurrentNetworkInfo();
  }

  Future<void> _fetchCurrentNetworkInfo() async {
    final networkInfo = NetworkInfo();
    try {
      String? currentSSID = await networkInfo.getWifiName();
      if (currentSSID != null) currentSSID = currentSSID.replaceAll('"', '');
      String? currentBSSID = await networkInfo.getWifiBSSID();

      setState(() {
        _connectedSSID = currentSSID ?? 'Not connected';
        _connectedBSSID = currentBSSID ?? 'Unknown';
      });

      debugPrint('📶 Current SSID: $_connectedSSID');
      debugPrint('🔑 Current BSSID: $_connectedBSSID');

      if (currentSSID == 'ESP_APPCODIE') debugPrint("✅ Connected to ESP device!");
    } catch (e, stackTrace) {
      _showMessage('Error fetching network info: $e');
      debugPrint('Error fetching network info: $e\n$stackTrace');
      setState(() {
        _connectedSSID = 'Not connected';
        _connectedBSSID = 'Unknown';
      });
    }
  }

  Future<void> sendWifiCredentials(String ssid, String password) async {
    const url = 'http://192.168.5.2/connect';
    final body = jsonEncode({"ssid": ssid.trim(), "password": password.trim()});
    debugPrint("📤 Sending JSON to ESP: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('POST request timed out'),
      );

      if (response.statusCode == 200) {
        _showMessage("✅ Credentials sent: ${response.body}");
      } else {
        _showMessage("❌ Failed: HTTP ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      _showMessage("Error sending WiFi credentials: $e");
      debugPrint('Error sending WiFi credentials: $e\n$stackTrace');
    }
  }

  Future<void> _provisionWiFi() async {
    final ssidController = TextEditingController(text: "Appcodie");
    final passwordController = TextEditingController(text: "appcodie@324");

    final String? homeSSID = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Provision WiFi'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: ssidController,
                decoration: const InputDecoration(labelText: 'Home WiFi SSID'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Home WiFi Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final ssid = ssidController.text.trim();
              if (ssid.isNotEmpty) Navigator.pop(context, ssid);
              else _showMessage('SSID is required.');
            },
            child: const Text('Send WiFi Credentials'),
          ),
        ],
      ),
    );

    if (homeSSID == null || passwordController.text.isEmpty) {
      _showMessage('Provisioning cancelled: SSID and password required.');
      return;
    }

    await sendWifiCredentials(homeSSID, passwordController.text);
  }

  void _showMessage(String message) {
    debugPrint(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') || message.contains('❌') ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Provisioner'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_showAddText)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Wifi_Device()),
                ).then((_) {
                  if (mounted) {
                    setState(() {
                      _showAddText = false;
                    });
                  }
                });
              },
              child: const Text(
                'Add Device',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add',
              onPressed: () {
                setState(() {
                  _showAddText = true;
                });
              },
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/connected.jpeg', height: 150, width: 150),
              const SizedBox(height: 24),
              Text(
                'Current WiFi: $_connectedSSID',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _provisionWiFi,
                    child: const Text('Provision WiFi'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ColourChange()),
                      );
                    },
                    child: const Text('Change Color'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
