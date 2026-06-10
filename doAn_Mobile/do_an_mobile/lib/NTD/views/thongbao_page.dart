// lib/NTD/views/thongbao_page.dart
import 'package:flutter/material.dart';
import '../services/invitation_service.dart';

class ThongBaoPage extends StatefulWidget {
  const ThongBaoPage({super.key});

  @override
  State<ThongBaoPage> createState() => _ThongBaoPageState();
}

class _ThongBaoPageState extends State<ThongBaoPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) {
        return 'Vừa xong';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} phút trước';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} giờ trước';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      } else {
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return timeStr;
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final invitationNotifs = await InvitationService.getNtdNotifications();
      setState(() {
        _notifications = invitationNotifs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n["unread"] = false;
      }
    });
    // Lưu lại
    final invitationNotifs = _notifications
        .where((n) => n['type'] == 'accepted' || n['type'] == 'rejected')
        .toList();
    InvitationService.saveNtdNotifications(invitationNotifs);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'new_cv': return Icons.person_add;
      case 'interview': return Icons.event_available;
      case 'warning': return Icons.warning;
      default: return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'new_cv': return Colors.blue;
      case 'interview': return Colors.green;
      case 'warning': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thông báo",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00C853), Color(0xFF009688)]))),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Làm mới",
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: Colors.white),
            tooltip: "Đánh dấu đã đọc",
            onPressed: _markAllRead,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: const Color(0xFF00C853),
              child: _notifications.isEmpty
                  ? const Center(
                      child: Text("Không có thông báo nào",
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        var notif = _notifications[index];
                        final type = notif['type']?.toString() ?? 'default';
                        final iconData = _iconForType(type);
                        final color = _colorForType(type);

                        return Dismissible(
                          key: Key(notif["id"].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            setState(() => _notifications.removeAt(index));
                            // Lưu lại nếu là thông báo lời mời
                            final invitationNotifs = _notifications
                                .where((n) => n['type'] == 'accepted' || n['type'] == 'rejected')
                                .toList();
                            InvitationService.saveNtdNotifications(invitationNotifs);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã xóa thông báo")),
                            );
                          },
                          child: Container(
                            color: (notif["unread"] == true)
                                ? color.withOpacity(0.05)
                                : Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: color.withOpacity(0.1),
                                    radius: 25,
                                    child: Icon(iconData, color: color),
                                  ),
                                  if (notif["unread"] == true)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                notif["title"]?.toString() ?? '',
                                style: TextStyle(
                                  fontWeight: (notif["unread"] == true)
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notif["sub"]?.toString() ?? ''),
                                    const SizedBox(height: 5),
                                    Text(
                                      _formatTime(notif["time"]?.toString()),
                                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                setState(() => notif["unread"] = false);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}