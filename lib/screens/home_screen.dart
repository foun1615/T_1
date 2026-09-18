import 'package:flutter/material.dart';
import 'package:restaurant_queue_manager/screens/add-queue/add_queue_screen.dart';
import 'package:restaurant_queue_manager/screens/widgets/item_queue.dart';
import 'package:restaurant_queue_manager/repository/queue_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List> _future;

  @override
  void initState() {
    super.initState();
    _future = QueueRepository.getQueue();
  }

  void _reload() {
    setState(() {
      _future = QueueRepository.getQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded, color: primary),
            const SizedBox(width: 8),
            const Text('คิวร้านอาหาร'),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return _EmptyState(primary: primary);
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 96),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final queue = data[index];
                return ItemQueue(
                  queue: queue,
                  onDeleted: _reload,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddQueueScreen(editQueue: queue),
                      ),
                    );
                    _reload();
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQueueScreen()),
          );
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มคิว'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color primary;
  const _EmptyState({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_seat_outlined,
                size: 44,
                color: primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ยังไม่มีคิวในขณะนี้',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'แตะปุ่ม "เพิ่มคิว" ด้านล่างเพื่อบันทึกคิวลูกค้า',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}