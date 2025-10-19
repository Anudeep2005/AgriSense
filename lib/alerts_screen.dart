import 'dart:ui';
import 'package:flutter/material.dart';
import 'notifications.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<Map<String, String>> _notifications = [
    {
      'title': 'High Temperature Alert',
      'body': 'Temperature in Wheat Field A has reached 35°C. Consider irrigation.',
      'time': '2h ago',
      'priority': 'High',
      'location': 'Wheat Field A',
    },
    {
      'title': 'Irrigation Scheduled',
      'body': 'Automatic irrigation system activated for Tomato Grove B.',
      'time': '4h ago',
      'priority': 'Low',
      'location': 'Tomato Grove B',
    },
    {
      'title': 'Low Soil Moisture',
      'body': 'Soil moisture levels below optimal range in Field Section 2.',
      'time': '1 day ago',
      'priority': 'Medium',
      'location': 'Field Section 2',
    },
    {
      'title': 'Sensor Malfunction',
      'body': 'pH sensor in Greenhouse 1 requires maintenance check.',
      'time': '2 days ago',
      'priority': 'High',
      'location': 'Greenhouse 1',
    },
  ];

  void _addNotification() {
    setState(() {
      _notifications.insert(0, {
        'title': 'High Temperature Alert',
        'body': 'Temperature in Wheat Field A has reached 35°C. Consider irrigation.',
        'time': 'Just now',
        'priority': 'High',
        'location': 'Wheat Field A',
      });

      Notifications.showNotification(
        title: "🚨 High Temperature",
        body: "Wheat Field A has reached 35°C",
      );
    });
  }

  void _dismissNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            "assets/farm_bg.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          _GlassButton(text: 'High', isSelected: true),
                          SizedBox(width: 10),
                          _GlassButton(text: 'Warnings', isSelected: false),
                          SizedBox(width: 10),
                          _GlassButton(text: 'Info', isSelected: false),
                          SizedBox(width: 10),
                          _GlassButton(text: 'Weather', isSelected: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return _GlassmorphicCard(
                            title: n['title'] ?? 'Alert',
                            body: n['body'] ?? '',
                            time: n['time'] ?? '',
                            priority: n['priority'] ?? 'Low',
                            location: n['location'] ?? 'Unknown',
                            icon: Icons.notifications_active_outlined,
                            onDismiss: () => _dismissNotification(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNotification,
        label: const Text('Send Alert'),
        icon: const Icon(Icons.add_alert),
      ),
    );
  }
}

// Glass Filter Button
class _GlassButton extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _GlassButton({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.35)
                : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


class _GlassmorphicCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final String priority;
  final String location;
  final IconData icon;
  final VoidCallback onDismiss;

  const _GlassmorphicCard({
    required this.title,
    required this.body,
    required this.time,
    required this.priority,
    required this.location,
    required this.icon,
    required this.onDismiss,
  });

  Color _getPriorityColor() {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.3,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with badge
                Row(
                  children: [
                    Icon(icon, color: _getPriorityColor(), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),

                // Footer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$time  •  $location",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text("View",
                              style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: onDismiss,
                          child: const Text("Dismiss",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
