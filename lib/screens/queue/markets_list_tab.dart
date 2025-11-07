import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/market_provider.dart';
import '../../models/market.dart';
import '../../utils/responsive_helper.dart';
import 'booking_dialog.dart';

/// Tab สำหรับแสดงรายการตลาดนัด
class MarketsListTab extends StatefulWidget {
  const MarketsListTab({super.key});

  @override
  State<MarketsListTab> createState() => _MarketsListTabState();
}

class _MarketsListTabState extends State<MarketsListTab> {
  final TextEditingController _searchController = TextEditingController();
  
  // ประเภทสัตว์สำหรับกรอง
  final List<String> _livestockTypes = [
    'ทั้งหมด',
    'โค',
    'กระบือ',
    'สุกร',
    'เป็ด',
    'ไก่',
    'แพะ',
    'แกะ',
  ];

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลตลาด
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().loadMarkets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(),
        
        const SizedBox(height: 16),
        
        // Livestock Type Filter
        _buildLivestockFilter(),
        
        const SizedBox(height: 16),
        
        // Markets Grid/List
        Expanded(
          child: _buildMarketsList(),
        ),
      ],
    );
  }

  /// Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาตลาด...',
          hintStyle: const TextStyle(fontSize: 20),
          prefixIcon: const Icon(Icons.search, size: 28),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 28),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        style: const TextStyle(fontSize: 20),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  /// Livestock Type Filter Chips
  Widget _buildLivestockFilter() {
    return Consumer<MarketProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _livestockTypes.length,
            itemBuilder: (context, index) {
              final type = _livestockTypes[index];
              final isSelected = provider.selectedLivestockFilter == type;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.filterByLivestock(type);
                  },
                  selectedColor: const Color(0xFF228B22),
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Markets List
  Widget _buildMarketsList() {
    return Consumer<MarketProvider>(
      builder: (context, provider, _) {
        // Loading
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 5),
                SizedBox(height: 16),
                Text('กำลังโหลดตลาด...', style: TextStyle(fontSize: 20)),
              ],
            ),
          );
        }

        // Error
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาด',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.loadMarkets(),
                  icon: const Icon(Icons.refresh, size: 28),
                  label: const Text('ลองอีกครั้ง', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter markets by search query
        var markets = provider.filteredMarkets;
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          markets = markets.where((market) {
            return market.name.toLowerCase().contains(query) ||
                   market.location.toLowerCase().contains(query);
          }).toList();
        }

        // Empty
        if (markets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ไม่พบตลาด',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ลองค้นหาหรือเปลี่ยนตัวกรองใหม่',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Markets Grid
        return RefreshIndicator(
          onRefresh: () => provider.loadMarkets(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              spacing: 16,
              children: markets.map((market) {
                return _buildMarketCard(market);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Market Card
  Widget _buildMarketCard(Market market) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showBookingDialog(context, market),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                market.imageUrl ?? 'https://picsum.photos/seed/default/800/600',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.store, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    market.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          market.location,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${market.rating.toStringAsFixed(1)} (${market.reviewCount})',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Zones
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: market.zones.take(3).map((zone) {
                      return Chip(
                        avatar: Icon(zone.icon, size: 18),
                        label: Text(
                          '${zone.code}: ${zone.livestockType}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        backgroundColor: const Color(0xFF228B22).withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      );
                    }).toList(),
                  ),

                  if (market.zones.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'และอีก ${market.zones.length - 3} โซน...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showBookingDialog(context, market),
                      icon: const Icon(Icons.calendar_today, size: 24),
                      label: const Text(
                        'จองคิว',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  /// Show Booking Dialog
  void _showBookingDialog(BuildContext context, Market market) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(market: market),
    ).then((success) {
      if (success == true) {
        // Refresh markets if booking successful
        context.read<MarketProvider>().loadMarkets();
      }
    });
  }
}
