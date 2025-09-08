import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gps_provider.dart';
import '../../models/gps_location.dart';
import '../../utils/app_theme.dart';

class GPSTrackingScreen extends StatefulWidget {
  const GPSTrackingScreen({super.key});

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ติดตาม GPS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.forestGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
            tooltip: 'กลับหน้าหลัก',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'ตำแหน่งปัจจุบัน'),
            Tab(text: 'เส้นทางติดตาม'),
            Tab(text: 'สถิติ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentLocationTab(),
          _buildTracksTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: Consumer<GPSProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: provider.isTracking ? _stopTracking : _startTracking,
            backgroundColor: provider.isTracking ? AppTheme.mutedRed : AppTheme.forestGreen,
            foregroundColor: Colors.white,
            icon: Icon(provider.isTracking ? Icons.stop : Icons.play_arrow),
            label: Text(
              provider.isTracking ? 'หยุดติดตาม' : 'เริ่มติดตาม',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentLocationTab() {
    return Consumer<GPSProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'กำลังค้นหาตำแหน่ง...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาด',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.clearError,
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        final location = provider.currentLocation;
        if (location == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ไม่พบตำแหน่งปัจจุบัน',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'กรุณาเปิดใช้งาน GPS และอนุญาตการเข้าถึงตำแหน่ง',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(location),
              const SizedBox(height: 16),
              _buildTrackingStatusCard(provider),
              const SizedBox(height: 16),
              _buildQuickActionsCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(GPSLocation location) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.forestGreen, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'ตำแหน่งปัจจุบัน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationInfo('พิกัด', location.coordinatesString, Icons.my_location),
            if (location.address != null)
              _buildLocationInfo('ที่อยู่', location.address!, Icons.home),
            if (location.subDistrict != null)
              _buildLocationInfo('ตำบล', location.subDistrict!, Icons.location_city),
            if (location.district != null)
              _buildLocationInfo('อำเภอ', location.district!, Icons.location_city),
            if (location.province != null)
              _buildLocationInfo('จังหวัด', location.province!, Icons.map),
            if (location.accuracy != null)
              _buildLocationInfo('ความแม่นยำ', '${location.accuracy!.toStringAsFixed(1)} เมตร', Icons.gps_fixed),
            _buildLocationInfo('เวลาอัปเดต', _formatDateTime(location.timestamp), Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatusCard(GPSProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider.isTracking ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: provider.isTracking ? AppTheme.forestGreen : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  provider.isTracking ? 'กำลังติดตาม' : 'ไม่ได้ติดตาม',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: provider.isTracking ? AppTheme.forestGreen : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isTracking) ...[
              const Text(
                'ระบบกำลังบันทึกตำแหน่งของคุณ',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'เส้นทางที่ใช้งาน: ${provider.activeTracks_count} เส้นทาง',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const Text(
                'กดปุ่มเริ่มติดตามเพื่อบันทึกเส้นทาง',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'การดำเนินการ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addManualLocation,
                    icon: const Icon(Icons.add_location),
                    label: const Text('เพิ่มตำแหน่ง'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldenYellow,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('รีเฟรช'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warmBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracksTab() {
    return Consumer<GPSProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.tracks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีเส้นทางติดตาม',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'เริ่มติดตามเพื่อบันทึกเส้นทางการเดินทาง',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.tracks.length,
          itemBuilder: (context, index) {
            final track = provider.tracks[index];
            return _buildTrackCard(track);
          },
        );
      },
    );
  }

  Widget _buildTrackCard(LocationTrack track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEntityIcon(track.entityType),
                  color: AppTheme.forestGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    track.description ?? 'เส้นทาง ${track.entityType}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (track.endTime == null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'กำลังติดตาม',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'ระยะทาง: ${track.totalDistance.toStringAsFixed(2)} กม.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'เวลา: ${_formatDuration(track.duration)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'ความเร็วเฉลี่ย: ${track.averageSpeed.toStringAsFixed(1)} กม./ชม.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'จุด: ${track.locations.length}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'เริ่ม: ${_formatDateTime(track.startTime)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (track.endTime != null)
              Text(
                'สิ้นสุด: ${_formatDateTime(track.endTime!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<GPSProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCard(
                'สรุปการติดตาม',
                [
                  _buildStatItem('เส้นทางทั้งหมด', provider.totalTracks.toString(), Icons.route),
                  _buildStatItem('เส้นทางที่ใช้งาน', provider.activeTracks_count.toString(), Icons.play_circle),
                  _buildStatItem('ระยะทางรวม', '${provider.totalDistanceTracked.toStringAsFixed(2)} กม.', Icons.straighten),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                'ประเภทการติดตาม',
                _getTrackTypeStats(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(String title, List<Widget> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.forestGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getTrackTypeStats(GPSProvider provider) {
    final typeStats = <String, int>{};
    for (final track in provider.tracks) {
      typeStats[track.entityType] = (typeStats[track.entityType] ?? 0) + 1;
    }

    return typeStats.entries.map((entry) {
      return _buildStatItem(
        _getEntityTypeName(entry.key),
        entry.value.toString(),
        _getEntityIcon(entry.key),
      );
    }).toList();
  }

  IconData _getEntityIcon(String entityType) {
    switch (entityType) {
      case 'transport':
        return Icons.local_shipping;
      case 'survey':
        return Icons.assignment;
      case 'farm':
        return Icons.agriculture;
      default:
        return Icons.location_on;
    }
  }

  String _getEntityTypeName(String entityType) {
    switch (entityType) {
      case 'transport':
        return 'การขนส่ง';
      case 'survey':
        return 'การสำรวจ';
      case 'farm':
        return 'ฟาร์ม';
      default:
        return entityType;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}ชม. ${minutes}นาที';
    } else {
      return '${minutes}นาที';
    }
  }

  void _startTracking() async {
    final provider = Provider.of<GPSProvider>(context, listen: false);
    await provider.startTracking(
      'USER001',
      'manual',
      description: 'การติดตามด้วยตนเอง',
    );
  }

  void _stopTracking() async {
    final provider = Provider.of<GPSProvider>(context, listen: false);
    await provider.stopTracking();
  }

  void _addManualLocation() {
    // TODO: Implement manual location input dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์เพิ่มตำแหน่งด้วยตนเองจะพัฒนาในขั้นตอนถัดไป'),
        backgroundColor: AppTheme.goldenYellow,
      ),
    );
  }

  void _refreshLocation() async {
    final provider = Provider.of<GPSProvider>(context, listen: false);
    // Simulate location refresh
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('อัปเดตตำแหน่งเรียบร้อย'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
  }
}
