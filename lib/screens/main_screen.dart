import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reading_screen.dart';
import 'reading_progress_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 찾기 탭 = AI 감정 검색(HomeScreen). 키워드 검색은 성경 탭 헤더 돋보기로 접근.
  final _screens = const [
    HomeScreen(),
    ReadingScreen(),
    ReadingProgressScreen(),
    BookmarksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
