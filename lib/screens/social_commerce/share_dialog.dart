import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';
import '../../services/social_commerce/share_service.dart';
import '../../widgets/social_commerce/share_preview_card.dart';

/// Dialog สำหรับแชร์ไปยัง Social Media
class ShareDialog extends StatefulWidget {
  final MarketListing listing;
  final Livestock livestock;
  final String userId;
  
  const ShareDialog({
    Key? key,
    required this.listing,
    required this.livestock,
    required this.userId,
  }) : super(key: key);
  
  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  String _selectedTemplate = 'card';
  final Set<String> _selectedPlatforms = {'facebook'};
  final TextEditingController _captionController = TextEditingController();
  bool _showUrgentBadge = false;
  bool _isSharing = false;
  
  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'card',
      'name': 'Card',
      'icon': Icons.credit_card,
      'description': 'การ์ดมาตรฐาน',
    },
    {
      'id': 'price',
      'name': 'Price',
      'icon': Icons.local_offer,
      'description': 'เน้นราคา',
    },
    {
      'id': 'gallery',
      'name': 'Gallery',
      'icon': Icons.grid_view,
      'description': 'แบบ Gallery',
    },
    {
      'id': 'video',
      'name': 'Video',
      'icon': Icons.videocam,
      'description': 'สำหรับ TikTok',
    },
  ];
  
  final List<Map<String, dynamic>> _platforms = [
    {
      'id': 'facebook',
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': Color(0xFF1877F2),
    },
    {
      'id': 'tiktok',
      'name': 'TikTok',
      'icon': Icons.music_note,
      'color': Color(0xFF000000),
    },
    {
      'id': 'x',
      'name': 'X (Twitter)',
      'icon': Icons.tag,
      'color': Color(0xFF000000),
    },
    {
      'id': 'line',
      'name': 'LINE',
      'icon': Icons.chat_bubble,
      'color': Color(0xFF00B900),
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _captionController.text = widget.listing.shareDescription ?? 
        widget.listing.description ?? 
        'ขาย${widget.livestock.type.displayName}';
  }
  
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.share,
                  color: Color(0xFF228B22),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'แชร์ขายปศุสัตว์',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF228B22),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template Selection
                    _buildSectionTitle('เลือก Template'),
                    const SizedBox(height: 12),
                    _buildTemplateSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Preview
                    _buildSectionTitle('ตัวอย่าง'),
                    const SizedBox(height: 12),
                    Center(
                      child: SharePreviewCard(
                        template: _selectedTemplate,
                        listing: widget.listing,
                        livestock: widget.livestock,
                        customization: {
                          'showUrgentBadge': _showUrgentBadge,
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Platform Selection
                    _buildSectionTitle('เลือก Platform'),
                    const SizedBox(height: 12),
                    _buildPlatformSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Caption
                    _buildSectionTitle('Caption'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'เขียนคำบรรยาย...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Options
                    CheckboxListTile(
                      value: _showUrgentBadge,
                      onChanged: (value) {
                        setState(() {
                          _showUrgentBadge = value ?? false;
                        });
                      },
                      title: const Text('เพิ่มป้าย "ขายด่วน"'),
                      activeColor: const Color(0xFF228B22),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _handleShare,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share),
                    label: Text(_isSharing ? 'กำลังแชร์...' : 'แชร์เลย'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
  
  Widget _buildTemplateSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          final template = _templates[index];
          final isSelected = _selectedTemplate == template['id'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTemplate = template['id'];
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF228B22) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF228B22) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    template['icon'],
                    size: 32,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    template['description'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPlatformSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _platforms.map((platform) {
        final isSelected = _selectedPlatforms.contains(platform['id']);
        
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                platform['icon'],
                size: 20,
                color: isSelected ? Colors.white : platform['color'],
              ),
              const SizedBox(width: 8),
              Text(platform['name']),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedPlatforms.add(platform['id']);
              } else {
                _selectedPlatforms.remove(platform['id']);
              }
            });
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: platform['color'],
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
  
  Future<void> _handleShare() async {
    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกอย่างน้อย 1 platform'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isSharing = true;
    });
    
    try {
      final shareService = ShareService();
      int successCount = 0;
      
      // แชร์ไปแต่ละ platform
      for (final platform in _selectedPlatforms) {
        final success = await shareService.shareToSocial(
          listing: widget.listing,
          livestock: widget.livestock,
          platform: platform,
          template: _selectedTemplate,
          customization: {
            'showUrgentBadge': _showUrgentBadge,
          },
          userId: widget.userId,
        );
        
        if (success) successCount++;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('แชร์สำเร็จ $successCount จาก ${_selectedPlatforms.length} platform'),
            backgroundColor: const Color(0xFF228B22),
            action: SnackBarAction(
              label: 'ตกลง',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error sharing: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}

/// ฟังก์ชัน Helper สำหรับเปิด Share Dialog
Future<void> showShareDialog({
  required BuildContext context,
  required MarketListing listing,
  required Livestock livestock,
  required String userId,
}) async {
  return showDialog(
    context: context,
    builder: (context) => ShareDialog(
      listing: listing,
      livestock: livestock,
      userId: userId,
    ),
  );
}
