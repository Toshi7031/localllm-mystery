import 'package:flutter/material.dart';
import '../../features/map/map_page.dart';
import '../../features/evidence/evidence_list_page.dart';
import '../../features/contradiction/contradiction_list_page.dart';
import '../../features/deduction/deduction_page.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    MapPage(),
    EvidenceListPage(),
    ContradictionListPage(),
    DeductionPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'マップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '証拠',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: '矛盾',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: '推理',
          ),
        ],
      ),
    );
  }
}
