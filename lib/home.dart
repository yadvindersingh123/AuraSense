import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Wifi_Devices.dart';
import 'bottom%20navigation%20bar.dart';
class Home_Screen extends StatefulWidget {
  final bool showBottomBar;
  const Home_Screen({super.key, this.showBottomBar = true});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  // Track single device online/offline status
  bool _isOnline = true;

  Future<void> _seedDevices() async {
    final devices = FirebaseFirestore.instance.collection('devices');
    final snapshot = await devices.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // already seeded

    final batch = FirebaseFirestore.instance.batch();
    final samples = [
      {
        'name': 'Smart Light',
        'type': 'light',
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Smart Fan',
        'type': 'fan',
        'isOnline': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Smart Socket',
        'type': 'socket',
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Smart Speaker',
        'type': 'speaker',
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];
    for (final d in samples) {
      batch.set(devices.doc(), d);
    }
    await batch.commit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample devices added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Digital Home",
        style: TextStyle(
            fontWeight: FontWeight.bold
        ),
      ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
        foregroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios)

        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'add_device') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Bottom_navigation(initialIndex: 1),
                  ),
                );
              } else if (value == 'seed_devices') {
                _seedDevices();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'add_device',
                child: Text('Add Device'),
              ),
              const PopupMenuItem<String>(
                value: 'seed_devices',
                child: Text('Seed Devices'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Connected Devices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('devices')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.devices_other, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No devices yet. Use menu to Seed or Add.')
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final title = (data['name'] as String?) ?? 'Device';
                      final isOnline = (data['isOnline'] as bool?) ?? false;
                      return _SmartDeviceCard(
                        title: title,
                        isOnline: isOnline,
                        onToggleStatus: () async {
                          await doc.reference.update({'isOnline': !isOnline});
                        },
                        onEdit: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Edit ${title}')), 
                          );
                        },
                        onDelete: () async {
                          await doc.reference.delete();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted ${title}')),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomBar
          ? BottomNavigationBar(
              currentIndex: 0,
              selectedItemColor: Colors.teal,
              onTap: (index) {
                if (index == 0) return; // Already on Home
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Bottom_navigation(initialIndex: index),
                  ),
                );
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.devices_outlined),
                  activeIcon: Icon(Icons.devices),
                  label: 'Devices',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}

class _SmartDeviceCard extends StatelessWidget {
  final String title;
  final bool isOnline;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _SmartDeviceCard({
    super.key,
    required this.title,
    required this.isOnline,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.memory, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                } else if (value == 'toggle') {
                  onToggleStatus();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
                PopupMenuItem<String>(
                  value: 'toggle',
                  child: Text('Toggle Online/Offline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
