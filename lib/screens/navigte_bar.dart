import 'package:flutter/material.dart';
import 'package:thanya/screens/band_screen.dart';
import 'package:thanya/screens/home_screen.dart';
import 'package:thanya/screens/sos_screen.dart';
import 'package:thanya/screens/profile_screen.dart';

class NavigateBar extends StatefulWidget {
  const NavigateBar({super.key});

  @override
  State<NavigateBar> createState() => _NavigateBarState();
}

class _NavigateBarState extends State<NavigateBar> {
  int _currentIndex = 3;

  final List<Widget> _screens = [
    HomeScreen(),
    SosScreen(),
    BandScreen(),
    ProfileScreen(),
  ];

  final List<Color> _activeColors = [
    Color(0xFF2196F3),
    Color(0xFFE53935),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(index: _currentIndex, children: _screens),

            Positioned(
              left: 20,
              right: 20,
              bottom: 25,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, "Home", 0),
                    _buildNavItem(Icons.sos, "", 1),
                    _buildNavItem(Icons.watch, "Band", 2),
                    _buildNavItem(Icons.person, "Profile", 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    final Color activeColor = _activeColors[index];

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 0,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade900 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white70,
              size: 26,
            ),
            if (isSelected)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
