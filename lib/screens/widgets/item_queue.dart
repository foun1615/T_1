import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_queue_manager/models/queue.dart';
import 'package:restaurant_queue_manager/repository/queue_repository.dart';

class ItemQueue extends StatelessWidget {
  final Queue queue;
  final VoidCallback onDeleted;
  const ItemQueue({super.key, required this.queue, required this.onDeleted});

  Color _zoneColor() {
    switch (queue.zone) {
      case 'ห้องแอร์':
        return Colors.lightBlueAccent;
      case 'พัดลม':
        return Colors.amberAccent;
      default:
        return Colors.green;
    }
  }

  _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เรียกคิวแล้ว"),
        content: Text("ยืนยันลบคิวของ ${queue.customerName} ออกจากระบบใช่หรือไม่"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
          TextButton(
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _zoneColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    queue.customerName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // มุมขวาบน: แสดงทั้งวันที่และเวลาที่กดบัตรคิว (ใช้ intl)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat(DateFormat.HOUR_MINUTE).format(queue.createdAt),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy').format(queue.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 18),
                const SizedBox(width: 5),
                Text("${queue.pax} ท่าน"),
                const SizedBox(width: 15),
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 5),
                Text(queue.zone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}