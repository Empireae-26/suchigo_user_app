import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suchigo_app/services/pickup_api_service.dart';

class NotificationModel {
  final String title;
  final String body;
  final DateTime dateTime;
  final bool isUpcoming;

  NotificationModel({
    required this.title,
    required this.body,
    required this.dateTime,
    required this.isUpcoming,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  static const Color _primaryGreen = Color(0xFF1E713D);
  static const Color _bgGreen = Color(0xFFEFF9F1);

  late TabController _tabController;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawPickups = await PickupApiService.fetchPickups();
      final generatedList = _generateNotifications(rawPickups);

      if (mounted) {
        setState(() {
          _notifications = generatedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<NotificationModel> _generateNotifications(List<Map<String, dynamic>> rawPickups) {
    final now = DateTime.now();
    final List<NotificationModel> list = [];

    for (var item in rawPickups) {
      final dateStr = item['pickup_date']?.toString() ?? item['scheduled_date']?.toString();
      if (dateStr == null || dateStr.isEmpty) continue;
      final pickupDate = DateTime.tryParse(dateStr);
      if (pickupDate == null) continue;

      // 1. Day before reminder (4:00 PM the day before)
      final dayBefore = pickupDate.subtract(const Duration(days: 1));
      final dayBeforeSchedule = DateTime(
        dayBefore.year,
        dayBefore.month,
        dayBefore.day,
        16,
        0,
      );

      // 2. Day of reminder (8:00 AM the day of)
      final dayOfSchedule = DateTime(
        pickupDate.year,
        pickupDate.month,
        pickupDate.day,
        8,
        0,
      );

      list.add(NotificationModel(
        title: 'SuchiGo Pickup Reminder',
        body: 'Your garbage pickup is scheduled for tomorrow. Please keep your bags ready!',
        dateTime: dayBeforeSchedule,
        isUpcoming: dayBeforeSchedule.isAfter(now),
      ));

      list.add(NotificationModel(
        title: 'SuchiGo Pickup Today',
        body: 'Our collector will arrive today. Please ensure waste is accessible!',
        dateTime: dayOfSchedule,
        isUpcoming: dayOfSchedule.isAfter(now),
      ));
    }

    // Sort by date descending (most recent first)
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  String _formatNotificationTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('hh:mm a').format(dt);

    if (checkDate == today) {
      return 'Today at $timeStr';
    } else if (checkDate == yesterday) {
      return 'Yesterday at $timeStr';
    } else {
      return '${DateFormat('MMM dd, yyyy').format(dt)} at $timeStr';
    }
  }

  List<NotificationModel> _getFilteredNotifications(int tabIndex) {
    if (tabIndex == 1) {
      // Upcoming
      return _notifications.where((n) => n.isUpcoming).toList();
    } else if (tabIndex == 2) {
      // Delivered / Past
      return _notifications.where((n) => !n.isUpcoming).toList();
    }
    // All
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGreen,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        backgroundColor: _primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Upcoming"),
            Tab(text: "Delivered"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: List.generate(3, (index) {
                    final filtered = _getFilteredNotifications(index);
                    return RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: _primaryGreen,
                      child: filtered.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.6,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_off_outlined,
                                      size: 72,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No notifications found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      index == 1
                                          ? 'No upcoming scheduled reminders.'
                                          : index == 2
                                              ? 'No past notifications received yet.'
                                              : 'Your notifications will appear here.',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final item = filtered[i];
                                return _NotificationCard(
                                  item: item,
                                  timeLabel: _formatNotificationTime(item.dateTime),
                                  accentColor: _primaryGreen,
                                );
                              },
                            ),
                    );
                  }),
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final String timeLabel;
  final Color accentColor;

  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: item.isUpcoming ? accentColor : Colors.grey.shade400,
                width: 5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.isUpcoming
                      ? accentColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isUpcoming
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: item.isUpcoming ? accentColor : Colors.grey.shade600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: item.isUpcoming ? Colors.black87 : Colors.black54,
                            ),
                          ),
                        ),
                        if (item.isUpcoming)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Upcoming',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: item.isUpcoming ? Colors.grey.shade700 : Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
