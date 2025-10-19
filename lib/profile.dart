import 'dart:ui';
import 'package:flutter/material.dart';

class MYProfile extends StatelessWidget {
  const MYProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: const [
          Icon(Icons.notifications_none_outlined, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.person_2_outlined, color: Colors.white),
          SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
        
          Image.asset(
            "assets/farm_bg.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

         
          Container(color: Colors.black.withOpacity(0.1)),

       
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _glassCard(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage("farmerimg.jpg"),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "John",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Farm Owner & Manager",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Green Valley Organic Farm",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Rajahmundry, Andhra Pradesh",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                 
                  const Text(
                    "Farm Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      _buildInfoCard(Icons.landscape, "8", "Total Fields"),
                      _buildInfoCard(Icons.map, "250 acres", "Total Area"),
                      _buildInfoCard(Icons.sensors, "24", "Active Sensors"),
                      _buildInfoCard(
                        Icons.calendar_month,
                        "3 months",
                        "Harvest Season",
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildActivityTile(
                    Icons.check_circle,
                    Colors.green,
                    "Irrigation completed",
                    "Wheat Field A - 2 hours ago",
                  ),
                  _buildActivityTile(
                    Icons.camera_alt,
                    Colors.blue,
                    "Disease scan performed",
                    "Tomato Grove B - 1 day ago",
                  ),
                  _buildActivityTile(
                    Icons.warning,
                    Colors.orange,
                    "Temperature alert resolved",
                    "Corn Field C - 2 days ago",
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSettingsTile(
                    Icons.home,
                    "Farm Information",
                    "Update farm details and location",
                  ),
                  _buildSettingsTile(
                    Icons.sensors,
                    "Sensor Configuration",
                    "Manage IoT devices and thresholds",
                  ),
                  _buildSettingsTile(
                    Icons.notifications,
                    "Alert Preferences",
                    "Customize notification settings",
                  ),
                  _buildSettingsTile(Icons.language, "Language", "English"),
                  _buildSettingsTile(
                    Icons.download,
                    "Data Export",
                    "Download farming data and reports",
                  ),
                  _buildSettingsTile(
                    Icons.help_outline,
                    "Help & Support",
                    "Get assistance and tutorials",
                  ),

                  const SizedBox(height: 20),
                  _glassCard(
                    color: Colors.white.withOpacity(0.1),
                    child: const Center(
                      child: Text(
                        "Sign Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Widget _glassCard({required Widget child, Color? color}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (color ?? Colors.white.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: child,
      ),
    ),
  );
}


Widget _buildInfoCard(IconData icon, String value, String label) {
  return _glassCard(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget _buildActivityTile(
  IconData icon,
  Color color,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: _glassCard(
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildSettingsTile(StringIcon, String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: _glassCard(
      child: Row(
        children: [
          Icon(StringIcon, color: Colors.white, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    ),
  );
}
