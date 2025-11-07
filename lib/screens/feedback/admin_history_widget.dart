// Admin History Widget - temporary file for _buildAdminHistory method

Widget _buildAdminHistory() {
  return Consumer<FeedbackProvider>(
    builder: (context, feedbackProvider, child) {
      // กรองเฉพาะ feedback ที่ rejected หรือ closed (สำหรับแท็บ "ประวัติ")
      var feedbacks = feedbackProvider.feedbacks
          .where((f) => 
              f.status == FeedbackModel.FeedbackStatus.rejected ||
              f.status == FeedbackModel.FeedbackStatus.closed)
          .toList();

      // Apply filters
      if (_filterType != null) {
        feedbacks = feedbacks.where((f) => f.type == _filterType).toList();
      }
      if (_filterStatus != null) {
        feedbacks = feedbacks.where((f) => f.status == _filterStatus).toList();
      }
      if (_filterCategory != null) {
        feedbacks = feedbacks.where((f) => f.category == _filterCategory).toList();
      }
      if (_searchQuery.isNotEmpty) {
        feedbacks = feedbacks
            .where((f) =>
                f.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                f.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                f.userName.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      if (feedbacks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'ไม่มีประวัติข้อเสนอแนะ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ข้อเสนอแนะที่ถูกปฏิเสธหรือปิดจะแสดงที่นี่',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Search Bar (simple version)
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหาประวัติ',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Feedback List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];
                final isRejected = feedback.status == FeedbackModel.FeedbackStatus.rejected;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isRejected ? Colors.red[200]! : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isRejected 
                                    ? Colors.red[100] 
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isRejected ? Icons.cancel : Icons.archive,
                                color: isRejected 
                                    ? Colors.red[800] 
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feedback.subject,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildTypeChip(feedback.type),
                                      const SizedBox(width: 8),
                                      _buildStatusChip(feedback.status),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        
                        // Message
                        Text(
                          feedback.message,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Admin Response (if any)
                        if (feedback.adminResponse != null && 
                            feedback.adminResponse!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                Row(
                                  children: [
                                    Icon(Icons.admin_panel_settings, 
                                        size: 16, 
                                        color: Colors.grey[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'คำตอบจากผู้ดูแล:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  feedback.adminResponse!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Submitter Info
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              feedback.userName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(feedback.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
