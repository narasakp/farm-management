import 'package:flutter/material.dart';

/// Widget แสดงอีเมลของ User - สร้างใหม่ 2025-10-24
class UserEmailDisplay extends StatelessWidget {
  final String? email;
  
  const UserEmailDisplay({Key? key, required this.email}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final displayEmail = email ?? 'ไม่มีอีเมล';
    
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.email, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayEmail,
              style: TextStyle(
                fontSize: 13,
                color: email != null ? Colors.black87 : Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
