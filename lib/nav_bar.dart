import 'package:farm_guard_mvp/services/homescreen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'knowledge_book.dart';
import 'disease_detection.dart';
import 'alerts_screen.dart';
import 'profile.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  int currentIndex = 2;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final screens = [
    KnowledgeHubScreen(),
    MyCropDetection(),
    FarmGuardApp(),
    AlertsScreen(),
    MYProfile(),
  ];

  final List<NavItem> navItems = [
    NavItem(icon: Icons.menu_book_rounded, label: 'Knowledge'),
    NavItem(icon: Icons.camera_alt_rounded, label: 'Detect'),
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.notifications_active_rounded, label: 'Alerts'),
    NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    }).toList();
    _controllers[currentIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == currentIndex) return;
    
    _controllers[currentIndex].reverse();
    _controllers[index].forward();
    
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  return _buildNavItem(index);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = currentIndex == index;
    final item = navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final animValue = _animations[index].value;
            
            return Container(
              height: 75,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  
                  if (isSelected)
                    Positioned(
                      top: 10,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 50 + (animValue * 10),
                        height: 50 + (animValue * 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF66BB6A).withOpacity(0.3 * animValue),
                              const Color(0xFF2E7D32).withOpacity(0.2 * animValue),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF66BB6A).withOpacity(0.3 * animValue),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     
                      Transform.scale(
                        scale: 1.0 + (animValue * 0.15),
                        child: Icon(
                          item.icon,
                          size: 26,
                          color: isSelected 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                     
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 1.0 : 0.6,
                        child: Transform.translate(
                          offset: Offset(0, -2 * animValue),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: isSelected ? 11 : 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                 
                  if (isSelected)
                    Positioned(
                      top: 8,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: animValue,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF66BB6A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF66BB6A).withOpacity(0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}