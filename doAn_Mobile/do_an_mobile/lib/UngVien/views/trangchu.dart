import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:do_an_mobile/UngVien/views/ntd_uv.dart';
import 'package:do_an_mobile/UngVien/views/thongbao.dart';
import 'package:do_an_mobile/UngVien/views/taikhoan.dart';
import 'package:do_an_mobile/UngVien/views/taocv.dart';
import 'package:do_an_mobile/UngVien/views/map_page.dart';
import 'package:do_an_mobile/UngVien/views/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrangChu extends StatefulWidget {
  const TrangChu({super.key});

  @override
  State<TrangChu> createState() => _TrangChuState();
}

class _TrangChuState extends State<TrangChu> {
  int currentIndex = 0;

  String selectedLocation = "Tất cả";
  String searchText = "";

  // 🔥 DATA JOB (cơ bản + từ NTD đăng)
  final List<Map<String, String>> _defaultJobs = [
    {
      "title": "Nhân Viên Kinh Doanh Fulltime (Công Ty Startup)",
      "company": "CÔNG TY CỔ PHẦN ĐÀO TẠO NGOẠI NGỮ TANGO",
      "salary": "15 - 25 triệu",
      "location": "Hà Nội",
    },
    {
      "title": "Nhân Viên Video Editor Đi Làm Ngay",
      "company": "CÔNG TY TNHH NỘI THẤT FUFUTECH",
      "salary": "10 - 16 triệu",
      "location": "Hồ Chí Minh",
    },
  ];

  List<Map<String, String>> _ntdJobs = [];

  List<Map<String, String>> get jobs => [..._defaultJobs, ..._ntdJobs];

  @override
  void initState() {
    super.initState();
    _loadNtdJobs();
  }

  Future<void> _loadNtdJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String raw = prefs.getString('ntd_published_jobs') ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      setState(() {
        _ntdJobs = list
            .cast<Map<String, dynamic>>()
            .map<Map<String, String>>((j) => {
                  'title': j['title']?.toString() ?? '',
                  'company': j['company']?.toString() ?? 'Nhà tuyển dụng',
                  'salary': j['salary']?.toString() ?? 'Thỏa thuận',
                  'location': j['location']?.toString() ?? 'Hồ Chí Minh',
                })
            .toList();
      });
    } catch (_) {}
  }

  // 🔥 FILTER LOGIC
  List<Map<String, String>> get filteredJobs {
    return jobs.where((job) {
      bool matchLocation = selectedLocation == "Tất cả" ||
          (job["location"] ?? '').toLowerCase().contains(selectedLocation.toLowerCase());

      bool matchSearch = searchText.isEmpty ||
          (job["title"] ?? '').toLowerCase().contains(searchText.toLowerCase()) ||
          (job["company"] ?? '').toLowerCase().contains(searchText.toLowerCase()) ||
          (job["location"] ?? '').toLowerCase().contains(searchText.toLowerCase());

      return matchLocation && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              left: 15,
              right: 15,
              bottom: 15,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm theo địa điểm",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // KHÁM PHÁ (🔥 CHỈ SỬA CHỖ NÀY)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          elevation: 0,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapPage(jobs: jobs), // ✅ truyền jobs
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text(
                          "Khám phá việc làm gần bạn",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // CARD CV
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5E9), Colors.white],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person, size: 40, color: Colors.green),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "> 20.000 Nhà tuyển dụng đang tìm kiếm ứng viên\nTạo CV ngay để NTD tìm thấy bạn!",
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TaoCV(),
                                ),
                              );
                            },
                            child: const Text(
                              "Tạo CV",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // TITLE
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(
                          "Việc làm tốt nhất",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 FILTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      filterItem("Tất cả"),
                      filterItem("Hà Nội"),
                      filterItem("Hồ Chí Minh"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 🔥 JOB LIST
                  Column(
                    children: filteredJobs.map((job) {
                      return jobItem(
                        job["title"]!,
                        job["company"]!,
                        job["salary"]!,
                        job["location"]!,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTTOM NAV (GIỮ NGUYÊN)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TaoCV()),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NTD_UV()),
            );
          }
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ThongBao()),
            );
          }
          if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TaiKhoan()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Tạo CV"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "NTD -> UV"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Thông báo"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }

  // 🔥 FILTER ITEM
  Widget filterItem(String title) {
    bool isSelected = selectedLocation == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLocation = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // GIỮ NGUYÊN
  Widget jobItem(String title, String company, String salary, String location) {
    String imagePath = company.contains("TANGO")
        ? "assets/images/company.jpg"
        : "assets/images/company2.jpg";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailPage(
              title: title,
              company: company,
              salary: salary,
              location: location,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 60, width: 60),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(company),
                  Row(
                    children: [
                      chip(salary),
                      const SizedBox(width: 5),
                      chip(location),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}