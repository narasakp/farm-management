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
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController();
    final minPriceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedLivestock = 'cattle001';
    bool isNegotiable = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างประกาศขาย'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLivestock,
                  decoration: const InputDecoration(
                    labelText: 'เลือกปศุสัตว์',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cattle001', child: Text('โค #001')),
                    DropdownMenuItem(value: 'cattle002', child: Text('โค #002')),
                    DropdownMenuItem(value: 'pig001', child: Text('สุกร #001')),
                    DropdownMenuItem(value: 'chicken001', child: Text('ไก่ #001')),
                  ],
                  onChanged: (value) => selectedLivestock = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาขาย (บาท)',
                    border: OutlineInputBorder(),
                    prefixText: '฿ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'กรุณาใส่ราคา';
                    if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาต่ำสุด (บาท)',
                    border: OutlineInputBorder(),
                    prefixText: '฿ ',
                    hintText: 'ถ้าต่อรองได้',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด',
                    border: OutlineInputBorder(),
                    hintText: 'อธิบายเพิ่มเติมเกี่ยวกับปศุสัตว์',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('ต่อรองราคาได้'),
                  value: isNegotiable,
                  onChanged: (value) => isNegotiable = value ?? false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final listing = MarketListing(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  farmId: 'current_user_farm',
                  livestockId: selectedLivestock,
                  askingPrice: double.parse(priceController.text),
                  minPrice: minPriceController.text.isNotEmpty 
                      ? double.parse(minPriceController.text) 
                      : null,
                  description: descriptionController.text.isNotEmpty 
                      ? descriptionController.text 
                      : null,
                  isNegotiable: isNegotiable,
                  listedDate: DateTime.now(),
                  status: 'active',
                  viewCount: 0,
                  createdAt: DateTime.now(),
                );
                
                context.read<TradingProvider>().createListing(listing);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('สร้างประกาศเรียบร้อยแล้ว')),
                );
              }
            },
            child: const Text('สร้างประกาศ'),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลติดต่อผู้ขาย:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('นายสมชาย ใจดี'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                const Text('044-123-456'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                const Text('บ้านเลขที่ 123 ต.เนินสง่า อ.เนินสง่า จ.ชัยภูมิ'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('หมายเหตุ: กรุณาติดต่อในเวลา 08:00-18:00 น.', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เปิดแอปโทรศัพท์')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('โทร'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(LivestockMarket market) {
    final formKey = GlobalKey<FormState>();
    final livestockCountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedTimeSlot = '06:00-08:00';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('จองคิว ${market.name}'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('วันที่: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTimeSlot,
                    decoration: const InputDecoration(
                      labelText: 'ช่วงเวลา',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '06:00-08:00', child: Text('06:00-08:00')),
                      DropdownMenuItem(value: '08:00-10:00', child: Text('08:00-10:00')),
                      DropdownMenuItem(value: '10:00-12:00', child: Text('10:00-12:00')),
                    ],
                    onChanged: (value) => selectedTimeSlot = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: livestockCountController,
                    decoration: const InputDecoration(
                      labelText: 'จำนวนปศุสัตว์',
                      border: OutlineInputBorder(),
                      suffixText: 'ตัว',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'กรุณาใส่จำนวน';
                      if (int.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'หมายเหตุ',
                      border: OutlineInputBorder(),
                      hintText: 'ข้อมูลเพิ่มเติม (ถ้ามี)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final booking = MarketBooking(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    farmId: 'current_user_farm',
                    marketId: market.id,
                    bookingDate: selectedDate,
                    livestockType: 'โค',
                    quantity: int.parse(livestockCountController.text),
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                    status: 'confirmed',
                    createdAt: DateTime.now(),
                  );
                  
                  context.read<TradingProvider>().bookMarketQueue(booking);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('จองคิวเรียบร้อยแล้ว')),
                  );
                }
              },
              child: const Text('จองคิว'),
            ),
          ],
        ),
      ),
    );
  }

  void _editListing(MarketListing listing) {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController(text: listing.askingPrice.toString());
    final minPriceController = TextEditingController(text: listing.minPrice?.toString() ?? '');
    final descriptionController = TextEditingController(text: listing.description ?? '');
    bool isNegotiable = listing.isNegotiable;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขประกาศขาย'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาขาย (บาท)',
                    border: OutlineInputBorder(),
                    prefixText: '฿ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'กรุณาใส่ราคา';
                    if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาต่ำสุด (บาท)',
                    border: OutlineInputBorder(),
                    prefixText: '฿ ',
                    hintText: 'ถ้าต่อรองได้',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('ต่อรองราคาได้'),
                  value: isNegotiable,
                  onChanged: (value) => isNegotiable = value ?? false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedListing = MarketListing(
                  id: listing.id,
                  farmId: listing.farmId,
                  livestockId: listing.livestockId,
                  askingPrice: double.parse(priceController.text),
                  minPrice: minPriceController.text.isNotEmpty 
                      ? double.parse(minPriceController.text) 
                      : null,
                  description: descriptionController.text.isNotEmpty 
                      ? descriptionController.text 
                      : null,
                  isNegotiable: isNegotiable,
                  listedDate: listing.listedDate,
                  status: listing.status,
                  viewCount: listing.viewCount,
                  createdAt: listing.createdAt,
                );
                
                context.read<TradingProvider>().updateListing(updatedListing);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('แก้ไขประกาศเรียบร้อยแล้ว')),
                );
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
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
