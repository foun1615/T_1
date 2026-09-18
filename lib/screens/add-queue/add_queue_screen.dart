import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_queue_manager/models/queue.dart';
import 'package:restaurant_queue_manager/repository/queue_repository.dart';
import 'package:restaurant_queue_manager/screens/home_screen.dart';

class AddQueueScreen extends StatefulWidget {
  final Queue? editQueue; 

  const AddQueueScreen({super.key, this.editQueue});

  @override
  State<AddQueueScreen> createState() => _AddQueueScreenState();
}

class _AddQueueScreenState extends State<AddQueueScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customerName = TextEditingController();
  final _pax = TextEditingController();
  String _zone = 'ห้องแอร์';
  bool _saving = false;

  bool get _isEditing => widget.editQueue != null;

  final _zones = const ['ห้องแอร์', 'พัดลม', 'กลับบ้าน'];

  static const _zoneIcons = {
    'ห้องแอร์': Icons.ac_unit_rounded,
    'พัดลม': Icons.air_rounded,
    'กลับบ้าน': Icons.home_rounded,
  };

  @override
  void initState() {
    super.initState();
    final editQueue = widget.editQueue;
    if (editQueue != null) {
      _customerName.text = editQueue.customerName;
      _pax.text = editQueue.pax.toString();
      _zone = editQueue.zone;
    }
  }

  @override
  void dispose() {
    _customerName.dispose();
    _pax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "แก้ไขคิว" : "เพิ่มคิว"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isEditing
                                ? Icons.edit_outlined
                                : Icons.person_add_alt_1_rounded,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "ข้อมูลลูกค้า",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerName,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: "ชื่อลูกค้า",
                          hintText: "เช่น คุณสมชาย",
                          prefixIcon: Icon(Icons.person_outline_rounded),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณาป้อนชื่อลูกค้า";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pax,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        // รับเฉพาะตัวเลขเท่านั้น ตามที่โจทย์กำหนด
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: "จำนวนคน",
                          hintText: "เช่น 4",
                          prefixIcon: Icon(Icons.people_alt_outlined),
                          counterText: "",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณาป้อนจำนวนคน";
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return "กรุณาป้อนจำนวนคนเป็นตัวเลขที่มากกว่า 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _zone,
                        decoration: const InputDecoration(
                          labelText: "โซนที่ต้องการ",
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        items: _zones.map((zone) {
                          return DropdownMenuItem(
                            value: zone,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_zoneIcons[zone], size: 18),
                                const SizedBox(width: 8),
                                Text(zone),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _zone = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _saveQueue();
                          }
                        },
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_saving
                      ? "กำลังบันทึก..."
                      : (_isEditing ? "บันทึกการแก้ไข" : "บันทึกคิว")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveQueue() async {
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final original = widget.editQueue!;
        final updated = Queue(
          id: original.id,
          customerName: _customerName.text.trim(),
          pax: int.parse(_pax.text),
          zone: _zone,
          createdAt: original.createdAt, // คงเวลาที่เข้าคิวเดิมไว้
        );
        await QueueRepository.update(queue: updated);
      } else {
        final queue = Queue(
          customerName: _customerName.text.trim(),
          pax: int.parse(_pax.text),
          zone: _zone,
          createdAt: DateTime.now(),
        );
        await QueueRepository.insert(queue: queue);
      }
      if (!mounted) return;
      if (_isEditing) {
        Navigator.pop(context); // กลับไปหน้ารายการ แล้วให้ home_screen รีเฟรช
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("บันทึกไม่สำเร็จ: $e")),
      );
    }
  }
}