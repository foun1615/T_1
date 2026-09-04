import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_queue_manager/models/queue.dart';
import 'package:restaurant_queue_manager/repository/queue_repository.dart';
import 'package:restaurant_queue_manager/screens/home_screen.dart';

class AddQueueScreen extends StatefulWidget {
  const AddQueueScreen({super.key});

  @override
  State<AddQueueScreen> createState() => _AddQueueScreenState();
}

class _AddQueueScreenState extends State<AddQueueScreen> {
  final _formKey = GlobalKey<FormState>();

  final _customerName = TextEditingController();
  final _pax = TextEditingController();
  String _zone = 'ห้องแอร์';

  final _zones = const ['ห้องแอร์', 'พัดลม', 'กลับบ้าน'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มคิว"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _customerName,
                  decoration: InputDecoration(
                    hintText: "ชื่อลูกค้า",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณาป้อนชื่อลูกค้า";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _pax,
                  keyboardType: TextInputType.number,
                  // รับเฉพาะตัวเลขเท่านั้น ตามที่โจทย์กำหนด
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "จำนวนคน",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณาป้อนจำนวนคน";
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return "กรุณาป้อนจำนวนคนเป็นตัวเลขที่มากกว่า 0";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField(
                  value: _zone,
                  decoration: InputDecoration(
                    label: const Text("โซนที่ต้องการ"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _zones.map((zone) {
                    return DropdownMenuItem(
                      value: zone,
                      child: Text(zone),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _zone = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _insertQueue();
                    }
                  },
                  child: const Text("บันทึกคิว"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _insertQueue() async {
    final queue = Queue(
      customerName: _customerName.text,
      pax: int.parse(_pax.text),
      zone: _zone,
      createdAt: DateTime.now(),
    );
    await QueueRepository.insert(queue: queue);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}