import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trading_provider.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'ทั้งหมด';
  String _sortBy = 'ล่าสุด';

  final List<String> _categories = [
    'ทั้งหมด',
    'โค',
    'กระบือ', 
    'สุกร',
    'ไก่',
    'เป็ด',
    'แพะ',
    'แกะ'
  ];

  final List<String> _sortOptions = [
    'ล่าสุด',
    'ราคาต่ำ-สูง',
    'ราคาสูง-ต่ำ',
    'ยอดนิยม'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingProvider>().loadMarketListings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตลาดปศุสัตว์'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ซื้อ-ขาย', icon: Icon(Icons.store)),
            Tab(text: 'จองคิว', icon: Icon(Icons.schedule)),
            Tab(text: 'ประกาศของฉัน', icon: Icon(Icons.list_alt)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => _sortOptions
                .map((option) => PopupMenuItem(
                      value: option,
                      child: Text(option),
                    ))
                .toList(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketplaceTab(),
          _buildQueueBookingTab(),
          _buildMyListingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListingDialog,
        child: const Icon(Icons.add),
        tooltip: 'ประกาศขาย',
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: Consumer<TradingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final listings = provider.getFilteredListings(_selectedCategory, _sortBy);
              
              if (listings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ไม่มีประกาศขายในขณะนี้'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  return _buildListingCard(listings[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueBookingTab() {
    return Consumer<TradingProvider>(
      builder: (context, provider, child) {
        final markets = provider.availableMarkets;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: markets.length,
          itemBuilder: (context, index) {
            return _buildMarketCard(markets[index]);
          },
        );
      },
    );
  }

  Widget _buildMyListingsTab() {
    return Consumer<TradingProvider>(
      builder: (context, provider, child) {
        final myListings = provider.myListings;
        
        if (myListings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('คุณยังไม่มีประกาศขาย'),
                SizedBox(height: 8),
                Text('กดปุ่ม + เพื่อสร้างประกาศใหม่'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myListings.length,
          itemBuilder: (context, index) {
            return _buildMyListingCard(myListings[index]);
          },
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildListingCard(MarketListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showListingDetails(listing),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      _getAnimalIcon(listing.livestockId),
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'โค #${listing.livestockId}', // TODO: Get actual livestock name
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'น้ำหนัก: 450 กก. • อายุ: 3 ปี', // TODO: Get actual data
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '฿${listing.askingPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      if (listing.isNegotiable)
                        Text(
                          'ต่อรองได้',
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (listing.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  listing.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'ชัยภูมิ', // TODO: Get actual location
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.viewCount} ครั้ง',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(listing.listedDate),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketCard(LivestockMarket market) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  market.type == 'physical' ? Icons.store : Icons.computer,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        market.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        market.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showBookingDialog(market),
                  child: const Text('จองคิว'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: market.operatingDays.map((day) => Chip(
                label: Text(day, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.green.shade50,
              )).toList(),
            ),
            if (market.operatingHours != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    market.operatingHours!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyListingCard(MarketListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'โค #${listing.livestockId}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '฿${listing.askingPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(listing.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${listing.viewCount} ครั้ง'),
                const Spacer(),
                TextButton(
                  onPressed: () => _editListing(listing),
                  child: const Text('แก้ไข'),
                ),
                TextButton(
                  onPressed: () => _deleteListing(listing),
                  child: const Text('ลบ', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'active':
        color = Colors.green;
        text = 'กำลังขาย';
        break;
      case 'sold':
        color = Colors.blue;
        text = 'ขายแล้ว';
        break;
      case 'expired':
        color = Colors.orange;
        text = 'หมดอายุ';
        break;
      case 'withdrawn':
        color = Colors.grey;
        text = 'ถอนประกาศ';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  IconData _getAnimalIcon(String livestockId) {
    // TODO: Get actual animal type from livestock data
    return Icons.agriculture;
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else {
      return '${difference.inMinutes} นาทีที่แล้ว';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ค้นหา'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'ค้นหาปศุสัตว์...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ค้นหา'),
          ),
        ],
      ),
    );
  }

  void _showCreateListingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างประกาศขาย'),
        content: const Text('ฟีเจอร์นี้กำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(MarketListing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียด #${listing.livestockId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ราคา: ฿${listing.askingPrice.toStringAsFixed(0)}'),
            if (listing.description != null) ...[
              const SizedBox(height: 8),
              Text('รายละเอียด: ${listing.description}'),
            ],
            const SizedBox(height: 8),
            Text('วันที่ประกาศ: ${listing.listedDate.day}/${listing.listedDate.month}/${listing.listedDate.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactDialog();
            },
            child: const Text('ติดต่อ'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ติดต่อผู้ขาย'),
        content: const Text('ฟีเจอร์นี้กำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(LivestockMarket market) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('จองคิว ${market.name}'),
        content: const Text('ฟีเจอร์นี้กำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('จองคิว'),
          ),
        ],
      ),
    );
  }

  void _editListing(MarketListing listing) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ฟีเจอร์แก้ไขประกาศกำลังพัฒนา')),
    );
  }

  void _deleteListing(MarketListing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบประกาศ'),
        content: const Text('คุณต้องการลบประกาศนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TradingProvider>().deleteListing(listing.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ลบประกาศเรียบร้อยแล้ว')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
