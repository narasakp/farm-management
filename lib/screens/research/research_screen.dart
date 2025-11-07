import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/research_provider.dart';
import '../../models/research_project.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../utils/tab_navigation_mixin.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> with TickerProviderStateMixin, TabNavigationMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initTabNavigation(_tabController, initialTab: 0, fallbackRoute: '/dashboard');
  }

  @override
  void dispose() {
    disposeTabNavigation();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'วิจัยและพัฒนา',
        onBackPressed: handleSmartBackPress,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          tabs: const [
            Tab(text: 'โครงการวิจัย'),
            Tab(text: 'ข้อมูลวิจัย'),
            Tab(text: 'สถิติ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectsTab(),
          _buildDataTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(),
        backgroundColor: const Color(0xFFDAA520),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'เพิ่มโครงการ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Consumer<ResearchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีโครงการวิจัย',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'เริ่มต้นโดยการเพิ่มโครงการวิจัยใหม่',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.projects.length,
          itemBuilder: (context, index) {
            final project = provider.projects[index];
            return _buildProjectCard(project);
          },
        );
      },
    );
  }

  Widget _buildProjectCard(ResearchProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProjectDetails(project),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildStatusChip(project.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    project.researcherName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    project.type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(project.startDate)} - ${project.endDate != null ? _formatDate(project.endDate!) : 'ไม่ระบุ'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (project.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      project.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ResearchStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case ResearchStatus.planning:
        backgroundColor = Colors.orange;
        break;
      case ResearchStatus.ongoing:
        backgroundColor = const Color(0xFF228B22);
        break;
      case ResearchStatus.dataCollection:
        backgroundColor = Colors.blue;
        break;
      case ResearchStatus.analysis:
        backgroundColor = Colors.purple;
        break;
      case ResearchStatus.completed:
        backgroundColor = const Color(0xFFDAA520);
        textColor = Colors.black87;
        break;
      case ResearchStatus.published:
        backgroundColor = Colors.green;
        break;
      case ResearchStatus.cancelled:
        backgroundColor = const Color(0xFFCD5C5C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDataTab() {
    return Consumer<ResearchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.researchData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.data_usage,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีข้อมูลวิจัย',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ข้อมูลจะแสดงเมื่อมีการเก็บข้อมูลวิจัย',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.researchData.length,
          itemBuilder: (context, index) {
            final data = provider.researchData[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF228B22),
                  child: Icon(
                    _getDataTypeIcon(data.dataType),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.description,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เก็บโดย: ${data.collectorName} • ${_formatDate(data.collectionDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: () => _showDataDetails(data),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<ResearchProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCard(
                'สรุปโครงการวิจัย',
                [
                  _buildStatItem('โครงการทั้งหมด', provider.totalProjects.toString(), Icons.science),
                  _buildStatItem('โครงการที่ดำเนินการ', provider.activeProjects.toString(), Icons.play_circle),
                  _buildStatItem('โครงการที่เสร็จสิ้น', provider.completedProjects.toString(), Icons.check_circle),
                  _buildStatItem('ข้อมูลวิจัย', provider.totalDataPoints.toString(), Icons.data_usage),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                'สถานะโครงการ',
                provider.getProjectStatusStats().entries.map((entry) =>
                  _buildStatItem(entry.key.displayName, entry.value.toString(), Icons.circle)
                ).toList(),
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                'ประเภทการวิจัย',
                provider.getProjectTypeStats().entries.map((entry) =>
                  _buildStatItem(entry.key.displayName, entry.value.toString(), Icons.category)
                ).toList(),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          Icon(icon, size: 20, color: const Color(0xFF228B22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDataTypeIcon(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'production':
        return Icons.production_quantity_limits;
      case 'nutrition':
        return Icons.restaurant;
      case 'livestock_health':
        return Icons.health_and_safety;
      case 'breeding':
        return Icons.pets;
      case 'environment':
        return Icons.eco;
      default:
        return Icons.data_usage;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddProjectDialog() {
    // TODO: Implement add project dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์เพิ่มโครงการจะพัฒนาในขั้นตอนถัดไป'),
        backgroundColor: const Color(0xFFDAA520),
      ),
    );
  }

  void _showProjectDetails(ResearchProject project) {
    // TODO: Implement project details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('รายละเอียดโครงการ: ${project.title}'),
        backgroundColor: const Color(0xFF228B22),
      ),
    );
  }

  void _showDataDetails(data) {
    // TODO: Implement data details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('รายละเอียดข้อมูล: ${data.title}'),
        backgroundColor: const Color(0xFF228B22),
      ),
    );
  }
}
