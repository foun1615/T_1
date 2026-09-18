import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_queue_manager/models/queue.dart';
import 'package:restaurant_queue_manager/repository/queue_repository.dart';

class ItemQueue extends StatelessWidget {
  final Queue queue;
  final VoidCallback onDeleted;
  final VoidCallback onEdit; // ใหม่
  const ItemQueue({
    super.key,
    required this.queue,
    required this.onDeleted,
    required this.onEdit,
  });

  Color _zoneColor() {
    switch (queue.zone) {
      case 'ห้องแอร์':
        return const Color(0xFF339AF0);
      case 'พัดลม':
        return const Color(0xFFF59F00);
      default:
        return const Color(0xFF37B24D);
    }
  }

  IconData _zoneIcon() {
    switch (queue.zone) {
      case 'ห้องแอร์':
        return Icons.ac_unit_rounded;
      case 'พัดลม':
        return Icons.air_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เรียกคิวแล้ว"),
        content: Text("ยืนยันลบคิวของ ${queue.customerName} ออกจากระบบใช่หรือไม่"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await QueueRepository.delete(queue: queue);
              onDeleted();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  //  เมนูให้เลือกว่าจะแก้ไขหรือลบ แทนการลบทันทีเมื่อแตะการ์ด
  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('แก้ไขคิว'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text(
                'ลบคิว (เรียกคิวแล้ว)',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zoneColor = _zoneColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: zoneColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showActions(context), // เปลี่ยนจากลบทันที เป็นเปิดเมนู
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถวบน: ชื่อลูกค้า (ตัวใหญ่สุดของบัตรคิว) + เวลาที่กดบัตรคิว มุมขวาบน
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        queue.customerName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          // เวลาที่กดบัตรคิว (ใช้ intl)
                          DateFormat(DateFormat.HOUR_MINUTE)
                              .format(queue.createdAt),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd/MM/yyyy').format(queue.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      icon: Icons.people_alt_outlined,
                      label: "${queue.pax} ท่าน",
                      color: Colors.grey.shade700,
                      background: Colors.grey.shade100,
                    ),
                    _Chip(
                      icon: _zoneIcon(),
                      label: queue.zone,
                      color: zoneColor,
                      background: zoneColor.withOpacity(0.12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}