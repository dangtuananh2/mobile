// lib/NTD/views/trangchu_ntd.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../UngVien/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dang_tuyen_dung_page.dart';
import 'danhsach_cv_page.dart';

class TrangChuNtdPage extends StatefulWidget {
  const TrangChuNtdPage({super.key});
  @override
  State<TrangChuNtdPage> createState() => _TrangChuNtdPageState();
}

class _TrangChuNtdPageState extends State<TrangChuNtdPage> {
  String searchText = '';
  String selectedFilter = 'Tất cả';
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/TinTuyenDung'),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _jobs = data.cast<Map<String, dynamic>>();
      } else {
        _jobs = [];
      }
    } catch (_) {
      _jobs = [];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String raw = prefs.getString('ntd_published_jobs') ?? '[]';
      final List<dynamic> list = jsonDecode(raw);
      final List<Map<String, dynamic>> localJobs = list.map((j) => {
        'idTin': j['idTin'] ?? j['id_tin'] ?? 0,
        'tieuDe': j['title'] ?? j['tieuDe'] ?? 'Chưa có tiêu đề',
        'kyNang': j['skills'] ?? j['kyNang'] ?? '',
        'trangThai': j['trangThai'] ?? 'Đang mở',
        'hanNop': j['publishedAt'] ?? j['hanNop'],
        'soLuongCv': j['soLuongCv'] ?? 0,
      }).toList();
      _jobs = [...localJobs, ..._jobs];
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    return _jobs.where((job) {
      final trangThai = job['trangThai']?.toString() ?? '';
      final tieuDe = job['tieuDe']?.toString().toLowerCase() ?? '';
      final kyNang = job['kyNang']?.toString().toLowerCase() ?? '';
      final matchFilter = selectedFilter == 'Tất cả' ||
          (selectedFilter == 'Đang mở' && trangThai == 'Đang mở') ||
          (selectedFilter == 'Đã đóng' && trangThai == 'Đã đóng');
      final matchSearch = searchText.isEmpty ||
          tieuDe.contains(searchText.toLowerCase()) ||
          kyNang.contains(searchText.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quản lý tuyển dụng',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Row(children: [
                      // Nút Tìm kiếm
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: _JobSearchDelegate(
                              jobs: _jobs,
                              onSelect: (job) {
                                final idTin = job['idTin'] ?? job['id_tin'] ?? 0;
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => DanhSachCvPage(idTinTuyenDung: int.tryParse(idTin.toString()) ?? 0),
                                ));
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Tìm kiếm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      // Nút Đăng tuyển dụng
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const DangTuyenDungPage()));
                          _loadJobs();
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Đăng tuyển', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => searchText = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm tin đăng hoặc kỹ năng...',
                    prefixIcon: const Icon(Icons.manage_search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _loadJobs)
                    : RefreshIndicator(
                        onRefresh: _loadJobs,
                        color: const Color(0xFF00C853),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              // Thống kê
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(children: [
                                  _statCard('CV Mới',
                                      _jobs.fold(0, (s, j) => s + (j['soLuongCv'] as int? ?? 0)).toString(),
                                      Colors.orange),
                                  const SizedBox(width: 10),
                                  _statCard('Đang mở',
                                      _jobs.where((j) => j['trangThai'] == 'Đang mở').length.toString(),
                                      Colors.blue),
                                  const SizedBox(width: 10),
                                  _statCard('Tin đăng', _jobs.length.toString(), Colors.green),
                                ]),
                              ),
                              const SizedBox(height: 20),

                              // Nút tạo tin
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30)),
                                      padding: const EdgeInsets.all(15),
                                    ),
                                    onPressed: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const DangTuyenDungPage())),
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text('Tạo tin tuyển dụng mới',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Filter + danh sách
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Danh sách tin đăng (${_filtered.length})',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Row(children: [
                                      _filterChip('Tất cả'),
                                      _filterChip('Đang mở'),
                                      _filterChip('Đã đóng'),
                                    ]),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              if (_filtered.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Column(children: [
                                    Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('Chưa có tin tuyển dụng nào',
                                        style: TextStyle(color: Colors.grey)),
                                  ]),
                                )
                              else
                                ..._filtered.map((job) => _jobCard(job)),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      );

  Widget _filterChip(String title) {
    final isSelected = selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = title),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(title,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
      ),
    );
  }

  Widget _jobCard(Map<String, dynamic> job) {
    final isActive = job['trangThai']?.toString() == 'Đang mở';
    final tieuDe = job['tieuDe']?.toString() ?? 'Chưa có tiêu đề';
    final kyNang = job['kyNang']?.toString() ?? '';
    final hanNop = job['hanNop']?.toString();
    final idTin = job['idTin'] ?? job['id_tin'] ?? 0;
    final cvCount = job['soLuongCv']?.toString() ?? '0';

    String hanDisplay = 'Chưa rõ';
    if (hanNop != null) {
      try {
        final dt = DateTime.parse(hanNop);
        hanDisplay = 'Hạn: ${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
      } catch (_) { hanDisplay = hanNop; }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isActive ? Colors.green : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.business_center, color: Colors.green),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tieuDe, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (kyNang.isNotEmpty)
                    Text('Kỹ năng: $kyNang',
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(children: [
              Text(cvCount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              const Text('CV', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ]),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job['trangThai']?.toString() ?? 'Không rõ',
                      style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(hanDisplay,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DanhSachCvPage(idTinTuyenDung: int.tryParse(idTin.toString()) ?? 0))),
                child: const Text('Quản lý CV', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Job Search Delegate ─────────────────────────────────────────────────────

class _JobSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> jobs;
  final void Function(Map<String, dynamic> job) onSelect;

  _JobSearchDelegate({required this.jobs, required this.onSelect});

  @override
  String get searchFieldLabel => 'Tìm tiêu đề hoặc kỹ năng...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = jobs.where((j) {
      final q = query.toLowerCase();
      return j['tieuDe']?.toString().toLowerCase().contains(q) == true ||
          j['kyNang']?.toString().toLowerCase().contains(q) == true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('Không tìm thấy kết quả', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final job = filtered[i];
        return ListTile(
          leading: const Icon(Icons.work_outline, color: Colors.green),
          title: Text(job['tieuDe']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(job['kyNang']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            close(context, '');
            onSelect(job);
          },
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Không thể tải dữ liệu'),
              const SizedBox(height: 6),
              Text(error, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
                onPressed: onRetry,
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
}