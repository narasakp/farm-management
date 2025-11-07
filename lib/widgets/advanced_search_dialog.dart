/**
 * Advanced Search Dialog
 * Dialog สำหรับค้นหาแบบละเอียด พร้อม filters และ sort options
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/thread.dart';
import '../utils/date_formatter.dart';

class AdvancedSearchDialog extends StatefulWidget {
  const AdvancedSearchDialog({super.key});

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Search state
  List<Thread> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  int _total = 0;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  // Filters
  final List<String> _selectedCategories = [];
  final List<String> _selectedStatuses = [];
  final List<String> _selectedTags = [];
  String _sortBy = 'relevance';
  bool? _hasAcceptedAnswer;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  // Available options
  final List<String> _categories = [
    'ทั่วไป',
    'โค-กระบือ',
    'สุกร',
    'สัตว์ปีก',
    'แพะ-แกะ',
    'สัตว์น้ำ',
    'อื่นๆ',
  ];

  final List<String> _statuses = ['open', 'closed', 'archived'];

  final List<String> _tags = [
    'การเลี้ยง',
    'โรคสัตว์',
    'อาหารสัตว์',
    'การผสมพันธุ์',
    'ราคา',
    'การขาย',
    'เทคโนโลยี',
    'ปัญหา',
  ];

  final Map<String, String> _sortOptions = {
    'relevance': 'ความเกี่ยวข้อง',
    'date_desc': 'วันที่ล่าสุด',
    'date_asc': 'วันที่เก่าสุด',
    'replies': 'คำตอบมากสุด',
    'votes': 'โหวตมากสุด',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isSearching && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _performSearch({bool reset = false}) async {
    if (reset) {
      setState(() {
        _offset = 0;
        _results = [];
        _hasMore = true;
        _hasSearched = true;
      });
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/search/advanced'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'query': _searchController.text.trim(),
          'categories': _selectedCategories,
          'statuses': _selectedStatuses,
          'tags': _selectedTags,
          'sortBy': _sortBy,
          'hasAcceptedAnswer': _hasAcceptedAnswer,
          'dateFrom': _dateFrom?.toIso8601String(),
          'dateTo': _dateTo?.toIso8601String(),
          'limit': _limit,
          'offset': _offset,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final threads = (data['threads'] as List)
            .map((json) => Thread.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            if (reset) {
              _results = threads;
            } else {
              _results.addAll(threads);
            }
            _total = data['total'] ?? 0;
            _hasMore = threads.length == _limit;
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    _offset += _limit;
    await _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategories.clear();
      _selectedStatuses.clear();
      _selectedTags.clear();
      _sortBy = 'relevance';
      _hasAcceptedAnswer = null;
      _dateFrom = null;
      _dateTo = null;
      _results = [];
      _hasSearched = false;
      _total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  // Filters Panel
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: _buildFiltersPanel(),
                  ),
                  // Results Panel
                  Expanded(
                    child: _buildResultsPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ค้นหาขั้นสูง',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหาหัวข้อ, เนื้อหา, ผู้เขียน...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _performSearch(reset: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('ค้นหา'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _performSearch(reset: true),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('ล้าง'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onPressed: _clearFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort By
          _buildFilterSection(
            title: 'เรียงตาม',
            icon: Icons.sort,
            child: Column(
              children: _sortOptions.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _sortBy,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // Categories
          _buildFilterSection(
            title: 'หมวดหมู่',
            icon: Icons.category,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // Status
          _buildFilterSection(
            title: 'สถานะ',
            icon: Icons.info_outline,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((status) {
                final isSelected = _selectedStatuses.contains(status);
                final label = status == 'open'
                    ? 'เปิด'
                    : status == 'closed'
                        ? 'ปิด'
                        : 'เก็บถาวร';
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedStatuses.add(status);
                      } else {
                        _selectedStatuses.remove(status);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // Tags
          _buildFilterSection(
            title: 'แท็ก',
            icon: Icons.label,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32),

          // Has Accepted Answer
          _buildFilterSection(
            title: 'คำตอบที่ยอมรับ',
            icon: Icons.check_circle,
            child: Column(
              children: [
                RadioListTile<bool?>(
                  title: const Text('ทั้งหมด'),
                  value: null,
                  groupValue: _hasAcceptedAnswer,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _hasAcceptedAnswer = value;
                    });
                  },
                ),
                RadioListTile<bool?>(
                  title: const Text('มีคำตอบที่ยอมรับ'),
                  value: true,
                  groupValue: _hasAcceptedAnswer,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _hasAcceptedAnswer = value;
                    });
                  },
                ),
                RadioListTile<bool?>(
                  title: const Text('ไม่มีคำตอบที่ยอมรับ'),
                  value: false,
                  groupValue: _hasAcceptedAnswer,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _hasAcceptedAnswer = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Date Range
          _buildFilterSection(
            title: 'ช่วงเวลา',
            icon: Icons.date_range,
            child: Column(
              children: [
                ListTile(
                  title: const Text('จาก'),
                  subtitle: Text(
                    _dateFrom != null
                        ? DateFormatter.formatDate(_dateFrom!)
                        : 'ไม่จำกัด',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateFrom = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('ถึง'),
                  subtitle: Text(
                    _dateTo != null
                        ? DateFormatter.formatDate(_dateTo!)
                        : 'ไม่จำกัด',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateTo ?? DateTime.now(),
                      firstDate: _dateFrom ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _dateTo = date;
                      });
                    }
                  },
                ),
                if (_dateFrom != null || _dateTo != null)
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('ล้างช่วงเวลา'),
                    onPressed: () {
                      setState(() {
                        _dateFrom = null;
                        _dateTo = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildResultsPanel() {
    if (!_hasSearched) {
      return _buildEmptyState(
        icon: Icons.search,
        message: 'กรอกคำค้นหาและเลือกตัวกรอง\nแล้วกดปุ่ม "ค้นหา"',
      );
    }

    if (_isSearching && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        message: 'ไม่พบผลลัพธ์\nลองเปลี่ยนคำค้นหาหรือตัวกรอง',
      );
    }

    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Text(
                'ผลลัพธ์: $_total รายการ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        // Results List
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _results.length + (_hasMore ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              if (index >= _results.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildThreadCard(_results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadCard(Thread thread) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(thread);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Category & Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    thread.categoryText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  thread.status == ThreadStatus.open
                      ? Icons.check_circle
                      : thread.status == ThreadStatus.closed
                          ? Icons.cancel
                          : Icons.archive,
                  size: 16,
                  color: thread.status == ThreadStatus.open
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  thread.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Author & Date
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  thread.authorName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatRelative(thread.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stats
            Row(
              children: [
                Icon(Icons.comment, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${thread.replyCount} ตอบ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${thread.viewCount} ดู',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.thumb_up, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${thread.upvoteCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
