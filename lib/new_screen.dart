import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class New_Screen extends StatefulWidget {
  const New_Screen({super.key});

  @override
  State<New_Screen> createState() => _New_ScreenState();
}

class _New_ScreenState extends State<New_Screen> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _switch1 = false;
  bool _switch2 = false;
  bool _switch3 = false;

  double _temperature = 0.0;
  double _voltage = 0.0;
  double _humidity = 0.0;

  double _durationMinutes = 5; // Default duration
  Timer? _relay1Timer;

  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref('esp32_data/6C:C8:40:4E:7E:58');
  final DatabaseReference _controlRef =
  FirebaseDatabase.instance.ref('esp32_control');

  StreamSubscription<DatabaseEvent>? _sensorSubscription;
  StreamSubscription<DatabaseEvent>? _controlSubscription;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen();
  }

  Future<void> _initFirebaseAndListen() async {
    await Firebase.initializeApp();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'esp32-farm@appcodie.com',
        password: 'Mohali@324',
      );
      debugPrint('✅ Signed in as esp32-farm@appcodie.com');
    } catch (e) {
      debugPrint('❌ Firebase Auth sign-in failed: $e');
    }

    // ✅ Ensure relay2 & relay3 start false
    await _updateRelayState('relay2', false);
    await _updateRelayState('relay3', false);

    _setupFirebaseListener();
  }

  void _setupFirebaseListener() {
    // Listen for sensor data
    _sensorSubscription = _databaseRef.onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value;
      if (data is Map) {
        setState(() {
          _temperature = _parseLatestValue(data['temperature']);
          _voltage = _parseLatestValue(data['voltage']);
          _humidity = _parseLatestValue(data['humidity']);
        });
      }
    });

    // Listen for control state updates
    _controlSubscription = _controlRef.onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value;

      if (data is Map) {
        setState(() {
          // ✅ Handle relay1 object format
          if (data['relay1'] is Map) {
            _switch1 = data['relay1']['state'] == true;
            final duration = data['relay1']['duration'];
            if (duration != null) {
              _durationMinutes = double.tryParse(duration.toString()) ?? 5;
            }
          } else {
            _switch1 = data['relay1'] == true;
          }

          // ✅ Ensure relay2 and relay3 are false if not found
          _switch2 = data['relay2'] == true;
          _switch3 = data['relay3'] == true;
        });
      } else {
        // ✅ No data in Firebase, set defaults
        setState(() {
          _switch2 = false;
          _switch3 = false;
        });
        _updateRelayState('relay2', false);
        _updateRelayState('relay3', false);
      }
    });
  }

  double _parseLatestValue(dynamic raw) {
    if (raw == null) return 0;
    try {
      final parts = raw.toString().trim().split(' ');
      return double.parse(parts.last);
    } catch (e) {
      debugPrint('Error parsing value: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _controlSubscription?.cancel();
    _relay1Timer?.cancel();
    super.dispose();
  }

  // ✅ Updated to store relay1 as an object
  Future<void> _updateRelayState(String relay, bool value,
      {int? duration}) async {
    try {
      if (relay == 'relay1') {
        await _controlRef.update({
          relay: {
            "state": value,
            "duration": duration ?? _durationMinutes.toInt(),
          }
        });
      } else {
        await _controlRef.update({relay: value});
      }

      debugPrint('✅ Updated $relay to $value');
    } catch (e) {
      debugPrint('❌ Failed to update $relay: $e');
      if (mounted) {
        setState(() {
          if (relay == 'relay1') _switch1 = !_switch1;
          if (relay == 'relay2') _switch2 = !_switch2;
          if (relay == 'relay3') _switch3 = !_switch3;
        });
      }
    }
  }

  // ✅ Auto-off logic for relay1
  void _handleSwitch1Toggle(bool value) {
    setState(() => _switch1 = value);

    _relay1Timer?.cancel(); // Cancel previous timer

    if (value) {
      double tempMinutes = _durationMinutes;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setLocalState) {
              return AlertDialog(
                title: const Text('Set Auto Cut Time'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Auto Cut: ${tempMinutes.toInt()} min',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: tempMinutes,
                      min: 1,
                      max: 60,
                      divisions: 59,
                      label: '${tempMinutes.toInt()} min',
                      onChanged: (v) => setLocalState(() => tempMinutes = v),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      ).then((confirmed) {
        if (!mounted) return;
        if (confirmed == true) {
          setState(() => _durationMinutes = tempMinutes);
          _updateRelayState('relay1', true,
              duration: _durationMinutes.toInt());

          _relay1Timer = Timer(
            Duration(minutes: _durationMinutes.toInt()),
                () {
              if (mounted) {
                setState(() => _switch1 = false);
                _updateRelayState('relay1', false,
                    duration: _durationMinutes.toInt());
                debugPrint(
                    '⏰ Relay1 turned OFF after $_durationMinutes minutes');
              }
            },
          );
        } else {
          setState(() => _switch1 = false);
          _updateRelayState('relay1', false);
        }
      });
    } else {
      _updateRelayState('relay1', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Device List'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch 1 (Timer Controlled)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Switch 1',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: _switch1,
                    onChanged: _handleSwitch1Toggle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Auto Cut: ${_durationMinutes.toInt()} min',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: _durationMinutes,
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: '${_durationMinutes.toInt()} min',
                        onChanged: _switch1
                            ? (v) => setState(() => _durationMinutes = v)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Switch 2',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              value: _switch2,
              onChanged: (v) {
                setState(() => _switch2 = v);
                _updateRelayState('relay2', v);
              },
            ),
            SwitchListTile(
              title: const Text('Switch 3',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              value: _switch3,
              onChanged: (v) {
                setState(() => _switch3 = v);
                _updateRelayState('relay3', v);
              },
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 12),
            const Text(
              'Sensor Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildSensorCard(Icons.thermostat, 'Temperature',
                      '${_temperature.toStringAsFixed(1)}°C', Colors.red),
                  _buildSensorCard(Icons.electrical_services, 'Voltage',
                      '${_voltage.toStringAsFixed(2)}V', Colors.blue),
                  _buildSensorCard(Icons.water_drop, 'Humidity',
                      '${_humidity.toStringAsFixed(1)}%', Colors.cyan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(
      IconData icon, String title, String value, Color color) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
