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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คิวร้านอาหาร'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: QueueRepository.getQueue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("ยังไม่มีคิว"),
              );
            }
            // ใช้ ListView.builder ตามที่โจทย์กำหนด
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final queue = snapshot.data![index];
                return ItemQueue(
                  queue: queue,
                  onDeleted: () => setState(() {}),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQueueScreen()),
          );
          setState(() {});
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}