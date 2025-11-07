import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_bars/standard_app_bar.dart';
import '../providers/production_auth_provider.dart';
import '../providers/contact_info_provider.dart';

class ContactAdminScreen extends ConsumerWidget {
  const ContactAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(productionAuthProvider);
    final userRole = authState.user?['role'] as String?;
    final isAdmin = authState.isAuthenticated && 
                    (userRole == 'SUPER_ADMIN' || userRole == 'ADMIN');
    
    // Watch contact info from provider
    final contactInfo = ref.watch(contactInfoProvider);

    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'ติดต่อผู้ดูแลระบบ',
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/admin-contact-settings'),
              backgroundColor: Color(0xFF1976D2), // Blue
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text(
                'แก้ไขข้อมูล',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Color(0xFF228B22), // Forest Green
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF228B22),
                    Color(0xFF2E7D32),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Admin Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.support_agent,
                      size: 50,
                      color: Color(0xFF228B22),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ทีมสนับสนุนพร้อมช่วยเหลือ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ติดต่อเราได้ทุกช่องทาง',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Contact Methods
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Email Contact
                  _ContactCard(
                    icon: Icons.email,
                    iconColor: Color(0xFF1976D2), // Blue
                    title: 'อีเมล',
                    subtitle: contactInfo.email,
                    description: 'ส่งอีเมลถึงเรา เราจะตอบกลับภายใน 24 ชั่วโมง',
                    onTap: () => _launchEmail(contactInfo.email),
                  ),
                  SizedBox(height: 16),

                  // Phone Contact
                  _ContactCard(
                    icon: Icons.phone,
                    iconColor: Color(0xFF228B22), // Green
                    title: 'โทรศัพท์',
                    subtitle: contactInfo.phone,
                    description: 'โทรได้ทุกวัน 08:00 - 17:00 น.',
                    onTap: () => _launchPhone(contactInfo.phone),
                  ),
                  SizedBox(height: 16),

                  // LINE Contact
                  _ContactCard(
                    icon: Icons.chat,
                    iconColor: Color(0xFF00B900), // LINE Green
                    title: 'LINE',
                    subtitle: contactInfo.lineId,
                    description: 'แชทกับเราทาง LINE ตอบเร็วที่สุด',
                    onTap: () => _launchLine(contactInfo.lineId),
                  ),
                  SizedBox(height: 32),

                  // Office Hours
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Color(0xFF8B4513), // Brown
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'เวลาทำการ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _InfoRow('วันจันทร์ - วันศุกร์', '08:00 - 17:00 น.'),
                          SizedBox(height: 8),
                          _InfoRow('วันเสาร์', '08:00 - 12:00 น.'),
                          SizedBox(height: 8),
                          _InfoRow('วันอาทิตย์และวันหยุดนักขัตฤกษ์', 'ปิดทำการ'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Emergency Note
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE0B2), // Soft Orange
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFFF9800), // Orange
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF9800),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'กรณีบัญชีถูกล็อค 24 ชั่วโมง กรุณาติดต่อทีมสนับสนุนเพื่อขอความช่วยเหลือ',
                            style: TextStyle(
                              color: Color(0xFF8B4513), // Brown
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'ติดต่อผู้ดูแลระบบ - Farm Management App',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchLine(String lineId) async {
    final Uri lineUri = Uri.parse('https://line.me/R/ti/p/$lineId');
    
    if (await canLaunchUrl(lineUri)) {
      await launchUrl(lineUri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _ContactCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513), // Brown
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF228B22), // Green
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8B4513), // Brown
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF228B22), // Green
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
