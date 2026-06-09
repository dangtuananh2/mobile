// lib/NTD/views/home_ntd_page.dart
import 'package:flutter/material.dart';
import 'trangchu_ntd.dart';
import 'danhsach_cv_page.dart';
import 'kham_pha_cv_page.dart';
import 'thongbao_page.dart';
import 'taikhoan_ntd_page.dart';

class HomeNtdPage extends StatefulWidget {
  const HomeNtdPage({super.key});
  @override
  State<HomeNtdPage> createState() => _HomeNtdPageState();
}

class _HomeNtdPageState extends State<HomeNtdPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TrangChuNtdPage(),
    DanhSachCvPage(),
    KhamPhaCvPage(),   // ← Tab Khám phá
    ThongBaoPage(),
    TaiKhoanNtdPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Bảng tin'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: 'Quản lý CV'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Công ty'),
        ],
      ),
    );
  }
}