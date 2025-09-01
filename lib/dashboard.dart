import 'package:flutter/material.dart';

import 'homepage.dart';
import 'pages/recent_page.dart';
import 'pages/settings_page.dart';

class Dashboard extends StatefulWidget {
  final List<Map<String, String>> initialRecent;
  final int initialIndex;

  const Dashboard({
    super.key,
    this.initialRecent = const [],
    this.initialIndex = 0,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  List<Map<String, String>> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _recentFiles = widget.initialRecent;
    _selectedIndex = widget.initialIndex;
  }

  void _updateRecent(List<Map<String, String>> newFiles) {
    setState(() {
      _recentFiles = newFiles;
      _selectedIndex = 1; // Switch to Recent tab automatically
    });
  }

  void _deleteFromRecent(List<Map<String, String>> updatedFiles) {
    setState(() {
      _recentFiles = updatedFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onPdfCreated: _updateRecent, existingRecent: _recentFiles),
      RecentPage(pdfFiles: _recentFiles, onPdfDeleted: _deleteFromRecent),
      const SettingsPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: "Recent",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
