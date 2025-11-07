import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class AuditDashboardScreen extends StatefulWidget {
  const AuditDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AuditDashboardScreen> createState() => _AuditDashboardScreenState();
}

class _AuditDashboardScreenState extends State<AuditDashboardScreen> {
  List<dynamic> _auditLogs = [];
  bool _isLoading = true;
  String? _selectedAction;
  String? _selectedResourceType;
  
  final List<String> _actions = ['all', 'create', 'edit', 'delete', 'approve', 'reject'];
  final List<String> _resourceTypes = ['all', 'feedback', 'reply', 'user'];

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoading = true);
    
    try {
      String url = '${ApiConfig.baseUrl}/api/feedback/audit/logs?limit=100';
      
      if (_selectedAction != null && _selectedAction != 'all') {
        url += '&action=$_selectedAction';
      }
      
      if (_selectedResourceType != null && _selectedResourceType != 'all') {
        url += '&resourceType=$_selectedResourceType';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _auditLogs = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading audit logs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.security),
            SizedBox(width: 8),
            Text('Audit Dashboard'),
          ],
        ),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                // Action filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Action',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedAction,
                    items: _actions.map((action) {
                      return DropdownMenuItem(
                        value: action,
                        child: Text(action),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedAction = value);
                      _loadAuditLogs();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Resource type filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Resource Type',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: _selectedResourceType,
                    items: _resourceTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedResourceType = value);
                      _loadAuditLogs();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Refresh button
                ElevatedButton.icon(
                  onPressed: _loadAuditLogs,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Actions',
                    _auditLogs.length.toString(),
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Edits',
                    _auditLogs.where((log) => log['action'] == 'edit').length.toString(),
                    Icons.edit,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Deletes',
                    _auditLogs.where((log) => log['action'] == 'delete').length.toString(),
                    Icons.delete,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Admins',
                    _auditLogs.map((log) => log['admin_username']).toSet().length.toString(),
                    Icons.admin_panel_settings,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Audit logs list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _auditLogs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No audit logs found',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _auditLogs.length,
                        itemBuilder: (context, index) {
                          final log = _auditLogs[index];
                          return _buildAuditLogCard(log);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogCard(Map<String, dynamic> log) {
    final action = log['action'] ?? '';
    final resourceType = log['resource_type'] ?? '';
    final adminUsername = log['admin_username'] ?? '';
    final createdAt = log['created_at'] ?? '';
    final resourceId = log['resource_id'] ?? '';
    
    Color actionColor;
    IconData actionIcon;
    
    switch (action) {
      case 'create':
        actionColor = Colors.green;
        actionIcon = Icons.add_circle;
        break;
      case 'edit':
        actionColor = Colors.orange;
        actionIcon = Icons.edit;
        break;
      case 'delete':
        actionColor = Colors.red;
        actionIcon = Icons.delete;
        break;
      case 'approve':
        actionColor = Colors.blue;
        actionIcon = Icons.check_circle;
        break;
      case 'reject':
        actionColor = Colors.purple;
        actionIcon = Icons.cancel;
        break;
      default:
        actionColor = Colors.grey;
        actionIcon = Icons.help;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: actionColor.withOpacity(0.1),
          child: Icon(actionIcon, color: actionColor, size: 20),
        ),
        title: Text(
          '$adminUsername performed $action on $resourceType',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDateTime(createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Admin ID', log['admin_id'] ?? '-'),
                _buildDetailRow('Action', action),
                _buildDetailRow('Resource Type', resourceType),
                _buildDetailRow('Resource ID', resourceId),
                if (log['details'] != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log['details'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                if (log['ip_address'] != null)
                  _buildDetailRow('IP Address', log['ip_address']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
