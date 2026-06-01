import 'package:flutter/material.dart';
import 'smart bulb.dart';
import 'smart fan.dart';
import 'smart socket.dart';
import 'smart speaker.dart';
class Wifi_Device extends StatefulWidget {
  const Wifi_Device({super.key});

  @override
  State<Wifi_Device> createState() => _Wifi_DeviceState();
}

class _Wifi_DeviceState extends State<Wifi_Device> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add device'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Devices',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _DeviceCard(
                    label: 'Smart Bulb',
                    assetPath: 'assets/smart bulb.jpg',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const smart_bulb()),
                      );
                    },
                  ),
                  _DeviceCard(
                    label: 'Smart Fan',
                    assetPath: 'assets/smart fan.jpg',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const smart_fan()),
                      );
                    },
                  ),
                  _DeviceCard(
                    label: 'Smart Socket',
                    assetPath: 'assets/smart socket.jpg',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const smart_socket()),
                      );
                    },
                  ),
                  _DeviceCard(
                    label: 'Smart Speaker',
                    assetPath: 'assets/smart speaker.jpg',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const smart_speaker()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String label;
  final String assetPath;
  final VoidCallback onPressed;

  const _DeviceCard({super.key, required this.label, required this.assetPath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
