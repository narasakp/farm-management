import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../utils/seed_data.dart';
import '../../providers/trading_provider.dart';
import '../../widgets/app_bars/standard_app_bar.dart';

/// 🛠️ หน้า Debug สำหรับ Seed ข้อมูล
/// เข้าได้ที่: localhost:8096/#/seed-data

class SeedDataScreen extends StatelessWidget {
  const SeedDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.detail,
        title: '🛠️ Seed Data (Dev)',
        onBackPressed: () => context.go('/dashboard'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.science, size: 100, color: Colors.orange),
              const SizedBox(height: 32),
              const Text(
                'เครื่องมือสำหรับนักพัฒนา',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'เพิ่มข้อมูลทดสอบเข้า Firestore',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              
              // ปุ่มเพิ่มข้อมูล
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'เพิ่มข้อมูล Sample',
                      message: 'ต้องการเพิ่มข้อมูลตัวอย่าง 8 รายการใช่ไหม?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังเพิ่มข้อมูล...');
                        
                        try {
                          await SeedData.seedMarketListings();
                          Navigator.pop(context); // ปิด loading
                          
                          _showSuccessDialog(context, 'เพิ่มข้อมูล 8 รายการสำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context); // ปิด loading
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 32),
                  label: const Text(
                    'เพิ่มข้อมูล Sample',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ปุ่มลบข้อมูล
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'ลบข้อมูลทั้งหมด',
                      message: 'คำเตือน! การดำเนินการนี้จะลบข้อมูลทั้งหมดใน market_listings',
                      isDangerous: true,
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังลบข้อมูล...');
                        
                        try {
                          await SeedData.clearMarketListings();
                          Navigator.pop(context); // ปิด loading
                          
                          _showSuccessDialog(context, 'ลบข้อมูลสำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context); // ปิด loading
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_forever, size: 32),
                  label: const Text(
                    'ลบข้อมูลทั้งหมด',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ปุ่ม Reset Market Listings
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'Reset Market Listings',
                      message: 'ลบข้อมูลเก่าแล้วเพิ่มข้อมูล Sample ใหม่?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลัง Reset...');
                        
                        try {
                          await SeedData.resetMarketListings();
                          
                          // Clear provider cache
                          if (context.mounted) {
                            final tradingProvider = context.read<TradingProvider>();
                            await tradingProvider.loadMarketListings();
                          }
                          
                          Navigator.pop(context); // ปิด loading
                          
                          _showSuccessDialog(context, 'Reset ข้อมูลสำเร็จ! ข้อมูลใหม่ได้โหลดแล้ว');
                        } catch (e) {
                          Navigator.pop(context); // ปิด loading
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 32),
                  label: const Text(
                    'Reset Market',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ปุ่มลบข้อมูลซ้ำ
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'ลบข้อมูลซ้ำ',
                      message: 'ตรวจสอบและลบข้อมูลส่วนเกิน (เก็บไว้แค่ 8 รายการ)?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังตรวจสอบ...');
                        
                        try {
                          await SeedData.removeDuplicates();
                          Navigator.pop(context); // ปิด loading
                          
                          _showSuccessDialog(context, 'ตรวจสอบและลบข้อมูลซ้ำเรียบร้อย!');
                        } catch (e) {
                          Navigator.pop(context); // ปิด loading
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.cleaning_services, size: 32),
                  label: const Text(
                    'ลบข้อมูลซ้ำ',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ปุ่มแก้ไข Image Paths 🔧
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: '🔧 แก้ไข Image Paths',
                      message: 'ลบ "assets/" ออกจาก image paths ทั้งหมด?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังแก้ไข paths...');
                        
                        try {
                          await SeedData.fixImagePaths();
                          Navigator.pop(context); // ปิด loading
                          
                          _showSuccessDialog(context, '✅ แก้ไข Image Paths เรียบร้อย!\nรูปภาพจะแสดงผลถูกต้องแล้ว');
                        } catch (e) {
                          Navigator.pop(context); // ปิด loading
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.build, size: 32),
                  label: const Text(
                    'แก้ไข Image Paths',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Divider(),
              
              // Social Commerce Section
              const SizedBox(height: 24),
              const Text(
                '📱 Social Commerce Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'ข้อมูลสำหรับ Social Shares และ Orders',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // ปุ่ม Seed Social Shares
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'เพิ่ม Social Shares',
                      message: 'เพิ่มข้อมูล Social Shares (7 รายการ)?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังเพิ่มข้อมูล...');
                        
                        try {
                          await SeedData.seedSocialShares();
                          Navigator.pop(context);
                          
                          _showSuccessDialog(context, 'เพิ่ม Social Shares สำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context);
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.share, size: 32),
                  label: const Text(
                    'Seed Social Shares',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ปุ่ม Seed Orders
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'เพิ่ม Orders',
                      message: 'เพิ่มข้อมูล Orders (5 รายการ)?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังเพิ่มข้อมูล...');
                        
                        try {
                          await SeedData.seedOrders();
                          Navigator.pop(context);
                          
                          _showSuccessDialog(context, 'เพิ่ม Orders สำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context);
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.shopping_cart, size: 32),
                  label: const Text(
                    'Seed Orders',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Divider(),
              
              // All Data Section
              const SizedBox(height: 24),
              const Text(
                '🎯 ข้อมูลทั้งหมด (All Data)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // ปุ่ม Seed All
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'Seed ข้อมูลทั้งหมด',
                      message: 'เพิ่มข้อมูล Market + Social Shares + Orders?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลัง Seed ทั้งหมด...');
                        
                        try {
                          await SeedData.seedAll();
                          Navigator.pop(context);
                          
                          _showSuccessDialog(context, '🎉 Seed ทั้งหมดสำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context);
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.rocket_launch, size: 32),
                  label: const Text(
                    'Seed All Data',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ปุ่ม Clear All
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'ลบข้อมูลทั้งหมด',
                      message: 'คำเตือน! จะลบข้อมูลทั้งหมด (Market + Social + Orders)',
                      isDangerous: true,
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลังลบทั้งหมด...');
                        
                        try {
                          await SeedData.clearAll();
                          Navigator.pop(context);
                          
                          _showSuccessDialog(context, 'ลบข้อมูลทั้งหมดสำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context);
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_sweep, size: 32),
                  label: const Text(
                    'Clear All Data',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ปุ่ม Reset All
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _showConfirmDialog(
                      context,
                      title: 'Reset ข้อมูลทั้งหมด',
                      message: 'ลบข้อมูลเก่าและเพิ่มข้อมูล Sample ใหม่ทั้งหมด?',
                      onConfirm: () async {
                        _showLoadingDialog(context, 'กำลัง Reset ทั้งหมด...');
                        
                        try {
                          await SeedData.resetAll();
                          Navigator.pop(context);
                          
                          _showSuccessDialog(context, '🔄 Reset ทั้งหมดสำเร็จ!');
                        } catch (e) {
                          Navigator.pop(context);
                          _showErrorDialog(context, e.toString());
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.restore, size: 32),
                  label: const Text(
                    'Reset All Data',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Divider(),
              
              const SizedBox(height: 16),
              
              const Text(
                '⚠️ หน้านี้ใช้เฉพาะสำหรับพัฒนาเท่านั้น',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'ห้ามใช้ใน Production!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDangerous = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? Colors.red : Colors.green,
            ),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }
  
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 16),
            Text('สำเร็จ!'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 16),
            Text('เกิดข้อผิดพลาด'),
          ],
        ),
        content: Text(error),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
